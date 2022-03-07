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
    
    @Published private(set) var _availableNodesOfSelectedContinent: [SentinelNode] = []
    @Published private(set) var _loadedNodesCount: Int = 0
    @Published private(set) var _isAllLoaded: Bool = false
    
    @Published private(set) var _subscriptions: [Subscription] = []
    @Published private(set) var _subscribedNodes: [SentinelNode] = []
    @Published private(set) var _isLoadingSubscriptions: Bool = true
    
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
        let sentinelNodes = nodesStorage.sentinelNodes
            .filter { sentinelNode in
                guard let node = sentinelNode.node else {
                    return false
                }
                return ContinentDecoder.shared.isInContinent(node: node, continent: continent)
            }
        
        _availableNodesOfSelectedContinent = sentinelNodes
        
        loadNodesInfo(for: sentinelNodes)
    }
    
    func loadNodesInfo(for nodes: [SentinelNode]) {
        _isAllLoaded = false
        
        _loadedNodesCount = 0
        
        let chunked = nodes.chunked(into: constants.stepToLoad)
        
        let group = DispatchGroup()
        
        chunked.enumerated().forEach { index, littlePortion in
            group.enter()
            
            loadLittlePortion(sentinelNodes: littlePortion) { [weak self] in
                guard let self = self else { return }
                
                self._loadedNodesCount = self._loadedNodesCount + constants.stepToLoad
                
                group.leave()
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
        
        nodesStorage.sentinelNodes
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
        nodesStorage.sentinelNodes
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
                
                self.loadNodes(from: Set(subscriptions.map { $0.node }))
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
        
        newSentinelNodesMutated.forEach {
            nodesStorage.save(sentinelNode: $0)
        }
    }
    
    private func loadLittlePortion(
        sentinelNodes: [SentinelNode],
        completion: @escaping () -> Void
    ) {
        let group = DispatchGroup()
        
        var loadedPortion: [Node] = []
        
        sentinelNodes.forEach { node in
            group.enter()
            
            loadNodeInfo(for: node) { result in
                if case let .success(node) = result {
                    loadedPortion.append(node)
                }
                
                group.leave()
            }
        }
        
        loadedPortion.forEach { newNode in
            if let row = self._availableNodesOfSelectedContinent
                .firstIndex(where: { $0.address == newNode.info.address }) {
                
                let newSentinelNode = _availableNodesOfSelectedContinent[row].set(node: newNode)
                _availableNodesOfSelectedContinent[row] = newSentinelNode
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    private func loadNodeInfo(
        for sentinelNode: SentinelNode,
        completion: @escaping (Result<Node, Error>) -> Void
    ) {
        self.sentinelService.fetchInfo(
            for: sentinelNode, timeout: constants.timeout
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                log.error(error)
                completion(.failure(NodesServiceError.failToLoadData))
            case .success(let node):
                self.nodesStorage.save(node: node, for: sentinelNode)
                completion(.success(node))
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
}
