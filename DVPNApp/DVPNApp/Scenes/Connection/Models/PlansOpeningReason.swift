//
//  PlansOpeningReason.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 12.03.2022.
//

import Foundation

enum PlansOpeningReason {
    case quotaLeft
    case quotaLeftOrPlanExpired
    case nodeWasMovedToPlan
}

extension PlansOpeningReason {
    var title: String {
        switch self {
        case .quotaLeft:
            return L10n.Connection.ResubscribeToPlan.QuotaLeft.title
        case .quotaLeftOrPlanExpired:
            return L10n.Connection.ResubscribeToPlan.QuotaLeftOrPlanExpired.title
        case .nodeWasMovedToPlan:
            return L10n.Connection.ResubscribeToPlan.NodeWasMovedToPlan.title
        }
    }
    
    var message: String {
        switch self {
        case .quotaLeft:
            return L10n.Connection.ResubscribeToPlan.subtitle
        case .quotaLeftOrPlanExpired:
            return L10n.Connection.ResubscribeToPlan.subtitle
        case .nodeWasMovedToPlan:
            return L10n.Connection.ResubscribeToPlan.NodeWasMovedToPlan.subtitle
        }
    }
}
