//
//  ContinentsViewModel.swift
//  DVPNApp
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import Foundation
import FlagKit
import SentinelWallet
import Combine
import UIKit.UIImage

enum NodeError: LocalizedError {
    case unavailableNode

    var errorDescription: String? {
        switch self {
        case .unavailableNode:
            return L10n.Error.unavailableNode
        }
    }
}

final class ContinentsViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case connect
        case subscribe(node: DVPNNodeInfo, delegate: NodeSubscriptionViewModelDelegate)
        case openNodes(Continent, delegate: NodeSubscriptionViewModelDelegate)
    }
    
    private(set) var nodes: Set<SentinelNode> = []
    
    private let model: ContinentsModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var numberOfNodesInContinent: [Continent: Int] = [:] {
        didSet {
            chunkedModels = numberOfNodesInContinent
                .sorted { $0.key.index < $1.key.index }
                .chunked(into: 2)
        }
    }
    @Published private(set) var chunkedModels: [[Dictionary<Continent, Int>.Element]] = []
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected

    init(model: ContinentsModel, router: Router) {
        self.model = model
        self.router = router
        
        handeEvents()
        
        numberOfNodesInContinent = model.numberOfNodesInContinent
        
        model.setNodes()
        model.refreshStatus()
    }
    
    func viewWillAppear() {
        model.connectIfNeeded()
        model.refreshStatus()
    }
}

// MARK: - NodeSubscriptionViewModelDelegate

extension ContinentsViewModel: NodeSubscriptionViewModelDelegate {
    func openConnection() {
        model.connectIfNeeded()
    }
}

// MARK: - Buttons actions

extension ContinentsViewModel {
    func toggleLocation(with id: String) {
        UIImpactFeedbackGenerator.lightFeedback()
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address ?? "" == id }),
              let node = sentinelNode.node else {
                  router.play(event: .error(NodeError.unavailableNode))
                  return
              }
        
        toggle(node: node)
    }

    func toggleRandomLocation() {
        UIImpactFeedbackGenerator.lightFeedback()
        guard connectionStatus != .connected else {
            model.disconnect()
            return
        }
        guard !nodes.isEmpty else { return }
        guard !model.subscriptions.isEmpty else {
            connectToRandomNode()
            return
        }

        guard let nodeId = model.subscriptions.randomElement()?.node else {
            connectToRandomNode()
            return
        }

        toggleLocation(with: nodeId)
    }
    
    func openNodes(for continent: Continent) {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .openNodes(continent, delegate: self))
    }
}

extension ContinentsViewModel {
    private func handeEvents() {
        model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case let .error(error):
                    self.router.play(event: .error(error))
                case let .update(nodes):
                    self.nodes.formUnion(nodes)
                case .connect:
                    self.router.play(event: .connect)
                case .setNumberOfNodesInContinent:
                    self.numberOfNodesInContinent = self.model.numberOfNodesInContinent
                case let .setTunnelStatus(status):
                    self.connectionStatus = status
                }
            }
            .store(in: &cancellables)
    }

    private func connectToRandomNode() {
        guard let sentinelNode = nodes.filter({ $0.node?.latency ?? 0 < 1 }).randomElement() ?? nodes.first,
              let node = sentinelNode.node else {
                  router.play(event: .error(NodeError.unavailableNode))
                  return
              }
        
        toggle(node: node)
    }

    private func toggle(node: Node) {
        let isSubscribedToNode = model.isSubscribed(to: node.info.address)
        guard isSubscribedToNode else {
            router.play(event: .subscribe(node: node.info, delegate: self))
            return
        }

        model.save(nodeAddress: node.info.address)
    }
}
