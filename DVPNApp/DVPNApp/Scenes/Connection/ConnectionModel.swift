import Foundation
import Combine
import SentinelWallet
import GRPC

private struct Constants {
    let timeout: TimeInterval = 15
    let denom = "udvpn"
}

private let constants = Constants()

enum ConnectionModelEvent {
    case error(Error)
    case warning(Error)

    case setButton(isLoading: Bool)

    case update(isTunnelActive: Bool)
    case updateConnection(status: ConnectionStatus)
    case updateLocation(countryName: String, moniker: String)
    case updateSubscription(initialBandwidth: String, bandwidthConsumed: String)
    case updateBandwidth(bandwidth: Bandwidth)
    case updateTimer(startDate: Date?)
    
    /// When the quota is over
    case openSubscription(for: DVPNNodeInfo)
    case resubscribeToNode(DVPNNodeInfo)
    case resubscribeToPlan(nodeAddress: String, planId: UInt64)
}

enum SubscriptionType {
    case node(String)
    case plan((nodeAddress: String, planId: UInt64))
    
    var nodeAddress: String {
        switch self {
        case let .node(nodeAddress):
            return nodeAddress
        case let .plan((nodeAddress, _)):
            return nodeAddress
        }
    }
}

final class ConnectionModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage & HasTunnelManager
        & HasNetworkService & HasNodesService
    
    private let context: Context

    private var isTunnelActive: Bool {
        context.tunnelManager.isTunnelActive
    }

    private var subscription: SentinelWallet.Subscription?

    private let eventSubject = PassthroughSubject<ConnectionModelEvent, Never>()
    var eventPublisher: AnyPublisher<ConnectionModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private var subscriptionType: SubscriptionType? = nil
    
    private var selectedNode: DVPNNodeInfo?

    init(context: Context) {
        self.context = context
        context.tunnelManager.delegate = self

        fetchWalletInfo()
    }
}

extension ConnectionModel {
    func setInitNodeInfo() {
        guard let sentinelNode = context.nodesService.nodes
                .first(where: { $0.address == context.connectionInfoStorage.lastSelectedNode() }) else {
                    return
                }
        
        selectedNode = sentinelNode.node?.info
        
        guard let node = sentinelNode.node else {
            log.error("Fail to set initial node info")
            return
        }
        
        eventSubject.send(.updateLocation(
            countryName: node.info.location.country,
            moniker: node.info.moniker)
        )
        
        eventSubject.send(.updateBandwidth(bandwidth: node.info.bandwidth))
    }
    
    /// Refreshes subscriptions. Should be called each time when the app leaves the background state.
    func refreshNodeState() {
        guard subscription != nil else {
            return
        }
        refreshSubscriptions()
    }
    
    /// Should be called each time when the view appears
    func checkNodeForUpdate() {
        guard let lastSelectedNodeAddress = context.connectionInfoStorage.lastSelectedNode(),
              context.connectionInfoStorage.shouldConnect() else {
            return
        }
        
        if let lastSelectedPlandId = context.connectionInfoStorage.lastSelectedPlanId() {
            self.subscriptionType = .plan((nodeAddress: lastSelectedNodeAddress, planId: lastSelectedPlandId))
        } else {
            self.subscriptionType = .node(lastSelectedNodeAddress)
        }
        
        context.connectionInfoStorage.set(shouldConnect: false)

        eventSubject.send(.setButton(isLoading: true))

        context.sentinelService.queryNodeStatus(
            address: lastSelectedNodeAddress,
            timeout: constants.timeout
        ) { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .failure(let error):
                log.error(error)
                self.show(error: ConnectionModelError.nodeIsOffline)
            case .success(let sentinelNode):
                guard let _ = sentinelNode.node else {
                    log.error("Loaded sentinelNode do not contain node")
                    return
                }
                
                self.eventSubject.send(.setButton(isLoading: true))
                self.loadSubscriptions(reconnect: true)
                self.context.connectionInfoStorage.set(lastSelectedNode: lastSelectedNodeAddress)
            }
        }
    }
    
    /// Should be called each time when we turn toggle to "on" state
    func connect() {
        guard let subscription = subscription else {
            eventSubject.send(.warning(ConnectionModelError.nodeIsOffline))
            return
        }
        eventSubject.send(.setButton(isLoading: true))
        
        detectConnectionAndHandle(considerStatus: false, reconnect: true, subscription: subscription)
    }
    
    /// Should be called each time when we turn toggle to "off" state
    func disconnect() {
        guard let tunnel = context.tunnelManager.lastTunnel, tunnel.status != .disconnected else {
            setTunnelActivity()
            return
        }

        eventSubject.send(.setButton(isLoading: true))
        context.tunnelManager.startDeactivation(of: tunnel)
    }
}

// MARK: - Subscriprion

extension ConnectionModel {
    /// Returns false if no quota
    private func checkQuotaAndSubscription(hasQuota: Bool) -> Bool {
        guard hasQuota, subscription?.isActive ?? false else {
            guard let subscriptionType = subscriptionType else {
                return false
            }
            
            switch subscriptionType {
            case .node:
                guard let selectedNode = selectedNode else {
                    return false
                }
                eventSubject.send(.openSubscription(for: selectedNode))
            case .plan:
                #warning("TODO: no quota, resubscribe to plan")
            }
            
            eventSubject.send(.updateConnection(status: .disconnected))
            eventSubject.send(.setButton(isLoading: false))
            return false
        }
        
        return true
    }
    
    private func refreshSubscriptions() {
        eventSubject.send(.setButton(isLoading: true))

        loadSubscriptions()
    }

    private func loadSubscriptions(reconnect: Bool = false) {
        context.sentinelService.fetchSubscriptions { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.show(error: error)

            case .success(let subscriptions):
                guard let subscriptionType = self.subscriptionType else {
                    self.connectToLastSubscription(from: subscriptions, reconnect: reconnect)
                    return
                }
                
                switch subscriptionType {
                case let .node(nodeAddress):
                    guard let subscription = subscriptions.last(where: { $0.node == nodeAddress }) else {
                        self.connectToLastSubscription(from: subscriptions, reconnect: reconnect)
                        return
                    }
                    // connect to node
                    self.subscription = subscription
                    self.handleConnection(reconnect: reconnect)
                case let .plan((_, planId)):
                    guard let subscription = subscriptions.last(where: { $0.plan == planId }) else {
                        self.connectToLastSubscription(from: subscriptions, reconnect: reconnect)
                        return
                    }
                    // connect to plan
                    self.subscription = subscription
                    self.handleConnection(reconnect: reconnect)
                }
            }
        }
    }
    
    private func connectToLastSubscription(
        from subscriptions: [SentinelWallet.Subscription],
        reconnect: Bool
    ) {
        // connect to last user subscription
        self.subscription = subscriptions.sorted(by: { $0.id > $1.id }).first
        
        guard let subscription = subscription else {
            show(error: ConnectionModelError.emptySubscriptions)
            return
        }
        
        if subscription.plan != 0 {
            #warning("TODO: set subscriptionType")
        } else {
            self.subscriptionType = .node(subscription.node)
        }
        
        self.handleConnection(reconnect: reconnect)
    }

    private func handleConnection(reconnect: Bool) {
        guard let subscription = subscription else {
            if context.tunnelManager.startDeactivationOfActiveTunnel() != true {
                stopLoading()
                setTunnelActivity()
            }
            return
        }
        
        if reconnect {
            detectConnectionAndHandle(reconnect: reconnect, subscription: subscription)
        } else {
            update(subscriptionInfo: subscription)
        }
    }

    private func update(subscriptionInfo: SentinelWallet.Subscription, status: ConnectionStatus? = nil) {
        if let status = status {
            eventSubject.send(.updateConnection(status: status))
        }
        
        context.sentinelService.queryQuota(subscriptionID: subscriptionInfo.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.show(error: error)

            case .success(let quota):
                guard self.update(quota: quota) else {
                    return
                }
                self.setTunnelActivity()
                self.stopLoading()
            }
        }
        
        updateLocation()
    }

    private func connect(to subscription: SentinelWallet.Subscription) {
        eventSubject.send(.updateConnection(status: .subscriptionStatus))
        context.sentinelService.queryQuota(subscriptionID: subscription.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.show(error: error)

            case let .success(quota):
                guard self.update(quota: quota) else {
                    return
                }
                self.eventSubject.send(.updateConnection(status: .nodeStatus))
                
                guard let nodeAddress = self.subscriptionType?.nodeAddress else {
                    return
                }
                
                self.context.sentinelService.queryNodeStatus(
                    address: nodeAddress,
                    timeout: constants.timeout
                ) { [weak self] result in
                    switch result {
                    case .failure(let error):
                        log.error(error)
                        self?.show(error: ConnectionModelError.nodeIsOffline)
                    case .success(let node):
                        self?.createNewSession(subscription: subscription, nodeURL: node.remoteURL)
                    }
                }
            }
        }
    }
    
    private func update(quota: Quota) -> Bool {
        let initialBandwidth = quota.allocated
        let bandwidthConsumed = quota.consumed
        
        self.eventSubject.send(
            .updateSubscription(
                initialBandwidth: initialBandwidth,
                bandwidthConsumed: bandwidthConsumed
            )
        )
        
        let bandwidthLeft = (Int64(initialBandwidth) ?? 0) - (Int64(bandwidthConsumed) ?? 0)
        
        return checkQuotaAndSubscription(hasQuota: bandwidthLeft != 0)
    }

    private func updateLocation() {
        guard let subscriptionType = self.subscriptionType else {
            return
        }
        
        let address = subscriptionType.nodeAddress
        
        context.sentinelService.queryNodeStatus(address: address, timeout: constants.timeout) { [weak self] response in
            switch response {
            case .failure(let error):
                guard self?.subscription != nil else {
                    return
                }
                log.error(error)
                self?.show(error: ConnectionModelError.nodeIsOffline)
            case .success(let sentinelNode):
                self?.selectedNode = sentinelNode.node?.info
                
                guard let node = sentinelNode.node else {
                    log.error("Loaded sentinelNode do not contain node")
                    return
                }
                
                self?.eventSubject.send(
                    .updateLocation(countryName: node.info.location.country,
                                    moniker: node.info.moniker)
                )
                self?.eventSubject.send(
                    .updateBandwidth(bandwidth: node.info.bandwidth)
                )
            }
        }
    }

    private func createNewSession(subscription: SentinelWallet.Subscription, nodeURL: String) {
        eventSubject.send(.updateConnection(status: .balanceCheck))
        context.walletService.fetchBalance { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                log.debug("Failed to fetch a balance due to \(error). Try to start a session anyway.")
                self.startSession(on: subscription, nodeURL: nodeURL)

            case .success(let balances):
                guard balances
                        .contains(
                            where: { $0.denom == constants.denom
                                && Int($0.amount) ?? 0 >= self.context.walletService.fee }
                        ) else {
                    self.eventSubject.send(.warning(ConnectionModelError.notEnoughTokens))
                    self.stopLoading()
                    return
                }
                self.startSession(on: subscription, nodeURL: nodeURL)
            }
        }
    }

    private func startSession(on subscription: SentinelWallet.Subscription, nodeURL: String) {
        eventSubject.send(.updateConnection(status: .sessionBroadcast))
        
        guard let nodeAddress = self.subscriptionType?.nodeAddress else {
            return
        }
        
        context.sentinelService.startNewSession(on: subscription.id, nodeAddress: nodeAddress) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.set(sessionStart: nil)
                self.show(error: error)
                self.stopLoading()
            case .success(let id):
                self.set(sessionStart: Date())
                self.fetchConnectionData(remoteURLString: nodeURL, id: id)
            }
        }
    }
    
    private func detectConnectionAndHandle(
        considerStatus: Bool = true,
        reconnect: Bool,
        subscription: SentinelWallet.Subscription
    ) {
        detectConnection { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                log.error(error)
                if reconnect {
                    self.connect(to: subscription)
                }
                
            case let .success((isTunnelActive, isSessionActive)):
                switch (isTunnelActive, isSessionActive) {
                case (true, true):
                    self.getInitialSessionStart()
                    self.update(subscriptionInfo: subscription, status: .connected)
                case (false, true):
                    self.getInitialSessionStart()
                    if let tunnel = self.context.tunnelManager.lastTunnel {
                        self.context.tunnelManager.startActivation(of: tunnel)
                        self.update(subscriptionInfo: subscription, status: .connected)
                    } else {
                        self.connect(to: subscription)
                        self.updateLocation()
                    }
                case (true, false), (false, false):
                    self.connect(to: subscription)
                    self.updateLocation()
                }
            }
        }
    }
    
    /// Checks if tunnel and session are active
    private func detectConnection(
        considerStatus: Bool = true,
        completion: @escaping (Result<(Bool, Bool), Error>) -> Void
    ) {
        eventSubject.send(.updateConnection(status: .sessionStatus))
        
        var isTunnelActive: Bool

        if let tunnel = context.tunnelManager.lastTunnel {
            isTunnelActive = true
            
            if considerStatus {
                isTunnelActive = tunnel.status == .connected || tunnel.status == .connecting
            }
        } else {
            isTunnelActive = false
        }
        
        context.sentinelService.loadActiveSession { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let session):
                guard let id = self.context.connectionInfoStorage.lastSessionId(),
                      session.id == id,
                      let node = self.context.connectionInfoStorage.lastSelectedNode(),
                      session.node == node else {
                          completion(.success((isTunnelActive, false)))
                          return
                      }
                
                completion(.success((isTunnelActive, true)))
            }
        }
    }
    
    private func getInitialSessionStart() {
        let sessionStart = context.connectionInfoStorage.lastSessionStart()
        eventSubject.send(.updateTimer(startDate: sessionStart))
    }
    
    private func set(sessionStart: Date?) {
        context.connectionInfoStorage.set(sessionStart: sessionStart)
        eventSubject.send(.updateTimer(startDate: sessionStart))
    }
}

// MARK: - Events

extension ConnectionModel {
    private func stopLoading() {
        eventSubject.send(.updateConnection(status: .init(from: isTunnelActive)))
        eventSubject.send(.setButton(isLoading: false))
    }

    private func show(error: Error) {
        log.error(error)
        stopLoading()
        eventSubject.send(.update(isTunnelActive: isTunnelActive))
        eventSubject.send(.error(error))
    }
}

// MARK: - Network and Wallet work

extension ConnectionModel {
    private func fetchConnectionData(remoteURLString: String, id: UInt64) {
        eventSubject.send(.updateConnection(status: .keysExchange))

        var int = id.bigEndian
        let sessionIdData = Data(bytes: &int, count: 8)

        guard let signature = context.walletService.generateSignature(for: sessionIdData) else {
            show(error: ConnectionModelError.signatureGenerationFailed)
            return
        }

        context.networkService.fetchConnectionData(
            remoteURLString: remoteURLString,
            id: id,
            accountAddress: context.walletService.accountAddress,
            signature: signature
        ) { [weak self] result in
            guard let self = self, let subscriptionType = self.subscriptionType else { return }

            switch result {
            case let .failure(error):
                switch subscriptionType {
                case .node:
                    if error.asAFError?.responseCode == 400, let selectedNode = self.selectedNode {
                        self.eventSubject.send(.resubscribeToNode(selectedNode))
                        self.stopLoading()
                        return
                    }
                    
                    self.show(error: error)
                case let .plan((nodeAddress, planId)):
                    if let afError = error.asAFError, afError.isSessionTaskError {
                        self.eventSubject.send(.resubscribeToPlan(nodeAddress: nodeAddress, planId: planId))
                        self.stopLoading()
                        return
                    }
                    self.show(error: error)
                }
            case let .success((data, wgKey)):
                self.context.connectionInfoStorage.set(sessionId: Int(id))
                self.context.tunnelManager.createNewProfile(
                    from: data,
                    with: wgKey
                )
            }
        }
    }

    private func updateTunnelActivity() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.setTunnelActivity(stopLoading: true)
        }
    }

    private func setTunnelActivity(stopLoading: Bool = false) {
        eventSubject.send(.update(isTunnelActive: self.isTunnelActive))
        
        if stopLoading {
            self.stopLoading()
        }
    }
    
    // MARK: - Wallet
    
    private func fetchWalletInfo() {
        context.walletService.fetchAuthorization { [weak self] error in
            if let error = error {
                if let statusError = error as? GRPC.GRPCStatus, statusError.code == .notFound {
                    return
                }
                self?.show(error: error)
            }
        }

        context.walletService.fetchTendermintNodeInfo { [weak self] result in
            switch result {
            case .success(let info):
                log.debug(info)
            case .failure(let error):
                self?.show(error: error)
            }
        }
    }
}

// MARK: - TunnelManagerDelegate

extension ConnectionModel: TunnelManagerDelegate {
    func handleTunnelUpdatingStatus() {
        eventSubject.send(.updateConnection(status: .tunnelUpdating))
    }

    func handleError(_ error: Error) {
        show(error: error)
    }

    func handleTunnelReconnection() {
        setTunnelActivity(stopLoading: true)
    }
    
    func handleTunnelServiceCreation() {
        refreshSubscriptions()
    }
}

// MARK: - TunnelsServiceStatusDelegate

extension ConnectionModel: TunnelsServiceStatusDelegate {
    func activationAttemptFailed(for tunnel: TunnelContainer, with error: TunnelActivationError) {
        show(error: error)
    }

    func activationAttemptSucceeded(for tunnel: TunnelContainer) {
        log.debug("\(tunnel.name) is succesfully attempted activation")
    }

    func activationFailed(for tunnel: TunnelContainer, with error: TunnelActivationError) {
        show(error: error)
    }

    func activationSucceeded(for tunnel: TunnelContainer) {
        log.debug("\(tunnel.name) is succesfully activated")

        updateTunnelActivity()
    }

    func deactivationSucceeded(for tunnel: TunnelContainer) {
        log.debug("\(tunnel.name) is succesfully deactivated")

        updateTunnelActivity()
    }
}
