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
}

final class PlanNodesModel {
    typealias Context = HasNodesService
    private let context: Context
    private let plan: SentinelPlan
    let isSubscribed: Bool

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
}

// MARK: - Private Methods

extension PlanNodesModel {
    private func show(error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
    }
}
