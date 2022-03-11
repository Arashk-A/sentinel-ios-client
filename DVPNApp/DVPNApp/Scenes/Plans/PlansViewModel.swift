//
//  PlansViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 09.03.2022.
//

import UIKit
import Combine
import RevenueCat
import SentinelWallet

final class PlansViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
    }

    private let model: PlansModel
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var options: [PlanOptionViewModel] = []
    @Published var isLoading: Bool = false

    init(model: PlansModel, router: Router) {
        self.model = model
        self.router = router

        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.router.play(event: .error(error))
                case let .plans(plans):
                    self?.update(plans: plans)
                }
            }
            .store(in: &cancellables)
    }
}

extension PlansViewModel {
    func viewWillAppear() {
        isLoading = true
        model.refresh()
    }

    func togglePlan(vm: PlanOptionViewModel) {
        UIImpactFeedbackGenerator.lightFeedback()
    }
}

extension PlansViewModel {
    private func update(plans: [SentinelPlan]) {
        guard !plans.isEmpty else { return }
        
        options = plans.map {
            let price = $0.price[0]
            let priceString = PriceFormatter.fullFormat(amount: price.amount, denom: price.denom)
            
            return PlanOptionViewModel(
                id: $0.id,
                price: priceString + " " + L10n.Common.Points.title,
                bandwidth: (Int64($0.bytes) ?? 0).bandwidthGBString + " " + L10n.Common.gb,
                validity: TimeFormatter.duration(from: $0.validity)
            )
        }

        isLoading = false
    }
}
