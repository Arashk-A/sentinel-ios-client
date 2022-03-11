//
//  TabBarCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 19.11.2021.
//

import UIKit

/// A enum that describes tabs.
enum TabType: Int, CaseIterable {
    case continents
    case plans
    case subscribedNodes
    case account
    case extra

    var title: String {
        switch self {
        case .continents:
            return L10n.TabBar.Item.continents.capitalized
        case .plans:
            return L10n.TabBar.Item.plans
        case .subscribedNodes:
            return L10n.TabBar.Item.subscribedNodes
        case .account:
            return L10n.TabBar.Item.account.capitalized
        case .extra:
            return L10n.TabBar.Item.extra
        }
    }

    var image: UIImage {
        switch self {
        case .continents:
            return Asset.Tabbar.continents.image
        case .plans:
            return Asset.Tabbar.provider.image
        case .subscribedNodes:
            return Asset.Tabbar.subscribed.image
        case .account:
            return Asset.Tabbar.account.image
        case .extra:
            return Asset.Tabbar.extra.image
        }
    }
}

protocol TabSwitcher: AnyObject {
    func switchTo(tab: TabType)
}

final class TabBarCoordinator: CoordinatorType {
    private var tabBarController: UITabBarController?
    private let tabs = TabType.allCases

    private weak var window: UIWindow?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let tabBarController = makeTabBarController()
        self.tabBarController = tabBarController

        tabBarController.viewControllers = tabs.map { makeTab(for: $0) }
        tabBarController.selectedIndex = 0

        window?.rootViewController = tabBarController
    }
}

// MARK: - TabBar configuration

extension TabBarCoordinator {
    private func makeTabBarController() -> UITabBarController {
        let controller = UITabBarController()
        controller.tabBar.isTranslucent = false
        controller.tabBar.barTintColor = Asset.Colors.gridBorder.color
        controller.tabBar.backgroundColor = Asset.Colors.gridBorder.color

        controller.tabBar.tintColor = Asset.Colors.navyBlue.color
        controller.tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.8)

        controller.tabBar.itemSpacing = 5

        return controller
    }

    func makeTab(for tab: TabType) -> UINavigationController {
        let initialView = makeTabContent(for: tab)
        let tabBarItem = UITabBarItem(title: tab.title, image: tab.image, tag: tab.rawValue)
        initialView.tabBarItem = tabBarItem

        return initialView
    }

    private func makeTabContent(for tab: TabType) -> UINavigationController {
        let navigationController = UINavigationController()
        switch tab {
        case .continents:
            ModulesFactory.shared.makeHomeModule(for: navigationController)
        case .subscribedNodes:
            ModulesFactory.shared.makeSubscribedNodesModule(for: navigationController)
        case .plans:
            ModulesFactory.shared.makePlansModule(for: navigationController)
        case .account:
            ModulesFactory.shared.makeAccountInfoModule(for: navigationController)
        case .extra:
            ModulesFactory.shared.makeExtraModule(for: navigationController)
        }

        return navigationController
    }
}

// MARK: - HomeTabSwitcher

extension TabBarCoordinator: TabSwitcher {
    func switchTo(tab: TabType) {
        tabBarController?.selectedIndex = tab.rawValue
    }
}
