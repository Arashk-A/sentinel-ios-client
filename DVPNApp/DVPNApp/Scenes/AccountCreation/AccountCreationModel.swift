//
//  AccountCreationModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.10.2021.
//

import Foundation
import Foundation
import Combine
import SentinelWallet

private struct Constants {
    let emptyMnemonic = Array(repeating: "", count: 24)
}
private let constants = Constants()

enum AccountCreationModelEvent {
    case error(Error)
    case updateWallet
    case address(String?)
    case mnemonic([String])
    case mode(CreationMode)
}

enum AccountCreationModelError: LocalizedError {
    case creationFailed
    case termsUnchecked

    var errorDescription: String? {
        switch self {
        case .creationFailed:
            return L10n.AccountCreation.Error.creationFailed
        case .termsUnchecked:
            return L10n.AccountCreation.Error.termsUnchecked
        }
    }
}

final class AccountCreationModel {
    typealias Context = HasSecurityService & HasWalletStorage & HasNodesService & HasPreloadService
    private let context: Context

    private let eventSubject = PassthroughSubject<AccountCreationModelEvent, Never>()
    var eventPublisher: AnyPublisher<AccountCreationModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init(context: Context) {
        self.context = context
    }

    func change(to mode: CreationMode) {
        switch mode {
        case .create:
            guard let address = context.walletStorage.walletAddress() else {
                eventSubject.send(.error(AccountCreationModelError.creationFailed))
                return
            }

            guard let mnemonic = context.securityService.loadMnemonics(for: address) else {
                eventSubject.send(.error(AccountCreationModelError.creationFailed))
                return
            }

            eventSubject.send(.mode(mode))
            eventSubject.send(.address(address))
            eventSubject.send(.mnemonic(mnemonic))
            
        case .restore:
            eventSubject.send(.mode(mode))
            eventSubject.send(.address(nil))
            eventSubject.send(.mnemonic(constants.emptyMnemonic))
        }
    }

    func check(mnemonic: [String]) {
        switch context.securityService.restore(from: mnemonic) {
        case .failure:
            return
        case .success(let result):
            eventSubject.send(.address(result))
        }
    }

    func saveWallet(mnemonic: [String]) {
        let mnemonic = mnemonic.map { $0.trimmingCharacters(in: .whitespaces) }

        switch context.securityService.restore(from: mnemonic) {
        case .failure(let error):
            eventSubject.send(.error(error))
        case .success(let result):
            guard context.securityService.save(mnemonics: mnemonic, for: result) else {
                eventSubject.send(.error(AccountCreationModelError.creationFailed))
                return
            }
            context.walletStorage.set(wallet: result)
            ModulesFactory.shared.resetWalletContext()
            context.preloadService.loadData {}

            eventSubject.send(.updateWallet)
        }
    }
}
