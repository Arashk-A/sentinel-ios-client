//
//  PlanNodesModel.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 09.03.2022.
//

import Foundation
import Combine
import SentinelWallet

enum PlanNodesModelEvent {
    case error(Error)    
    case update(locations: [SentinelNode])
    case connect
    case addTokens
    case changeState(isSubscribed: Bool)
}

final class PlanNodesModel {
    typealias Context = HasNodesService & HasWalletService & HasSentinelService
    private let context: Context
    private let plan: SentinelPlan
    private var isSubscribed: Bool

    private var subscriptions: [SentinelWallet.Subscription] = []

    private let eventSubject = PassthroughSubject<PlanNodesModelEvent, Never>()
    var eventPublisher: AnyPublisher<PlanNodesModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()

    init(context: Context, plan: SentinelPlan, isSubscribed: Bool) {
        self.context = context
        self.plan = plan
        self.isSubscribed = isSubscribed

        subscribeToEvents()
    }
}

extension PlanNodesModel {
    func loadNodes() {
        context.nodesService.loadNodesInfo(for: plan.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.eventSubject.send(.error(error))
            case .success(let nodes):
                self.eventSubject.send(.update(locations: nodes))
            }
        }
    }

    func checkBalanceAndSubscribe() {
        context.walletService.fetchBalance { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.eventSubject.send(.error(error))
            case .success(let balances):
                let balance = balances.first(where: { $0.denom == self.plan.price[0].denom })

                guard let balance = balance,
                      Int(balance.amount) ?? 0 >= (Int(self.plan.price[0].amount) ?? 0 + self.context.walletService.fee) else {
                    self.eventSubject.send(.addTokens)
                    return
                }

                self.subscribe(to: self.plan)
            }
        }
    }

    func cancelSubscription() {
        let subscriptionsToCancel = subscriptions
            .filter { $0.plan == plan.id }
            .map { $0.id }

        context.sentinelService.cancel(
            subscriptions: subscriptionsToCancel,
            node: plan.provider
        ) { [weak self] result in
                log.debug(result)

                switch result {
                case let .failure(error):
                    self?.show(error: error)
                case let .success(result):
                    switch result.isSuccess {
                    case true:
                        self?.changeSubscriptionState(to: false)
                    case false:
                        self?.show(error: SubscribedNodesModelError.faliToCancelSubscription)
                    }
                }
            }
    }
}

// MARK: - Private Methods

extension PlanNodesModel {
    private func show(error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
    }

    private func subscribeToEvents() {
        context.nodesService.subscriptions
            .sink(receiveValue: { [weak self] subscriptions in
                self?.subscriptions = subscriptions
            })
            .store(in: &cancellables)
    }

    private func subscribe(to plan: SentinelPlan) {
        context.sentinelService.subscribe(
            to: plan.id,
            provider: plan.provider,
            denom: plan.price[0].denom
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.eventSubject.send(.error(error))
            case .success(let response):
                guard response.isSuccess else {
                    self.eventSubject.send(.error(NodeSubscriptionModelError.paymentFailed))
                    return
                }

                self.changeSubscriptionState(to: true)
            }
        }
    }

    private func changeSubscriptionState(to isSubscribed: Bool) {
        context.nodesService.loadActiveSubscriptions(completion: { _ in })
        self.isSubscribed = isSubscribed
        eventSubject.send(.changeState(isSubscribed: isSubscribed))
    }
}
