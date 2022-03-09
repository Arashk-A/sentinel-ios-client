//
//  StoresConnectInfo.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation

protocol StoresConnectInfo {
    func set(shouldConnect: Bool)
    func shouldConnect() -> Bool
    func set(lastSelectedNode: String)
    func lastSelectedNode() -> String?
    
    func set(lastSelectedPlanId: UInt64?)
    func lastSelectedPlanId() -> UInt64?
    
    func set(sessionId: Int?)
    func lastSessionId() -> Int?
    func set(sessionStart: Date?)
    func lastSessionStart() -> Date?
}
