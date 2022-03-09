//
//  NodeDetailsViewModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import UIKit
import FlagKit
import SentinelWallet
import Combine

final class NodeDetailsViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    
    private let model: NodeDetailsModel
    private let router: Router

    enum Route {
        case error(Error)
        case subscribe(node: DVPNNodeInfo, delegate: NodeSubscriptionViewModelDelegate)
        case dismiss
        case connect
    }
    
    @Published private(set) var countryTileModel: CountryTileViewModel?
    @Published private(set) var nodeInfoViewModels: [NodeInfoViewModel] = []
    
    @Published private(set) var node: Node?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(model: NodeDetailsModel, router: Router) {
        self.model = model
        self.router = router

        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.router.play(event: .error(error))
                case let .update(node):
                    self?.update(sentinelNode: node)
                }
            }
            .store(in: &cancellables)
        
        model.setNode()
    }
}

extension NodeDetailsViewModel {
    func update(sentinelNode: SentinelNode) {
        self.node = sentinelNode.node
        
        guard let node = node else {
            return
        }
        
        let nodeInfo = node.info
        
        let countryCode = CountryFormatter.code(for: nodeInfo.location.country) ?? ""
        let icon = Flag(countryCode: countryCode)?.image(style: .roundedRect) ?? Asset.Tokens.dvpn.image
        
        countryTileModel = .init(
            id: "0",
            icon: icon,
            title: nodeInfo.moniker,
            subtitle: String(nodeInfo.address.suffix(6)),
            speed: node.info.bandwidth.speedImage
        )
        
        let domain = URL(string: sentinelNode.remoteURL)?.host ?? ""
        let upload = nodeInfo.bandwidth.upload.getBandwidthKBorMB
        let download = nodeInfo.bandwidth.download.getBandwidthKBorMB
        
        nodeInfoViewModels = [
            NodeInfoViewModel(type: .address, value: domain),
            NodeInfoViewModel(type: .peers, value: "\(nodeInfo.peers)"),
            NodeInfoViewModel(type: .uploadSpeed, value: makeString(from: upload)),
            NodeInfoViewModel(type: .provider, value: "Unknown"),
            NodeInfoViewModel(type: .downloadSpeed, value: makeString(from: download)),
            NodeInfoViewModel(type: .version, value: nodeInfo.version),
            NodeInfoViewModel(type: .type, value: "Wireguard"),
            NodeInfoViewModel(type: .country, value: nodeInfo.location.country),
            NodeInfoViewModel(type: .city, value: nodeInfo.location.city),
            NodeInfoViewModel(type: .features, value: "")
        ]
    }
    
    var gridViewModels: [GridViewModelType] {
        nodeInfoViewModels.map { GridViewModelType.nodeInfo($0) }
    }
}

// MARK: - Buttons actions

extension NodeDetailsViewModel {
    func didTapConnect() {
        UIImpactFeedbackGenerator.lightFeedback()
        guard let node = node else { return }
        toggle(node: node)
    }
}

// MARK: - NodeSubscriptionViewModelDelegate

extension NodeDetailsViewModel: NodeSubscriptionViewModelDelegate {
    func openConnection() {
        router.play(event: .dismiss)
    }
}

// MARK: - Private

extension NodeDetailsViewModel {
    private func toggle(node: Node) {
        guard model.isSubscribed else {
            router.play(event: .subscribe(node: node.info, delegate: self))
            return
        }
        
        model.save(nodeAddress: node.info.address)
        router.play(event: .connect)
    }
    
    private func makeString(from tuple: (String, String)) -> String {
        return tuple.0 + " " + tuple.1
    }
}
