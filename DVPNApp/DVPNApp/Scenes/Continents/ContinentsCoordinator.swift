//
//  ContinentsCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 03.10.2021.
//

import UIKit
import SwiftUI
import SwiftMessages

final class ContinentsCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: ContinentsModel.Context

    init(context: ContinentsModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = ContinentsModel(context: context)
        let viewModel = ContinentsViewModel(model: model, router: asRouter())
        let view = ContinentsView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.viewControllers = [controller]

        controller.makeNavigationBar(hidden: false, animated: false)
        controller.title = L10n.Continents.title
    }
}

extension ContinentsCoordinator: RouterType {
    func play(event: ContinentsViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case .connect:
            ModulesFactory.shared.makeConnectionModule(for: navigation)
        case let .subscribe(node, delegate):
            ModulesFactory.shared.makeNodeSubscriptionModule(node: node, delegate: delegate, for: navigation)
        case let .openNodes(continent, delegate):
            ModulesFactory.shared.makeAvailableNodesModule(
                continent: continent, delegate: delegate, for: navigation
            )
        }
    }
}
