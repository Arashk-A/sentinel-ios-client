//
//  PlanOptionViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 09.03.2022.
//

import Foundation
import SentinelWallet

struct PlanOptionViewModel: Hashable {
    let id: UInt64
    let price: String
    let bandwidth: String
    let validity: String

    var isSubscribed: Bool
}
