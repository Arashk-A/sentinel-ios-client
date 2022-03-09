//
//  NodeDetailsCoordinator.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import UIKit
import SwiftUI
import SwiftMessages
import SentinelWallet

final class NodeDetailsCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?
    
    typealias Configuration = NodeDetailsModel.Configuration

    private let context: NodeDetailsModel.Context
    private let configuration: Configuration

    init(
        context: NodeDetailsModel.Context,
        navigation: UINavigationController,
        configuration: Configuration
    ) {
        self.context = context
        self.navigation = navigation
        self.configuration = configuration
    }

    func start() {
        let model = NodeDetailsModel(context: context, configuration: configuration)
        let viewModel = NodeDetailsViewModel(model: model, router: asRouter())
        let view = NodeDetailsView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        controller.title = L10n.NodeDetails.title
        
        rootController = controller
        navigation?.pushViewController(controller, animated: true)
        
        controller.makeNavigationBar(hidden: false, animated: false)
    }
}

extension NodeDetailsCoordinator: RouterType {
    func play(event: NodeDetailsViewModel.Route) {
        guard let navigation = navigation else { return }
        
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case let .subscribe(node, delegate):
            ModulesFactory.shared.makeNodeSubscriptionModule(node: node, delegate: delegate, for: navigation)
        case .connect:
            ModulesFactory.shared.makeConnectionModule(for: navigation)
        case .dismiss:
            navigation.popToRootViewController(animated: true)
        }
    }
}
