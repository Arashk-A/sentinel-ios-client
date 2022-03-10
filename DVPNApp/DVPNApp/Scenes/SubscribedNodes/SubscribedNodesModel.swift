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

enum SubscribedNodesModelError: LocalizedError {
    case faliToCancelSubscription
    case newSubscription

    var errorDescription: String? {
        switch self {
        case .faliToCancelSubscription:
            return L10n.SubscribedNodes.Error.subscriptionCancellationFailed
        case .newSubscription:
            return L10n.SubscribedNodes.Error.newSubscription
        }
    }
}

enum SubscribedNodesModelEvent {
    case error(Error)
    
    case showLoadingSubscriptions(state: Bool)
    
    case update(locations: [SentinelNode])
    case set(subscribedNodes: [SentinelNode])
    case resetSubscribedNodes
    case setSubscriptionsState(SubscriptionsState)
    
    case info(String)
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
        
        context.nodesService.subscriptions
            .sink(receiveValue: { [weak self] subscriptions in
                self?.subscriptions = subscriptions
            }).store(in: &cancellables)
    }
    
    func setNodes() {
        eventSubject.send(.update(locations: context.nodesService.nodes))
    }
    
    func loadSubscriptions() {
        context.nodesService.loadActiveSubscriptions { [weak self] result in
            switch result {
            case .success:
                return
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
                log.debug(result)

                switch result {
                case let .failure(error):
                    self?.handleCancellationFailure(with: error)
                case let .success(result):
                    switch result.isSuccess {
                    case true:
                        self?.handleCancellation(node: node)
                    case false:
                        // It seems we get this messages usually for new subscriptions
                        if result.rawLog.contains("can not cancel") {
                            self?.handleCancellationFailure(with: SubscribedNodesModelError.newSubscription)
                            return
                        }
                        
                        self?.handleCancellationFailure(with: SubscribedNodesModelError.faliToCancelSubscription)
                    }
                }
            }
    }
}

// MARK: - Private
 
extension SubscribedNodesModel {
    private func handleCancellation(node: Node) {
        eventSubject.send(.resetSubscribedNodes)
        eventSubject.send(.info(L10n.SubscribedNodes.subscriptionCanceled(node.info.moniker)))

        loadSubscriptions()
    }
    
    private func handleCancellationFailure(with error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
        eventSubject.send(.showLoadingSubscriptions(state: false))
    }
}
