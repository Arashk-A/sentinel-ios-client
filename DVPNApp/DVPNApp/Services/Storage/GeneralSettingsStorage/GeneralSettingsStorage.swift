//
//  GeneralSettingsStorage.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 18.08.2021.
//

import Foundation
import Accessibility

private enum Keys: String {
    case shouldConnect
    case didPassOnboarding

    case lastSelectedNodeKey
    case lastSelectedPlanId
    case walletKey
    case lastSessionKey
    case dnsKey
    case sessionStart
}

final class GeneralSettingsStorage {
    private let settingsStorageStrategy: SettingsStorageStrategyType

    init(settingsStorageStrategy: SettingsStorageStrategyType = UserDefaultsStorageStrategy()) {
        self.settingsStorageStrategy = settingsStorageStrategy
    }
}

// MARK: - StoresGeneralInfo

extension GeneralSettingsStorage: StoresGeneralInfo {
    func set(didPassOnboarding: Bool) {
        settingsStorageStrategy.setObject(didPassOnboarding, forKey: Keys.didPassOnboarding.rawValue)
    }

    func didPassOnboarding() -> Bool {
        settingsStorageStrategy.object(ofType: Bool.self, forKey: Keys.didPassOnboarding.rawValue) ?? false
    }
}

// MARK: - StoresConnectInfo

extension GeneralSettingsStorage: StoresConnectInfo {
    func set(shouldConnect: Bool) {
        settingsStorageStrategy.setObject(shouldConnect, forKey: Keys.shouldConnect.rawValue)
    }

    func shouldConnect() -> Bool {
        settingsStorageStrategy.object(ofType: Bool.self, forKey: Keys.shouldConnect.rawValue) ?? false
    }
    
    func set(lastSelectedNode: String) {
        settingsStorageStrategy.setObject(lastSelectedNode, forKey: Keys.lastSelectedNodeKey.rawValue)
    }

    func lastSelectedNode() -> String? {
        settingsStorageStrategy.object(ofType: String.self, forKey: Keys.lastSelectedNodeKey.rawValue)
    }
    
    func set(lastSelectedPlanId: UInt64?) {
        settingsStorageStrategy.setObject(lastSelectedPlanId, forKey: Keys.lastSelectedPlanId.rawValue)
    }
    
    func lastSelectedPlanId() -> UInt64? {
        settingsStorageStrategy.object(ofType: UInt64.self, forKey: Keys.lastSelectedPlanId.rawValue)
    }

    func set(sessionId: Int?) {
        settingsStorageStrategy.setObject(sessionId, forKey: Keys.lastSessionKey.rawValue)
    }

    func lastSessionId() -> Int? {
        settingsStorageStrategy.object(ofType: Int.self, forKey: Keys.lastSessionKey.rawValue)
    }
    
    func set(sessionStart: Date?) {
        settingsStorageStrategy.setObject(sessionStart, forKey: Keys.sessionStart.rawValue)
    }
    
    func lastSessionStart() -> Date? {
        settingsStorageStrategy.object(ofType: Date.self, forKey: Keys.sessionStart.rawValue)
    }
}

// MARK: - StoresWallet

extension GeneralSettingsStorage: StoresWallet {
    func set(wallet: String) {
        settingsStorageStrategy.setObject(wallet, forKey: Keys.walletKey.rawValue)
    }
    
    func walletAddress() -> String? {
        settingsStorageStrategy.object(ofType: String.self, forKey: Keys.walletKey.rawValue)
    }
}

// MARK: - StoresDNSServers

extension GeneralSettingsStorage: StoresDNSServers {
    func set(dns: DNSServerType) {
        settingsStorageStrategy.setObject(dns.rawValue, forKey: Keys.dnsKey.rawValue)
    }
    
    func selectedDNS() -> DNSServerType {
        guard let rawValue = settingsStorageStrategy.object(ofType: String.self, forKey: Keys.dnsKey.rawValue) else {
            return .default
        }

        guard let server = DNSServerType(rawValue: rawValue) else {
            return .default
        }

        return server
    }
}
