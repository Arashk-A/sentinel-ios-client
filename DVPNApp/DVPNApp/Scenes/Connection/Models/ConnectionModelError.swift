//
//  ConnectionModelError.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 06.09.2021.
//

import Foundation

enum ConnectionModelError: LocalizedError {
    case signatureGenerationFailed
    case invalidURL
    case connectionParsingFailed

    case nodeIsOffline
    case notEnoughTokens
    
    case emptySubscriptions
    case emptyNodesForPlan

    var errorDescription: String? {
        switch self {
        case .signatureGenerationFailed:
            return L10n.Connection.Error.signatureGenerationFailed
        case .invalidURL:
            return L10n.Connection.Error.invalidURL
        case .nodeIsOffline:
            return L10n.Error.unavailableNode
        case .connectionParsingFailed:
            return L10n.Error.connectionParsingFailed
        case .notEnoughTokens:
            return L10n.Connection.Error.notEnoughTokens
        case .emptySubscriptions:
            return L10n.Connection.Error.emptySubscriptions
        case .emptyNodesForPlan:
            return L10n.Connection.Error.emptyNodesForPlan
        }
    }
}
