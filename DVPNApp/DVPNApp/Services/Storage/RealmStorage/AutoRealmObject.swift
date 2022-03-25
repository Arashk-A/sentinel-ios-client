//
//  AutoRealmObject.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 21.10.2021.
//

import Foundation
import RealmSwift
import SentinelWallet

// swiftlint:disable force_unwrapping

// MARK: - SentinelNodeObject
public class SentinelNodeObject: Object {
    @objc dynamic var address: String?
    @objc dynamic var provider: String?
    let price = List<CoinTokenObject>()
    @objc dynamic var remoteURL: String?
    @objc dynamic var node: NodeObject?

    override public static func primaryKey() -> String? {
        "address"
    }
}

// MARK: SentinelNode: Preservable
extension SentinelNode: Preservable {
    init(managedObject: SentinelNodeObject) {
        self.init(
            address: managedObject.address!,
            provider: managedObject.provider!,
            price: Array(managedObject.price).map(CoinToken.init),
            remoteURL: managedObject.remoteURL!,
            node: managedObject.node.flatMap { Node(managedObject: $0) }
        )
    }
    
    func toManagedObject() -> SentinelNodeObject {
        let obj = SentinelNodeObject()
        
        obj.address = address
        obj.provider = provider
        obj.price.append(objectsIn: price.map { $0.toManagedObject() })
        obj.remoteURL = remoteURL
        obj.node = node?.toManagedObject()
        
        return obj
    }
}

// MARK: - NodeObject
public class NodeObject: EmbeddedObject {
    @objc dynamic var info: DVPNNodeInfoObject?
    let latency = RealmProperty<Double?>()
}

// MARK: Node: Persistable
extension Node: Persistable {
    public init(managedObject: NodeObject) {
        self.init(
            info: DVPNNodeInfo(managedObject: managedObject.info!),
            latency: managedObject.latency.value!
        )
    }

    public func toManagedObject() -> NodeObject {
        let obj = NodeObject()
        
        obj.info = info.toManagedObject()
        obj.latency.value = latency.truncatingRemainder(dividingBy: 1)

        return obj
    }
}

// MARK: - BandwidthObject
public class BandwidthObject: EmbeddedObject {
    let download = RealmProperty<Int?>()
    let upload = RealmProperty<Int?>()
}

// MARK: Bandwidth: Persistable
extension Bandwidth: Persistable {
    public init(managedObject: BandwidthObject) {
        self.init(
            download: managedObject.download.value!,
            upload: managedObject.upload.value!
        )
    }

    public func toManagedObject() -> BandwidthObject {
        let obj = BandwidthObject()

        obj.download.value = download
        obj.upload.value = upload

        return obj
    }
}

// MARK: - DVPNNodeInfoObject
public class DVPNNodeInfoObject: EmbeddedObject {
    @objc dynamic var address: String?
    @objc dynamic var bandwidth: BandwidthObject?
    @objc dynamic var handshake: HandshakeObject?
    let intervalSetSessions = RealmProperty<Int?>()
    let intervalUpdateSessions = RealmProperty<Int?>()
    let intervalUpdateStatus = RealmProperty<Int?>()
    @objc dynamic var location: LocationObject?
    @objc dynamic var moniker: String?
    @objc dynamic var resultOperator: String?
    let peers = RealmProperty<Int?>()
    @objc dynamic var price: String?
    @objc dynamic var provider: String?
    @objc dynamic var qos: QOSObject?
    let type = RealmProperty<Int?>()
    @objc dynamic var version: String?
}

// MARK: DVPNNodeInfo: Persistable
extension DVPNNodeInfo: Persistable {
    public init(managedObject: DVPNNodeInfoObject) {
        self.init(
            address: managedObject.address!,
            bandwidth: Bandwidth(managedObject: managedObject.bandwidth!),
            handshake: Handshake(managedObject: managedObject.handshake!),
            intervalSetSessions: managedObject.intervalSetSessions.value!,
            intervalUpdateSessions: managedObject.intervalUpdateSessions.value!,
            intervalUpdateStatus: managedObject.intervalUpdateStatus.value!,
            location: Location(managedObject: managedObject.location!),
            moniker: managedObject.moniker!,
            resultOperator: managedObject.resultOperator!,
            peers: managedObject.peers.value!,
            price: managedObject.price!,
            provider: managedObject.provider!,
            qos: managedObject.qos.flatMap { QOS(managedObject: $0) },
            type: managedObject.type.value!,
            version: managedObject.version!
        )
    }

    public func toManagedObject() -> DVPNNodeInfoObject {
        let obj = DVPNNodeInfoObject()

        obj.address = address
        obj.bandwidth = bandwidth.toManagedObject()
        obj.handshake = handshake.toManagedObject()
        obj.intervalSetSessions.value = intervalSetSessions
        obj.intervalUpdateSessions.value = intervalUpdateSessions
        obj.intervalUpdateStatus.value = intervalUpdateStatus
        obj.location = location.toManagedObject()
        obj.moniker = moniker
        obj.resultOperator = resultOperator
        obj.peers.value = peers
        obj.price = price
        obj.provider = provider
        obj.qos = qos?.toManagedObject()
        obj.type.value = type
        obj.version = version

        return obj
    }
}

// MARK: - HandshakeObject
public class HandshakeObject: EmbeddedObject {
    let enable = RealmProperty<Bool?>()
    let peers = RealmProperty<Int?>()
}

// MARK: Handshake: Persistable
extension Handshake: Persistable {
    public init(managedObject: HandshakeObject) {
        self.init(
            enable: managedObject.enable.value!,
            peers: managedObject.peers.value!
        )
    }

    public func toManagedObject() -> HandshakeObject {
        let obj = HandshakeObject()

        obj.enable.value = enable
        obj.peers.value = peers

        return obj
    }
}

// MARK: - LocationObject
public class LocationObject: EmbeddedObject {
    @objc dynamic var city: String?
    @objc dynamic var country: String?
    @objc dynamic var continent: String?
}

// MARK: Location: Persistable
extension Location: Persistable {
    public init(managedObject: LocationObject) {
        self.init(
            city: managedObject.city!,
            country: managedObject.country!,
            continent: managedObject.continent!,
            latitude: 0,
            longitude: 0
        )
    }

    public func toManagedObject() -> LocationObject {
        let obj = LocationObject()

        obj.city = city
        obj.country = country
        obj.continent = continent

        return obj
    }
}

// MARK: - QOSObject
public class QOSObject: EmbeddedObject {
    let maxPeers = RealmProperty<Int?>()
}

// MARK: QOS: Persistable
extension QOS: Persistable {
    public init(managedObject: QOSObject) {
        self.init(
            maxPeers: managedObject.maxPeers.value!
        )
    }

    public func toManagedObject() -> QOSObject {
        let obj = QOSObject()

        obj.maxPeers.value = maxPeers

        return obj
    }
}

// MARK: - CoinTokenObject
public class CoinTokenObject: EmbeddedObject {
    @objc dynamic var denom: String?
    @objc dynamic var amount: String?
}

// MARK: CoinToken: Persistable
extension CoinToken: Persistable {
    public init(managedObject: CoinTokenObject) {
        self.init(
            denom: managedObject.denom!,
            amount: managedObject.amount!
        )
    }

    public func toManagedObject() -> CoinTokenObject {
        let obj = CoinTokenObject()

        obj.denom = denom
        obj.amount = amount

        return obj
    }
}

// swiftlint:enable force_unwrapping
