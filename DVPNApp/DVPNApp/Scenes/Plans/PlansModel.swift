//
//  PlansModel.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 09.03.2022.
//

import Foundation
import Foundation
import Combine
import SentinelWallet

private struct Constants {
    let providerAddress = "sentprov1gjkdw8arm54sv7xdhjxnx30lcya4alhfktuxyy"
}

private let constants = Constants()

enum PlansModelEvent {
    case error(Error)
    case plans([SentinelPlan])
}

final class PlansModel {
    typealias Context = HasSentinelService & HasNodesService
    private let context: Context

    private let eventSubject = PassthroughSubject<PlansModelEvent, Never>()
    var eventPublisher: AnyPublisher<PlansModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    private var subscriptions: [SentinelWallet.Subscription] = []

    init(context: Context) {
        self.context = context
        
        context.nodesService.subscriptions
            .sink(receiveValue: { [weak self] subscriptions in
                self?.subscriptions = subscriptions
            })
            .store(in: &cancellables)
    }
}

extension PlansModel {
    func isSubscribed(to plan: UInt64) -> Bool {
        subscriptions.contains(where: { $0.plan == plan })
    }
    
    func refresh() {
        context.sentinelService.queryPlans(for: constants.providerAddress) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                self.eventSubject.send(.error(error))
            case let .success(plans):
                self.context.nodesService.isLoadingSubscriptions
                    .first(where: { !$0 })
                    .sink(receiveValue: { _ in
                        self.eventSubject.send(.plans(plans))
                    })
                    .store(in: &self.cancellables)
            }
        }
    }
}
