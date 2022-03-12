//
//  ConnectionCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.08.2021.
//

import UIKit
import SwiftUI
import SentinelWallet
import SwiftMessages

final class ConnectionCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: ConnectionModel.Context

    init(context: ConnectionModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let homeModel = ConnectionModel(context: context)
        let homeViewModel = ConnectionViewModel(model: homeModel, router: asRouter())
        let homeView = ConnectionView(viewModel: homeViewModel)
        let controller = UIHostingController(rootView: homeView)
        controller.hidesBottomBarWhenPushed = true
        rootController = controller
        navigation?.pushViewController(controller, animated: true)

        controller.makeNavigationBar(hidden: false, animated: false)
        controller.title = L10n.Connection.title
    }
}

extension ConnectionCoordinator: RouterType {
    func play(event: ConnectionViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case .error(let error):
            show(message: error.localizedDescription)
        case .warning(let error):
            show(message: error.localizedDescription, theme: .warning)
        case let .openSubscription(node, delegate):
            ModulesFactory.shared.makeNodeSubscriptionModule(node: node, delegate: delegate, for: navigation)
        case let .dismiss(isEnabled):
            setBackNavigationEnability(isEnabled: isEnabled)
        case let .alert(title, message, completion):
            showAlert(
                title: title,
                message: message,
                on: rootController,
                completion: completion
            )
        }
    }
}

// MARK: - Private

extension ConnectionCoordinator {
    private func setBackNavigationEnability(isEnabled: Bool) {
        navigation?.interactivePopGestureRecognizer?.isEnabled = isEnabled
        navigation?.navigationBar.isUserInteractionEnabled = isEnabled
        navigation?.navigationBar.tintColor = isEnabled ? .white : .gray
    }
}
