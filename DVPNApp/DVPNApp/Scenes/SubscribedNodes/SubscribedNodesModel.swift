//
//  SubscribedNodesModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 22.11.2021.
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
            return L10n.SubscribedNodes.notFound
        case .noConnection:
            return L10n.SubscribedNodes.noConnection
        }
    }
}

enum SubscribedNodesModelEvent {
    case error(Error)
    
    case showLoadingSubscriptions(state: Bool)
    
    case update(locations: [SentinelNode])
    case set(subscribedNodes: [SentinelNode])
    case setSubscriptionsState(SubscriptionsState)
    case reloadSubscriptions
}

final class SubscribedNodesModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage
        & HasDNSServersStorage & HasTunnelManager & HasNodesService
    private let context: Context

    private let eventSubject = PassthroughSubject<SubscribedNodesModelEvent, Never>()
    var eventPublisher: AnyPublisher<SubscribedNodesModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private var subscriptions: [SentinelWallet.Subscription] = []
    
    private var cancellables = Set<AnyCancellable>()

    init(context: Context) {
        self.context = context

        loadSubscriptions()
        
        context.nodesService.loadAllNodesIfNeeded { result in
            if case let .success(nodes) = result {
                context.nodesService.loadNodesInfo(for: nodes)
            }
        }
    }
}

extension SubscribedNodesModel {
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
    
    func setNodes() {
        eventSubject.send(.update(locations: context.nodesService.nodes))
    }
    
    func loadSubscriptions() {
        context.nodesService.loadSubscriptions { [weak self] result in
            switch result {
            case let .success(subscriptions):
                self?.subscriptions = subscriptions
            case .failure:
                self?.eventSubject.send(.setSubscriptionsState(.noConnection))
            }
        }
    }
}

extension SubscribedNodesModel {
    func cancelSubscriptions(for node: Node) {
        let subscriptionsToCancel = subscriptions
            .filter { $0.node == node.info.address }
            .map { $0.id }
        
        context.sentinelService.cancel(
            subscriptions: subscriptionsToCancel, node: node.info.address) { [weak self] result in
                switch result {
                case let .failure(error):
                    log.error(error)
                    self?.eventSubject.send(.error(error))
                case .success:
                    self?.loadSubscriptions()
                }
            }
    }
}
