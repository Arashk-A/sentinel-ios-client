//
//  AvailableNodesCoordinator.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 18.10.2021.
//

import UIKit
import SwiftUI
import SwiftMessages

final class AvailableNodesCoordinator: CoordinatorType {
    private let context: AvailableNodesModel.Context
    private weak var delegate: NodeSubscriptionViewModelDelegate?
    private weak var navigation: UINavigationController?
    private let continent: Continent

    init(
        context: AvailableNodesModel.Context,
        delegate: NodeSubscriptionViewModelDelegate?,
        navigation: UINavigationController,
        continent: Continent
    ) {
        self.context = context
        self.delegate = delegate
        self.navigation = navigation
        self.continent = continent
    }

    func start() {
        let model = AvailableNodesModel(context: context, continent: continent)
        let viewModel = AvailableNodesViewModel(continent: continent, model: model, router: asRouter())
        let view = AvailableNodesView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        navigation?.pushViewController(controller, animated: true)
        
        controller.makeNavigationBar(hidden: false, animated: false)
        controller.title = continent.title
        
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

extension AvailableNodesCoordinator: RouterType {
    func play(event: AvailableNodesViewModel.Route) {
        guard let navigation = navigation else { return }
        
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case .connect:
            ModulesFactory.shared.makeConnectionModule(for: navigation)
        case let .details(node, isSubscribed):
            ModulesFactory.shared.makeNodeDetailsModule(
                for: navigation,
                   configuration: .init(node: node, planId: nil, isSubscribed: isSubscribed)
            )
        }
    }
}
