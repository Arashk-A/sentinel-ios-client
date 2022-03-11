//
//  PlanNodesCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 09.03.2022.
//

import UIKit
import SwiftUI
import SwiftMessages
import SentinelWallet

final class PlanNodesCoordinator: CoordinatorType {
    private let context: PlanNodesModel.Context
    private weak var navigation: UINavigationController?
    private let plan: SentinelPlan
    private let isSubscribed: Bool

    init(
        context: PlanNodesModel.Context,
        navigation: UINavigationController,
        plan: SentinelPlan,
        isSubscribed: Bool
    ) {
        self.context = context
        self.navigation = navigation
        self.plan = plan
        self.isSubscribed = isSubscribed
    }

    func start() {
        let model = PlanNodesModel(context: context, plan: plan, isSubscribed: isSubscribed)
        let viewModel = PlanNodesViewModel(
            plan: plan,
            isSubscribed: isSubscribed,
            model: model,
            router: asRouter()
        )
        let view = PlanNodesView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        navigation?.pushViewController(controller, animated: true)
        
        controller.makeNavigationBar(hidden: false, animated: false)
        controller.title = L10n.Plans.Nodes.title
        
        let activityIndicator = UIActivityIndicatorView.init(style: .medium)
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        if viewModel.isLoadingNodes {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

// MARK: - Events handling

extension PlanNodesCoordinator: RouterType {
    func play(event: PlanNodesViewModel.Route) {
        guard let navigation = navigation else { return }
        
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case let .info(message):
            show(message: message, theme: .success)
        case .connect:
            ModulesFactory.shared.makeConnectionModule(for: navigation)
        case let .details(node, isSubscribed):
            ModulesFactory.shared.makeNodeDetailsModule(
                for: navigation,
                configuration: .init(node: node, planId: plan.id, isSubscribed: isSubscribed)
            )
        case let .subscribe(plan, completion):
            showSubscribeAlert(name: plan, completion: completion)
        case let .cancelSubscription(plan):
            #warning("TODO cancelSubscription for plan")
        case let .addTokensAlert(completion: completion):
            showNotEnoughTokensAlert(completion: completion)
        case .accountInfo:
            navigation.dismiss(animated: true) { ModulesFactory.shared.switchTo(tab: .account) }
        }
    }
}

extension PlanNodesCoordinator {
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

        navigation?.present(alert, animated: true, completion: nil)
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

        navigation?.present(alert, animated: true, completion: nil)
    }
}
