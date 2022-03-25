//
//  WalletErros+Ext.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 06.09.2021.
//

import Foundation
import SentinelWallet

extension SentinelServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .broadcastFailed:
            return L10n.SentinelService.Error.broadcastFailed
        case .emptyInfo:
            return L10n.Error.unavailableNode
        case .sessionStartFailed:
            return L10n.Error.connectionParsingFailed
        case .sessionsStopFailed:
            return L10n.Error.sessionStopFailed
        }
    }
}

extension WalletServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .accountMatchesDestination:
            return L10n.WalletService.Error.accountMatchesDestination
        case .missingMnemonics:
            return L10n.WalletService.Error.missingMnemonics
        case .missingAuthorization:
            return L10n.WalletService.Error.missingAuthorization
        case .notEnoughTokens:
            return L10n.WalletService.Error.notEnoughTokens
        case .mnemonicsDoNotMatch:
            return L10n.WalletService.Error.mnemonicsDoNotMatch
        case .savingError:
            return L10n.WalletService.Error.savingError
        }
    }
}
