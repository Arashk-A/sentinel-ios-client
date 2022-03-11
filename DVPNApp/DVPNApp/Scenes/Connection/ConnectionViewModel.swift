import Combine
import SentinelWallet
import SwiftUI
import FlagKit
import GRPC

final class ConnectionViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router
    
    @Published private(set) var bandwidthConsumedGB: String?
    
    @Published private(set) var downloadSpeed: String?
    @Published private(set) var downloadSpeedUnits: String?
    @Published private(set) var uploadSpeed: String?
    @Published private(set) var uploadSpeedUnits: String?
    
    @Published private(set) var initialBandwidthGB: String?
    @Published private(set) var duration: String?
    
    // Location Selector
    @Published private(set) var countryImage: UIImage?
    @Published private(set) var countryName: String?
    @Published private(set) var moniker: String?
    @Published private(set) var speedImage: UIImage?
    
    // Connection Status
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected

    @Published var isLoading: Bool = false

    enum Route {
        case error(Error)
        case warning(Error)
        case openSubscription(for: DVPNNodeInfo, delegate: NodeSubscriptionViewModelDelegate?)
        case dismiss(isEnabled: Bool)
        case resubscribeToNode(completion: (Bool) -> Void)
        case resubscribeToPlan(completion: (Bool) -> Void)
    }
    
    private let model: ConnectionModel
    private var cancellables = Set<AnyCancellable>()
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    
    init(model: ConnectionModel, router: Router) {
        self.model = model
        self.router = router
        
        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .updateConnection(status):
                    self?.updateConnection(status: status)
                    log.info("Status was changed to \(status)")
                case let .update(isTunnelActive):
                    self?.updateConnection(isConnected: isTunnelActive)
                case let .updateLocation(countryName, moniker):
                    self?.updateLocation(countryName: countryName, moniker: moniker)
                case let .updateBandwidth(bandwidth):
                    self?.updateBandwidth(bandwidth: bandwidth)
                case let .updateTimer(initialDate):
                    self?.startDurationTracking(initialDate: initialDate)
                case let .updateSubscription(initialBandwidth, bandwidthConsumed):
                    self?.updateSubscription(
                        initialBandwidth: initialBandwidth,
                        bandwidthConsumed: bandwidthConsumed
                    )
                case let .setButton(isLoading):
                    self?.updateButton(isLoading: isLoading)
                    self?.router.play(event: .dismiss(isEnabled: !isLoading))
                case let .error(error):
                    self?.show(error: error)
                case let .openSubscription(node):
                    router.play(event: .openSubscription(for: node, delegate: self))
                case let .warning(error):
                    router.play(event: .warning(error))
                case let .resubscribeToNode(node):
                    router.play(
                        event: .resubscribeToNode { [weak self] result in
                            guard let self = self, result else {
                                return
                            }
                            
                            router.play(event: .openSubscription(for: node, delegate: self))
                        }
                    )
                case let .resubscribeToPlan(nodeAddress, planId):
                    router.play(
                        event: .resubscribeToPlan { [weak self] result in
                            guard let self = self, result else {
                                return
                            }
                            
                            #warning("TODO: resubscribe to plan")
                        }
                    )
                }
            }
            .store(in: &cancellables)
        
        model.setInitNodeInfo()
    }
    
    deinit {
        timer?.upstream.connect().cancel()
    }
    
    func viewWillAppear() {
        model.checkNodeForUpdate()
    }
}

extension ConnectionViewModel {
    func toggleConnection() {
        UIImpactFeedbackGenerator.lightFeedback()
        !isConnected ? model.connect() : model.disconnect()
    }

    func didEnterForeground() {
        model.refreshNodeState()
    }
}

// MARK: - NodeSubscriptionViewModelDelegate

extension ConnectionViewModel: NodeSubscriptionViewModelDelegate {
    func openConnection() {
        model.checkNodeForUpdate()
    }
}

// MARK: - Private

extension ConnectionViewModel {
    private func show(error: Error) {
        router.play(event: .error(error))
    }

    private func updateConnection(isConnected: Bool) {
        self.isConnected = isConnected
    }

    private func updateConnection(status: ConnectionStatus) {
        self.connectionStatus = status
        self.isLoading = isLoading || status.isLoading
    }
    
    private func updateLocation(countryName: String, moniker: String) {
        self.countryName = countryName
        self.moniker = moniker
        if let countryCode = CountryFormatter.code(for: countryName),
           let image = Flag(countryCode: countryCode)?.image(style: .roundedRect) {
            self.countryImage = image
        }
    }
    
    private func updateBandwidth(bandwidth: Bandwidth) {
        (downloadSpeed, downloadSpeedUnits) = bandwidth.download.getBandwidthKBorMB
        (uploadSpeed, uploadSpeedUnits) = bandwidth.upload.getBandwidthKBorMB
        speedImage = bandwidth.speedImage
    }

    private func updateButton(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    private func updateSubscription(initialBandwidth: String, bandwidthConsumed: String) {
        self.initialBandwidthGB = (Int64(initialBandwidth) ?? 0).bandwidthGBString
        self.bandwidthConsumedGB = (Int64(bandwidthConsumed) ?? 0).bandwidthGBString
    }
    
    func startDurationTracking(initialDate: Date?) {
        guard let initialDate = initialDate else {
            timer?.upstream.connect().cancel()
            duration = nil
            return
        }
        
        timer?.upstream.connect().cancel()
        
        timer = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
        
        timer?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                let timeToShow = -Int64(initialDate.timeIntervalSinceNow)
                self.duration = timeToShow.secondsAsString()
            }
            .store(in: &cancellables)
    }
}
