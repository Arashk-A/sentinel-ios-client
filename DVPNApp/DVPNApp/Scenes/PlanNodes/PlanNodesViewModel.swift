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
        case info(String)
        case alert(title: String, message: String?, completion: (Bool) -> Void)
        case connect
        case details(SentinelNode, isSubscribed: Bool)
        case accountInfo
    }

    @Published private(set) var locations: [NodeSelectionRowViewModel] = []
    
    private(set) var nodes: [SentinelNode] = []
    
    private let model: PlanNodesModel
    private var cancellables = Set<AnyCancellable>()

    @Published var isLoadingNodes: Bool = true
    @Published var isLoading: Bool = false
    @Published var isSubscribed: Bool
    private let plan: SentinelPlan

    init(plan: SentinelPlan, isSubscribed: Bool, model: PlanNodesModel, router: Router) {
        self.plan = plan
        self.isSubscribed = isSubscribed
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
            event: .details(sentinelNode, isSubscribed: isSubscribed)
        )
    }

    func didTapMainButton() {
        UIImpactFeedbackGenerator.lightFeedback()
        isSubscribed ? didTapCancelSubscription() : didTapSubscribe()
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
                case .addTokens:
                    self?.showAddTokens()
                case let .changeState(isSubscribed):
                    self?.changeSubscription(to: isSubscribed)
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

    private func changeSubscription(to state: Bool) {
        isLoading = false
        isSubscribed = state
        router.play(event: .info(state ? L10n.Plans.Info.subscribed : L10n.Plans.Info.unsubscribed))
    }

    private func didTapSubscribe() {
        router.play(
            event: .alert(
                title: L10n.Plans.Subscribe.title("plan #\(plan.id)"),
                message: nil
            ) { [weak self] result in
                guard let self = self, result else {
                    return
                }
                self.isLoading = true
                self.model.checkBalanceAndSubscribe()
            }
        )
    }

    private func didTapCancelSubscription() {
        router.play(
            event: .alert(
                title: L10n.SubscribedNodes.CancelSubscription.title("plan #\(plan.id)"),
                message: nil
            ) { [weak self] result in
                guard let self = self, result else {
                    return
                }
                self.isLoading = true
                self.model.cancelSubscription()
            }
        )
    }

    private func showAddTokens() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(
            event: .alert(
                title: L10n.Plans.AddTokens.title,
                message: L10n.Plans.AddTokens.subtitle
            ) { [weak self] result in
                self?.isLoading = false
                guard result else { return }
                self?.router.play(event: .accountInfo)
            }
        )
    }
}
