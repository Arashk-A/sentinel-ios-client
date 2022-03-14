//
//  PlansCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 09.03.2022.
//

import UIKit
import SwiftUI
import SentinelWallet


final class PlansCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: PlansModel.Context

    init(context: PlansModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = PlansModel(context: context)
        let viewModel = PlansViewModel(model: model, router: asRouter())
        let view = PlansView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.pushViewController(controller, animated: true)
        controller.makeNavigationBar(hidden: false, animated: false)
        controller.title = L10n.Plans.title
    }
}

extension PlansCoordinator: RouterType {
    func play(event: PlansViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case let .open(plan, isSubscribed):
            ModulesFactory.shared.makePlanNodesModule(plan: plan, isSubscribed: isSubscribed, for: navigation)
        }
    }
}
