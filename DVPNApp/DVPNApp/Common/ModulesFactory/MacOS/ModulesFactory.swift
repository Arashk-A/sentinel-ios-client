//
//  ModulesFactory+macOS.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 09.11.2021.
//

import Cocoa
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
    func makeOnboardingModule(for window: NSWindow) {
        OnboardingCoordinator(context: context, window: window).start()
    }
    
    func makeAccountCreationModule(mode: CreationMode, window: NSWindow) {
        AccountCreationCoordinator(context: context, mode: mode, window: window).start()
    }
    
    func makeHomeModule(for window: NSWindow) {
        HomeCoordinator(context: context, window: window).start()
    }
}

/// Scenes previews
extension ModulesFactory {
    func getOnboardingScene() -> OnboardingView {
        let coordinator = OnboardingCoordinator(
            context: context,
            window: NSWindow()
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
            window: NSWindow()
        ).asRouter()
        let model = AccountCreationModel(context: context)
        let viewModel = AccountCreationViewModel(model: model, mode: mode, router: coordinator)
        let view = AccountCreationView(viewModel: viewModel)

        return view
    }
    
    func getHomeScene() -> HomeView {
        let coordinator = HomeCoordinator(
            context: context,
            window: NSWindow()
        ).asRouter()
        let model = HomeModel(context: context)
        let viewModel = HomeViewModel(model: model, router: coordinator)
        let view = HomeView(viewModel: viewModel)

        return view
    }
}