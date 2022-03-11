//
//  SentinelPlan+Hashable.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 11.03.2022.
//

import Foundation
import SentinelWallet

extension SentinelPlan: Hashable {
    public static func == (lhs: SentinelPlan, rhs: SentinelPlan) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
