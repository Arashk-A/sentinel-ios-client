//
//  NodesService.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation
import SentinelWallet

private struct Constants {
    let timeout: TimeInterval = 5
    let stepToLoad = 10
}

private let constants = Constants()

final class NodesService {
    private let nodesStorage: StoresNodes
    private let sentinelService: SentinelService

    private var loadedNodes: Set<SentinelNode> = []
    
    @Published private(set) var _availableNodesOfSelectedContinent: [SentinelNode] = []
    @Published private(set) var _loadedNodesCount = 0
    @Published private(set) var _isAllLoaded = false

    @Published private(set) var _subscriptions: [Subscription] = []
    @Published private(set) var _subscribedNodes: [SentinelNode] = []
    @Published private(set) var _isLoadingSubscriptions = true
    
    init(nodesStorage: StoresNodes = RealmStorage(), sentinelService: SentinelService) {
        self.nodesStorage = nodesStorage
        self.sentinelService = sentinelService
    }
}

extension NodesService: NodesServiceType {
    var availableNodesOfSelectedContinent: Published<[SentinelNode]>.Publisher {
        $_availableNodesOfSelectedContinent
    }
    
    var loadedNodesCount: Published<Int>.Publisher {
        $_loadedNodesCount
    }
    
    var isAllLoaded: Published<Bool>.Publisher {
        $_isAllLoaded
    }
    
    var subscriptions: Published<[Subscription]>.Publisher {
        $_subscriptions
    }
    
    var subscribedNodes: Published<[SentinelNode]>.Publisher {
        $_subscribedNodes
    }
    
    var isLoadingSubscriptions: Published<Bool>.Publisher {
        $_isLoadingSubscriptions
    }
    
    func loadAllNodesIfNeeded(completion: @escaping ((Result<[SentinelNode], Error>) -> Void)) {
        if nodesStorage.sentinelNodes.isEmpty {
            loadAllNodes(completion: completion)
        } else {
            completion(.success([]))
        }
    }
    
    func loadAllNodes(
        completion: ((Result<[SentinelNode], Error>) -> Void)?
    ) {
        sentinelService.queryNodes(limit: 10000) { [weak self] result in
            switch result {
            case .failure(let error):
                log.error(error)
            case .success(let nodes):
                self?.save(newSentinelNodes: nodes)
            }
            
            completion?(result)
        }
    }
    
    func loadNodesInfo(for continent: Continent) {
        let sentinelNodes = Array(loadedNodes)
            .filter { sentinelNode in
                guard let node = sentinelNode.node else {
                    return false
                }
                return ContinentDecoder.shared.isInContinent(node: node, continent: continent)
            }
        
        _availableNodesOfSelectedContinent = sentinelNodes

        if _isAllLoaded {
            loadNodesInfo(for: sentinelNodes)
        }
    }
    
    func loadNodesInfo(for nodes: [SentinelNode]) {
        _isAllLoaded = false

        _loadedNodesCount = 0
        
        let chunked = nodes.chunked(into: constants.stepToLoad)

        let queue = DispatchQueue(
            label: "NodesService",
            qos: .utility,
            attributes: .concurrent
        )
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: constants.stepToLoad)

        chunked.forEach { littlePortion in
            queue.async(group: group) {  [weak self] in
                guard let self = self else { return }
                group.enter()
                semaphore.wait()

                self.loadLittlePortion(sentinelNodes: littlePortion) {
                    self._loadedNodesCount = self._loadedNodesCount + constants.stepToLoad

                    group.leave()
                    semaphore.signal()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?._isAllLoaded = true
        }
    }
    
    var nodesInContinentsCount: [Continent: Int] {
        var nodesInContinents: [Continent: Int] = [:]
        
        Continent.allCases.forEach {
            nodesInContinents[$0] = 0
        }
        
        loadedNodes
            .forEach { node in
                guard let node = node.node else { return }
                
                if let continent = ContinentDecoder().getContinent(for: node),
                   let count = nodesInContinents[continent] {
                    nodesInContinents[continent] = count + 1
                }
            }
        
        return nodesInContinents
    }
    
    var nodes: [SentinelNode] {
        Array(loadedNodes)
    }
    
    func loadActiveSubscriptions(
        completion: @escaping ((Result<[Subscription], Error>) -> Void)
    ) {
        _isLoadingSubscriptions = true
        
        sentinelService.fetchSubscriptions(with: .active) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                log.error(error)
                self._isLoadingSubscriptions = false
                completion(.failure(error))
            case .success(let subscriptions):
                self._subscriptions = subscriptions
                
                completion(.success(subscriptions))
                
                guard !subscriptions.isEmpty else {
                    self._isLoadingSubscriptions = false
                    return
                }
                
                let addresses = Set(subscriptions.map { $0.node }.filter { !$0.isEmpty })
                self.loadNodes(from: addresses)
            }
        }
    }

    func loadNodesInfo(
        for plan: UInt64,
        completion: @escaping (Result<[SentinelNode], Error>) -> Void
    ) {
        sentinelService.queryNodesForPlan(with: plan) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                log.error(error)
                completion(.failure(NodesServiceError.failToLoadData))
            case .success(let nodes):
                self.loadInfo(for: nodes, completion: completion)
            }
        }
    }
}

// MARK: - Private

extension NodesService {
    private func save(newSentinelNodes: [SentinelNode]) {
        var newSentinelNodesMutated = newSentinelNodes
        
        nodesStorage.sentinelNodes.forEach { sentinelNodeInDB in
            let index = newSentinelNodesMutated
                .firstIndex(where: { $0.address == sentinelNodeInDB.address })
            
            if let index = index {
                let newNode = sentinelNodeInDB.setFields(from: newSentinelNodesMutated[index])
                nodesStorage.save(sentinelNode: newNode)
                
                newSentinelNodesMutated.remove(at: index)
            } else {
                nodesStorage.remove(sentinelNode: sentinelNodeInDB)
            }
        }

        nodesStorage.save(sentinelNodes: newSentinelNodesMutated)
        loadedNodes.formUnion(nodesStorage.sentinelNodes)
    }
    
    private func loadLittlePortion(
        sentinelNodes: [SentinelNode],
        completion: @escaping () -> Void
    ) {
        let group = DispatchGroup()
        
        var loadedPortion: [SentinelNode] = []
        
        sentinelNodes.forEach { node in
            group.enter()
            
            loadNodeInfo(for: node) { [weak self] result in
                guard case let .success(sentinelNode) = result else {
                    group.leave()
                    return
                }
                loadedPortion.append(sentinelNode)
                group.leave()
                guard let self = self, let node = sentinelNode.node else { return }
                guard let row = self._availableNodesOfSelectedContinent
                        .firstIndex(where: { $0.address == node.info.address }) else { return }
                let newSentinelNode = self._availableNodesOfSelectedContinent[row].set(node: node)
                self._availableNodesOfSelectedContinent[row] = newSentinelNode
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.nodesStorage.save(sentinelNodes: loadedPortion)
            self?.loadedNodes.formUnion(loadedPortion)
            completion()
        }
    }
    
    private func loadNodeInfo(
        for sentinelNode: SentinelNode,
        completion: @escaping (Result<SentinelNode, Error>) -> Void
    ) {
        sentinelService.fetchInfo(
            for: sentinelNode, timeout: constants.timeout
        ) { result in
            switch result {
            case .failure(let error):
                log.error(error)
                completion(.failure(NodesServiceError.failToLoadData))
            case .success(let node):
                completion(.success(sentinelNode.set(node: node)))
            }
        }
    }
    
    /// Use for loading nodes from subscriptions
    private func loadNodes(from addresses: Set<String>) {
        self._subscribedNodes = []
        
        addresses.enumerated().forEach { index, address in
            sentinelService.queryNodeStatus(
                address: address,
                timeout: constants.timeout
            ) { [weak self] result in
                guard let self = self else { return }
                if index == addresses.count - 1 {
                    self._isLoadingSubscriptions = false
                }
                switch result {
                case .failure(let error):
                    log.error(error)
                case .success(let node):
                    self._subscribedNodes.append(node)
                }
            }
        }
    }
    
    private func loadNodeInfo(for planID: UInt64) {
        sentinelService.queryNodesForPlan(with: planID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                log.error(error)
            case .success(let sentinelNodes):
                self.loadNodes(from: Set(sentinelNodes.map { $0.address }))
            }
        }
    }

    private func loadInfo(
        for sentinelNodes: [SentinelNode],
        completion: @escaping (Result<[SentinelNode], Error>) -> Void
    ) {
        let group = DispatchGroup()
        var loadedNodes: [SentinelNode] = []

        sentinelNodes.forEach { sentinelNode in
            group.enter()

            sentinelService.fetchInfo(for: sentinelNode, timeout: constants.timeout) { result in
                if case let .success(node) = result {
                    loadedNodes.append(sentinelNode.set(node: node))
                }

                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(.success(loadedNodes))
        }
    }
}
