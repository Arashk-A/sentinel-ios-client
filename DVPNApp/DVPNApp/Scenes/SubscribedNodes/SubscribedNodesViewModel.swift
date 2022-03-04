//
//  SubscribedNodesViewModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 22.11.2021.
//

import Foundation
import FlagKit
import SentinelWallet
import Combine
import UIKit.UIImage
import NetworkExtension
import SwiftUI

enum SubscribedNodesViewModelError: LocalizedError {
    case unavailableNode

    var errorDescription: String? {
        switch self {
        case .unavailableNode:
            return L10n.Error.unavailableNode
        }
    }
}

final class SubscribedNodesViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case details(SentinelNode, isSubscribed: Bool)
    }
    
    @Published private(set) var subscriptions: [NodeSelectionRowViewModel] = []
    private(set) var nodes: Set<SentinelNode> = []
    
    private let model: SubscribedNodesModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoadingSubscriptions: Bool = true

    private var statusObservationToken: NotificationToken?
    
    @Published private(set) var subscriptionsState: SubscriptionsState = .empty
    
    @Published var alertContent: (isShown: Bool, alert: Alert) = (
        false,
        Alert(title: Text(""), message: nil, dismissButton: nil)
    )

    init(model: SubscribedNodesModel, router: Router) {
        self.model = model
        self.router = router

        handeEvents()
        
        model.subscribeToEvents()
        model.setNodes()
    }
}

extension SubscribedNodesViewModel {
    func refresh() {
        model.loadSubscriptions()
    }
}

// MARK: - Buttons actions

extension SubscribedNodesViewModel {
    func openDetails(for id: String) {
        UIImpactFeedbackGenerator.lightFeedback()
        
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address ?? "" == id }),
              let _ = sentinelNode.node else {
                  router.play(event: .error(NodeError.unavailableNode))
                  return
              }
        
        router.play(event: .details(sentinelNode, isSubscribed: true))
    }
    
    func delete(at offsets: IndexSet) {
        if let index = offsets.first {
            let node = subscriptions[index].node
            
            showCancelSubscriptionAlert(node: node) { [weak self] in
                self?.model.cancelSubscriptions(for: node)
            }
        }
    }
}

extension SubscribedNodesViewModel {
    private func handeEvents() {
        model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.router.play(event: .error(error))
                case let .update(nodes):
                    self?.nodes.formUnion(nodes)
                case let .showLoadingSubscriptions(state):
                    self?.isLoadingSubscriptions = state
                case let .set(subscribedNodes):
                    self?.set(subscribedNodes: subscribedNodes)
                case let .setSubscriptionsState(state):
                    self?.subscriptionsState = state
                case .reloadSubscriptions:
                    self?.subscriptions = []
                    self?.isLoadingSubscriptions = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func set(subscribedNodes: [SentinelNode]) {
        subscribedNodes.forEach { subscribedNode in
            nodes.insert(subscribedNode)
            
            guard let node = subscribedNode.node else { return }
            
            let countryCode = CountryFormatter.code(for: node.info.location.country) ?? ""

            let model = NodeSelectionRowViewModel(
                from: node,
                icon: Flag(countryCode: countryCode)?.image(style: .roundedRect) ?? Asset.Tokens.dvpn.image
            )
            
            if !subscriptions.contains(where: { $0.id == model.id }) {
                subscriptions.append(model)
            }
        }
    }
    
    private func showCancelSubscriptionAlert(node: Node, completion: @escaping () -> Void) {
        let completion = { [weak self] in
            guard let self = self else { return }
            
            self.model.cancelSubscriptions(for: node)
        }
        
        alertContent = (
            true,
            Alert(
                title: Text( L10n.SubscribedNodes.CancelSubscription.title(node.info.moniker)),
                primaryButton: .default(
                    Text(L10n.Common.yes),
                    action: completion
                ),
                secondaryButton: .destructive(
                    Text(L10n.Common.cancel),
                    action: {}
                )
            )
        )
    }
}
