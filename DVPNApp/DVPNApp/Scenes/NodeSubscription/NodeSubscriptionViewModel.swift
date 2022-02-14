//
//  NodeSubscriptionViewModel.swift
//  DVPNApp
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import UIKit
import FlagKit
import SentinelWallet
import Combine
import GRPC

private struct Constants {
    let stepGB = 1
    let maxAllowedGB = 100
    let minAllowedGB = 1
}
private let constants = Constants()

protocol NodeSubscriptionViewModelDelegate: AnyObject {
    func openConnection()
}

final class NodeSubscriptionViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    
    private let model: NodeSubscriptionModel
    private let router: Router

    private weak var delegate: NodeSubscriptionViewModelDelegate?

    enum Route {
        case error(Error)
        case addTokensAlert(completion: (Bool) -> Void)
        case accountInfo
        case subscribe(node: String, completion: (Bool) -> Void)
        case close
    }
    
    private var fee: Int = 0
    private var price: Int = 0
    
    @Published private(set) var selectedLocationName: String
    @Published var prettyTokesToSpend: String = "0"

    @Published private(set) var gbToBuy: Int {
        didSet {
            prettyTokesToSpend = PriceFormatter.fullFormat(amount: tokesToSpend)
        }
    }

    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    
    private let formatter = NumberFormatter()
    
    init(model: NodeSubscriptionModel, router: Router, delegate: NodeSubscriptionViewModelDelegate?) {
        self.model = model
        self.router = router
        self.delegate = delegate
        
        selectedLocationName = ""
        gbToBuy = 1

        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.show(error: error)
                case let .updatePayment(countryName, price, fee):
                    self?.updatePayment(countryName: countryName, price: price, fee: fee)
                case let .processPayment(result):
                    self?.isLoading = false
                    switch result {
                    case .failure(let error):
                        self?.show(error: error)
                    case .success:
                        self?.openConnection()
                    }
                case .addTokens:
                    self?.showAddTokens()
                case .openConnection:
                    self?.openConnection()
                }
            }
            .store(in: &cancellables)

        self.model.refresh()
    }
}

// MARK: - Counter
    
extension NodeSubscriptionViewModel {
    func togglePlus() {
        UIImpactFeedbackGenerator.lightFeedback()
        guard gbToBuy < constants.maxAllowedGB else {
            return
        }
        gbToBuy += constants.stepGB
    }
    
    func toggleMinus() {
        UIImpactFeedbackGenerator.lightFeedback()
        guard gbToBuy > constants.minAllowedGB else {
            return
        }
        gbToBuy -= constants.stepGB
    }
    
    var tokesToSpend: Int {
        gbToBuy * price + fee
    }
}

// MARK: - Buttons actions

extension NodeSubscriptionViewModel {
    func didTapSubscribe() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(
            event: .subscribe(node: selectedLocationName) { [weak self] result in
                guard let self = self, result else {
                    return
                }
                self.isLoading = true
                self.model.checkBalanceAndSubscribe(
                    deposit: .init(denom: "udvpn", amount: "\(self.price * self.gbToBuy)"),
                    plan: String(format: "%.1f", self.gbToBuy) + L10n.Common.gb,
                    price: self.prettyTokesToSpend
                )
            }
        )
    }
    
    func didTapCrossButton() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .close)
    }
}

// MARK: - Private

extension NodeSubscriptionViewModel {
    private func show(error: Error) {
        isLoading = false
        guard let grpcError = error as? GRPC.GRPCError.RPCTimedOut else {
            router.play(event: .error(error))
            return
        }

        router.play(event: .error(grpcError))
    }

    private func updatePayment(countryName: String, price: String, fee: Int) {
        self.selectedLocationName = countryName
        self.fee = fee
        self.price = PriceFormatter.rawFormat(price: price).price
        self.gbToBuy = gbToBuy
    }

    private func openConnection() {
        delegate?.openConnection()
        router.play(event: .close)
    }

    private func showAddTokens() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .addTokensAlert { [weak self] result in
            self?.isLoading = false
            guard result else { return }
            self?.router.play(event: .accountInfo)
        })
    }
}
