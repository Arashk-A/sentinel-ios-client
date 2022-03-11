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
    private(set) var isSubscribed: Bool

    private let eventSubject = PassthroughSubject<PlanNodesModelEvent, Never>()
    var eventPublisher: AnyPublisher<PlanNodesModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()

    init(context: Context, plan: SentinelPlan, isSubscribed: Bool) {
        self.context = context
        self.plan = plan
        self.isSubscribed = isSubscribed
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
}

// MARK: - Private Methods

extension PlanNodesModel {
    private func show(error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
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

                self.context.nodesService.loadActiveSubscriptions(completion: { _ in })
                self.isSubscribed = true
                self.eventSubject.send(.changeState(isSubscribed: true))
            }
        }
    }
}
