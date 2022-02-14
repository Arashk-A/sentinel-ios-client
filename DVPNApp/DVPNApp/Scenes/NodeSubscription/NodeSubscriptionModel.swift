//
//  NodeSubscriptionModel.swift
//  DVPNApp
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import Foundation
import Combine
import SentinelWallet

enum NodeSubscriptionModelEvent {
    case error(Error)
    case updatePayment(countryName: String, price: String, fee: Int)
    case processPayment(Result<TransactionResult, Error>)
    case addTokens
    case openConnection
}

enum NodeSubscriptionModelError: LocalizedError {
    case paymentFailed

    var errorDescription: String? {
        switch self {
        case .paymentFailed:
            return L10n.Plans.Error.Payment.failed
        }
    }
}

final class NodeSubscriptionModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage & HasNodesService
    private let context: Context

    private let eventSubject = PassthroughSubject<NodeSubscriptionModelEvent, Never>()
    var eventPublisher: AnyPublisher<NodeSubscriptionModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var node: DVPNNodeInfo

    init(context: Context, node: DVPNNodeInfo) {
        self.context = context
        self.node = node
    }
}

extension NodeSubscriptionModel {
    var address: String {
        context.walletService.accountAddress
    }
    
    func refresh() {
        $node.eraseToAnyPublisher()
            .map { [context] in
                NodeSubscriptionModelEvent.updatePayment(
                    countryName: $0.location.country,
                    price: $0.price,
                    fee: context.walletService.fee
                )
            }
            .subscribe(eventSubject)
            .store(in: &cancellables)
    }

    func change(to node: DVPNNodeInfo, isSubscribed: Bool) {
        guard !isSubscribed else {
            context.connectionInfoStorage.set(lastSelectedNode: node.address)
            eventSubject.send(.openConnection)
            return
        }

        self.node = node
    }

    func checkBalanceAndSubscribe(deposit: CoinToken, plan: String, price: String) {
        context.walletService.fetchBalance { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.eventSubject.send(.processPayment(.failure(error)))
            case .success(let balances):
                let balance = balances
                    .first(where: { $0.denom == deposit.denom })
                
                guard let balance = balance,
                      Int(balance.amount) ?? 0 >= (Int(deposit.amount) ?? 0 + self.context.walletService.fee) else {
                    self.eventSubject.send(.addTokens)
                    return
                }

                self.subscribe(with: deposit)
            }
        }
    }
}

// MARK: - Private

extension NodeSubscriptionModel {
    private func show(error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
    }

    private func subscribe(with deposit: CoinToken) {
        context.sentinelService.subscribe(to: node.address, deposit: deposit) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.eventSubject.send(.processPayment(.failure(error)))
            case .success(let response):
                guard response.isSuccess else {
                    self.eventSubject.send(.processPayment(.failure(NodeSubscriptionModelError.paymentFailed)))
                    return
                }
                
                self.context.nodesService.loadSubscriptions(completion: { _ in })
                self.context.connectionInfoStorage.set(lastSelectedNode: self.node.address)
                self.context.connectionInfoStorage.set(shouldConnect: true)
                self.eventSubject.send(.processPayment(.success(response)))
            }
        }
    }
}
