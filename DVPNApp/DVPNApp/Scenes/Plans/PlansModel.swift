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
    typealias Context = HasSentinelService
    private let context: Context

    private let eventSubject = PassthroughSubject<PlansModelEvent, Never>()
    var eventPublisher: AnyPublisher<PlansModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init(context: Context) {
        self.context = context
    }

    func refresh() {
        context.sentinelService.queryPlans(for: constants.providerAddress) { [weak self] result in
            switch result {
            case let .failure(error):
                self?.eventSubject.send(.error(error))
            case let .success(plans):
                log.debug("+++ \(plans)")
                self?.eventSubject.send(.plans(plans))
            }
        }
    }
}
