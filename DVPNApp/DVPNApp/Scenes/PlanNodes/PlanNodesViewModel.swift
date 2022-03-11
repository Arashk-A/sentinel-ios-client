//
//  PlanNodesViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 09.03.2022.
//

import Foundation
import FlagKit
import SentinelWallet
import Combine
import UIKit

final class PlanNodesViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case connect
        case details(SentinelNode, isSubscribed: Bool)
    }

    @Published private(set) var locations: [NodeSelectionRowViewModel] = []
    
    private(set) var nodes: [SentinelNode] = []
    private(set) var loadedNodesCount: Int = 0
    
    private let model: PlanNodesModel
    private var cancellables = Set<AnyCancellable>()

    @Published var isLoadingNodes: Bool = true

    private let plan: SentinelPlan

    init(plan: SentinelPlan, model: PlanNodesModel, router: Router) {
        self.plan = plan
        self.model = model
        self.router = router

        handeEvents()

        model.loadNodes()
    }
}

// MARK: - Buttons actions

extension PlanNodesViewModel {
    func openDetails(for id: String) {
        UIImpactFeedbackGenerator.lightFeedback()
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address == id }) else {
            router.play(event: .error(NodeError.unavailableNode))
            return
        }
        
        router.play(
            event: .details(sentinelNode, isSubscribed: model.isSubscribed)
        )
    }
}

// MARK: - Private

extension PlanNodesViewModel {
    private func handeEvents() {
        model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.router.play(event: .error(error))
                case let .update(nodes):
                    self?.update(to: nodes)
                case .connect:
                    self?.router.play(event: .connect)
                }
            }
            .store(in: &cancellables)
    }

    private func update(to nodes: [SentinelNode]) {
        let locations = nodes.map { sentinelNode -> NodeSelectionRowViewModel? in
            guard let node = sentinelNode.node else {
                return nil
            }
            
            let countryCode = CountryFormatter.code(for: node.info.location.country) ?? ""

            return NodeSelectionRowViewModel(
                from: node,
                icon: Flag(countryCode: countryCode)?.image(style: .roundedRect) ?? Asset.Tokens.dvpn.image
            )
        }.compactMap { $0 }
        
        self.locations = locations
        self.nodes = nodes
        isLoadingNodes = false
    }
}
