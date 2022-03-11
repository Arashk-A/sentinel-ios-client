//
//  NodeDetailsModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import Combine
import SentinelWallet

enum NodeDetailsModelEvent {
    case update(node: SentinelNode)
    case error(Error)
}

final class NodeDetailsModel {
    typealias Context = HasConnectionInfoStorage
    private let context: Context

    private let eventSubject = PassthroughSubject<NodeDetailsModelEvent, Never>()
    var eventPublisher: AnyPublisher<NodeDetailsModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    struct Configuration {
        let node: SentinelNode
        let planId: UInt64?
        let isSubscribed: Bool
    }
    
    private let configuration: Configuration

    init(context: Context, configuration: Configuration) {
        self.context = context
        self.configuration = configuration
    }
}

extension NodeDetailsModel {
    func setNode() {
        eventSubject.send(.update(node: configuration.node))
    }
    
    func save(nodeAddress: String) {
        context.connectionInfoStorage.set(lastSelectedNode: nodeAddress)
        context.connectionInfoStorage.set(lastSelectedPlanId: configuration.planId)
        context.connectionInfoStorage.set(shouldConnect: true)
    }
    
    var isSubscribed: Bool {
        configuration.isSubscribed
    }

    var connectionAllowed: Bool {
        !(configuration.planId != nil && !isSubscribed)
    }
}
