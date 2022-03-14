//
//  NodesServiceType.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation
import SentinelWallet

protocol NodesServiceType {
    var availableNodesOfSelectedContinent: Published<[SentinelNode]>.Publisher { get }
    var loadedNodesCount: Published<Int>.Publisher { get }
    var isAllLoaded: Published<Bool>.Publisher { get }
    var nodes: [SentinelNode] { get }
    
    func loadAllNodesIfNeeded(completion: @escaping ((Result<[SentinelNode], Error>) -> Void))
    func loadAllNodes(completion: ((Result<[SentinelNode], Error>) -> Void)?)
    func loadNodesInfo(for continent: Continent)
    func loadNodesInfo(for nodes: [SentinelNode])
    func loadNodesInfo(for plan: UInt64, completion: @escaping (Result<[SentinelNode], Error>) -> Void)
    var nodesInContinentsCount: [Continent: Int] { get }
    func loadActiveSubscriptions(completion: @escaping ((Result<[Subscription], Error>) -> Void))
    
    var subscriptions: Published<[Subscription]>.Publisher { get }
    var subscribedNodes: Published<[SentinelNode]>.Publisher { get }
    var isLoadingSubscriptions: Published<Bool>.Publisher { get }
}

extension NodesServiceType {
    func loadAllNodes() {
        loadAllNodes(completion: nil)
    }
}
