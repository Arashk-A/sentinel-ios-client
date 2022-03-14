//
//  SubscribedNodesCoordinator.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 22.11.2021.
//

import UIKit
import SwiftUI
import SwiftMessages

final class SubscribedNodesCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: SubscribedNodesModel.Context

    init(context: SubscribedNodesModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = SubscribedNodesModel(context: context)
        let viewModel = SubscribedNodesViewModel(model: model, router: asRouter())
        let view = SubscribedNodesView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.viewControllers = [controller]

        controller.makeNavigationBar(hidden: false, animated: false)
        controller.title = L10n.SubscribedNodes.title
    }
}

extension SubscribedNodesCoordinator: RouterType {
    func play(event: SubscribedNodesViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case let .details(node, planId, isSubscribed):
            let configuration = NodeDetailsCoordinator.Configuration(
                node: node,
                planId: planId,
                isSubscribed: isSubscribed
            )
            
            ModulesFactory.shared.makeNodeDetailsModule(
                for: navigation,
                configuration: configuration
            )
        case let .info(message):
            show(message: message, theme: .success)
        }
    }
}
