//
//  NodeSubscriptionCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.08.2021.
//

import SwiftUI
import SentinelWallet

final class NodeSubscriptionCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: NodeSubscriptionModel.Context
    private let node: DVPNNodeInfo
    private weak var delegate: NodeSubscriptionViewModelDelegate?

    init(
        context: NodeSubscriptionModel.Context,
        navigation: UINavigationController,
        node: DVPNNodeInfo,
        delegate: NodeSubscriptionViewModelDelegate?
    ) {
        self.context = context
        self.navigation = navigation
        self.node = node
        self.delegate = delegate
    }

    func start() {
        let addTokensModel = NodeSubscriptionModel(context: context, node: node)
        let addTokensViewModel = NodeSubscriptionViewModel(model: addTokensModel, router: asRouter(), delegate: delegate)
        let addTokensView = NodeSubscriptionView(viewModel: addTokensViewModel)
        let controller = UIHostingController(rootView: addTokensView)
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen

        rootController = controller

        navigation?.present(controller, animated: false)
    }
}

// MARK: - Handle events

extension NodeSubscriptionCoordinator: RouterType {
    func play(event: NodeSubscriptionViewModel.Route) {
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case let .addTokensAlert(completion: completion):
            showNotEnoughTokensAlert(completion: completion)
        case let .subscribe(node, completion):
            showSubscribeAlert(name: node, completion: completion)
        case .accountInfo:
            navigation?.dismiss(animated: true) { ModulesFactory.shared.switchTo(tab: .account) }
        case .close:
            navigation?.dismiss(animated: true)
        }
    }
}

// MARK: - Private

extension NodeSubscriptionCoordinator {
    private func showSubscribeAlert(
        name: String,
        completion: @escaping (Bool) -> Void
    ) {
        let alert = UIAlertController(
            title: L10n.Plans.Subscribe.title(name),
            message: nil,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: L10n.Common.yes, style: .default) { _ in
            UIImpactFeedbackGenerator.lightFeedback()
            completion(true)
        }

        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .destructive) { _ in
            UIImpactFeedbackGenerator.lightFeedback()
            completion(false)
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        rootController?.present(alert, animated: true, completion: nil)
    }

    private func showNotEnoughTokensAlert(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: L10n.Plans.AddTokens.title,
            message: L10n.Plans.AddTokens.subtitle,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: L10n.Common.yes, style: .default) { _ in
            UIImpactFeedbackGenerator.lightFeedback()
            completion(true)
        }

        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .destructive) { _ in
            UIImpactFeedbackGenerator.lightFeedback()
            completion(false)
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        rootController?.present(alert, animated: true, completion: nil)
    }
}
