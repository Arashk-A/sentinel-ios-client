//
//  Context.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 05.08.2021.
//

import Foundation
import SentinelWallet
import RevenueCat

protocol NoContext {}

final class CommonContext {
    typealias Storage = StoresGeneralInfo & StoresConnectInfo & StoresWallet & StoresDNSServers
    
    let storage: Storage
    let securityService: SecurityService
    let tunnelManager: TunnelManagerType
    let networkService: NetworkServiceType
    
    /// Wallet-dependent services
    private(set) var walletService: WalletService
    private(set) var sentinelService: SentinelService
    private(set) var userService: UserService
    private(set) var preloadService: PreloadServiceType
    private(set) var nodesService: NodesServiceType

    init(
        storage: Storage,
        securityService: SecurityService,
        walletService: WalletService,
        sentinelService: SentinelService,
        tunnelManager: TunnelManagerType,
        networkService: NetworkServiceType,
        userService: UserService,
        preloadService: PreloadServiceType,
        nodesService: NodesServiceType
    ) {
        self.storage = storage
        self.securityService = securityService
        self.walletService = walletService
        self.sentinelService = sentinelService
        self.tunnelManager = tunnelManager
        self.networkService = networkService
        self.userService = userService
        self.preloadService = preloadService
        self.nodesService = nodesService
    }

    func resetWalletContext() {
        guard let walletAddress = storage.walletAddress(), !walletAddress.isEmpty else {
           return
        }
        Purchases.shared.logIn(walletAddress) { (purchaserInfo, created, error) in
            log.debug(purchaserInfo)
            log.debug(created)
            if let error = error {
                log.error(error)
            }
        }
        walletService = WalletService(for: walletAddress, securityService: securityService)
        sentinelService = SentinelService(walletService: walletService)
        
        userService = UserService(walletService: walletService)
        nodesService = NodesService(sentinelService: sentinelService)
        preloadService = PreloadService(userService: userService)
        preloadService.loadData {}
    }
}

extension CommonContext: NoContext {}

// MARK: - Storages

protocol HasConnectionInfoStorage { var connectionInfoStorage: StoresConnectInfo { get } }
extension CommonContext: HasConnectionInfoStorage {
    var connectionInfoStorage: StoresConnectInfo {
        storage as StoresConnectInfo
    }
}

protocol HasGeneralInfoStorage { var generalInfoStorage: StoresGeneralInfo { get } }
extension CommonContext: HasGeneralInfoStorage {
    var generalInfoStorage: StoresGeneralInfo {
        storage as StoresGeneralInfo
    }
}

protocol HasWalletStorage { var walletStorage: StoresWallet { get } }
extension CommonContext: HasWalletStorage {
    var walletStorage: StoresWallet {
        storage as StoresWallet
    }
}

protocol HasDNSServersStorage { var dnsServersStorage: StoresDNSServers { get } }
extension CommonContext: HasDNSServersStorage {
    var dnsServersStorage: StoresDNSServers {
        storage as StoresDNSServers
    }
}

// MARK: - Services

protocol HasWalletService { var walletService: WalletService { get } }
extension CommonContext: HasWalletService {}

protocol HasSentinelService { var sentinelService: SentinelService { get } }
extension CommonContext: HasSentinelService {}

protocol HasSecurityService { var securityService: SecurityService { get } }
extension CommonContext: HasSecurityService {}

protocol HasTunnelManager { var tunnelManager: TunnelManagerType { get } }
extension CommonContext: HasTunnelManager {}

protocol HasNetworkService { var networkService: NetworkServiceType { get } }
extension CommonContext: HasNetworkService {}

protocol HasUserService { var userService: UserService { get } }
extension CommonContext: HasUserService {}

protocol HasPreloadService { var preloadService: PreloadServiceType { get } }
extension CommonContext: HasPreloadService {}

protocol HasNodesService { var nodesService: NodesServiceType { get } }
extension CommonContext: HasNodesService {}
