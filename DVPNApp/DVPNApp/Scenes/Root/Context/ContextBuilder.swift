//
//  ContextBuilder.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 05.08.2021.
//

import Foundation
import SentinelWallet

/// This class should configure all required services and inject them into a Context
final class ContextBuilder {
    func buildContext() -> CommonContext {
        
        RealmStorage.prepare()
        let realmStorage = RealmStorage()
         
        let generalSettingsStorage = GeneralSettingsStorage()
        
        let securityService = SecurityService()
        let walletService = buildWalletService(storage: generalSettingsStorage, securityService: securityService)
        let tunnelManager = TunnelManager(storage: generalSettingsStorage)
        let networkService = NetworkService()
        let userService = UserService(walletService: walletService)
        let sentinelService = SentinelService(walletService: walletService)
        let nodesService = NodesService(nodesStorage: realmStorage, sentinelService: sentinelService)
        let preloadService = PreloadService(userService: userService)

        return CommonContext(
            storage: generalSettingsStorage,
            securityService: securityService,
            walletService: walletService,
            sentinelService: sentinelService,
            tunnelManager: tunnelManager,
            networkService: networkService,
            userService: userService,
            preloadService: preloadService,
            nodesService: nodesService
        )
    }

    func buildWalletService(
        storage: StoresWallet,
        securityService: SecurityService
    ) -> WalletService {
        guard let walletAddress = storage.walletAddress(), !walletAddress.isEmpty else {
            switch WalletManager(securityService: securityService).generateWallet() {
            case .failure(let error):
                fatalError("failed to generate wallet due to \(error), terminate")
            case .success(let walletService):
                storage.set(wallet: walletService.accountAddress)
                return walletService
            }
        }
        return WalletService(for: walletAddress, securityService: securityService)
    }
}
