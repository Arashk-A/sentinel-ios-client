//
//  HomeModel.swift
//  Test
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import Foundation
import Combine
import SentinelWallet

enum SubscriptionsState {
    case empty
    case noConnection
    
    var title: String {
        switch self {
        case .empty:
            return L10n.Home.Node.Subscribed.notFound
        case .noConnection:
            return L10n.Home.Node.Subscribed.noConnection
        }
    }
}

enum HomeModelEvent {
    case error(Error)
    
    case showLoadingSubscriptions(state: Bool)
    
    case update(locations: [SentinelNode])
    case set(subscribedNodes: [SentinelNode])
    case setSubscriptionsState(SubscriptionsState)
    case reloadSubscriptions

    case connect

    case select(server: DNSServerType)
    case setNumberOfNodesInContinent
}

final class HomeModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage
        & HasDNSServersStorage & HasTunnelManager & HasNodesService
    private let context: Context

    private let eventSubject = PassthroughSubject<HomeModelEvent, Never>()
    var eventPublisher: AnyPublisher<HomeModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private var subscriptions: [SentinelWallet.Subscription] = []
    private var reloadOnNextAppear = false
    
    private var cancellables = Set<AnyCancellable>()

    init(context: Context) {
        self.context = context

        loadSubscriptions()
        fetchWalletInfo()
        
        context.nodesService.loadAllNodesIfNeeded { result in
            if case let .success(nodes) = result {
                context.nodesService.loadNodesInfo(for: nodes)
            }
        }
        
        context.nodesService.isAllLoaded
            .sink(receiveValue: { [weak self] isAllLoaded in
                if isAllLoaded {
                    self?.eventSubject.send(.setNumberOfNodesInContinent)
                }
            }).store(in: &cancellables)
    }
}

extension HomeModel {
    func subscribeToEvents() {
        context.nodesService.isLoadingSubscriptions
            .map { .showLoadingSubscriptions(state: $0) }
            .subscribe(eventSubject)
            .store(in: &cancellables)
        
        context.nodesService.subscribedNodes
            .map { .set(subscribedNodes: $0) }
            .subscribe(eventSubject)
            .store(in: &cancellables)
    }
    
    var numberOfNodesInContinent: [Continent: Int] {
        context.nodesService.nodesInContinentsCount
    }
    
    func refreshDNS() {
        eventSubject.send(.select(server: context.dnsServersStorage.selectedDNS()))
    }

    func setNodes() {
        eventSubject.send(.update(locations: context.nodesService.nodes))
    }

    func save(nodeAddress: String) {
        context.connectionInfoStorage.set(lastSelectedNode: nodeAddress)
        context.connectionInfoStorage.set(shouldConnect: true)
        eventSubject.send(.connect)
    }

    func isSubscribed(to node: String) -> Bool {
        subscriptions.contains(where: { $0.node == node })
    }

    func connectIfNeeded() {
        if context.connectionInfoStorage.shouldConnect() {
            eventSubject.send(.connect)
            reloadOnNextAppear = true
        }

        if reloadOnNextAppear {
            eventSubject.send(.reloadSubscriptions)
            loadSubscriptions()
            
            reloadOnNextAppear = false
        }
    }

    func disconnect() {
        context.tunnelManager.startDeactivationOfActiveTunnel()
    }
}

// MARK: - Private Methods

extension HomeModel {
    private func show(error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
    }
    
    private func loadSubscriptions() {
        context.nodesService.loadSubscriptions { [weak self] result in
            switch result {
            case let .success(subscriptions):
                self?.subscriptions = subscriptions
            case .failure:
                self?.eventSubject.send(.setSubscriptionsState(.noConnection))
            }
        }
    }

    private func fetchWalletInfo() {
        context.walletService.fetchAuthorization { error in
            guard let error = error else {
                return
            }

            log.error(error)
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
