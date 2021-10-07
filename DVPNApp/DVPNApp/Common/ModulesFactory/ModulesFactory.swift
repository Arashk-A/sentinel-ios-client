//
//  ModulesFactory.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 17.06.2021.
//

private struct Constants {
    let key = "OnboardingPassed"
}

private let constants = Constants()

import UIKit
import SentinelWallet
import SwiftUI

final class ModulesFactory {
    private(set) static var shared = ModulesFactory()
    private let context: CommonContext

    private init() {
        context = ContextBuilder().buildContext()
    }

    func resetWalletContext() {
        context.resetWalletContext()
    }
}

extension ModulesFactory {
    func detectStartModule(for window: UIWindow) {
        guard context.storage.didPassOnboarding() else {
            makeOnboardingModule(for: window)
            return
        }

        makeLocationSelectionModule(for: window)
    }

    func makeOnboardingModule(for window: UIWindow) {
        let navigation = UINavigationController()
        window.rootViewController = navigation
        navigation.navigationBar.isHidden = true

        OnboardingCoordinator(context: context, navigation: navigation, window: window).start()
    }

    func makeAccountCreationModule(mode: CreationMode, for navigation: UINavigationController, window: UIWindow) {
        AccountCreationCoordinator(context: context, mode: mode, navigation: navigation, window: window).start()
    }

    func makeConnectionModule(for navigation: UINavigationController) {
        ConnectionCoordinator(context: context, navigation: navigation).start()
    }

    func makeLocationSelectionModule(for window: UIWindow) {
        let navigation = UINavigationController()
        window.rootViewController = navigation

        if !context.storage.didPassOnboarding() {
            context.storage.set(didPassOnboarding: true)
        }

        LocationSelectionCoordinator(context: context, navigation: navigation).start()
    }
    
    func makeNodeDetailsModule(for navigation: UINavigationController, configuration: NodeDetailsCoordinator.Configuration) {
        NodeDetailsCoordinator(context: context, navigation: navigation, configuration: configuration).start()
    }

    func makeAccountInfoModule(for navigation: UINavigationController) {
        AccountInfoCoordinator(context: context, navigation: navigation).start()
    }

    func makePlansModule(
        node: DVPNNodeInfo,
        for navigation: UINavigationController
    ) {
        PlansCoordinator(context: context, navigation: navigation, node: node).start()
    }
}

/// Scenes previews
extension ModulesFactory {
    func getConnectionScene() -> ConnectionView {
        let coordinator = ConnectionCoordinator(context: context, navigation: UINavigationController())
        let viewModel = ConnectionViewModel(
            model: ConnectionModel(context: context),
            router: coordinator.asRouter()
        )
        let view = ConnectionView(viewModel: viewModel)

        return view
    }

    func getOnboardingScene() -> OnboardingView {
        let coordinator = OnboardingCoordinator(
            context: context,
            navigation: UINavigationController(),
            window: UIWindow()
        ).asRouter()
        let model = OnboardingModel(context: context)
        let viewModel = OnboardingViewModel(model: model, router: coordinator)
        let view = OnboardingView(viewModel: viewModel)

        return view
    }

    func getAccountCreationScene(mode: CreationMode = .create) -> AccountCreationView {
        let coordinator = AccountCreationCoordinator(
            context: context,
            mode: mode,
            navigation: UINavigationController(),
            window: UIWindow()
        ).asRouter()
        let model = AccountCreationModel(context: context)
        let viewModel = AccountCreationViewModel(model: model, mode: mode, router: coordinator)
        let view = AccountCreationView(viewModel: viewModel)

        return view
    }

    func getLocationSelectionScene() -> LocationSelectionView {
        let coordinator = LocationSelectionCoordinator(
            context: context,
            navigation: UINavigationController()
        ).asRouter()
        let model = LocationSelectionModel(context: context)
        let viewModel = LocationSelectionViewModel(model: model, router: coordinator)
        let view = LocationSelectionView(viewModel: viewModel)

        return view
    }

    func getAccountInfoScene() -> AccountInfoView {
        let coordinator = AccountInfoCoordinator(context: context, navigation: UINavigationController()).asRouter()
        let model = AccountInfoModel(context: context)
        let viewModel = AccountInfoViewModel(model: model, router: coordinator)
        let view = AccountInfoView(viewModel: viewModel)

        return view
    }
}
