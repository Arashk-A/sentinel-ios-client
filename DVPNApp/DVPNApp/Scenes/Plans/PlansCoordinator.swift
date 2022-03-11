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
        switch event {
        case .error(let error):
            show(message: error.localizedDescription)
        }
    }
}
