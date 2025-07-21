//
//  PositionCoordinator.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 7/20/25.
//

import Foundation

class PositionCoordinator{
    var connectedDevices: Set<String> = []
    var anchors: [String: Anchor] = [:]
    
    var anchorsPositions: [String: Vector3D]
    var connectionLimit: Int
    var connectionTimeout: Double
    
    // Manager instances
    var uwbManager: UWBManager
    var accelerometerManager: AccelerometerManager
    
    
    init(anchorsPositions: [String: Vector3D], connectionLimit: Int, connectionTimeout: Double, uwbManager: UWBManager, accelerometerManager: AccelerometerManager){
        self.anchorsPositions = anchorsPositions
        self.connectionLimit = connectionLimit
        self.connectionTimeout = connectionTimeout
        
        // Manager instances
        self.uwbManager = uwbManager
        self.accelerometerManager = accelerometerManager
    }
    
    func getAnchor(deviceID: String, distance: Double) -> Anchor{
        return Anchor(
            id: deviceID,
            position: anchorsPositions[deviceID]!,
            distance: distance,
            timestamp: Date().timeIntervalSince1970
        )
    }
    
}

extension PositionCoordinator: UWBManagerDelegate{
    
    func didDisconnect(deviceId: String) {
        // we remove the item from the list of connected devices
        self.connectedDevices.remove(deviceId)
        
        // we remove the item from the map [deviceId: Anchor]
        self.anchors.removeValue(forKey: deviceId)
    }
    
    func didConnect(deviceId: String) {
        // we add the device from the list of connected devices
        self.connectedDevices.insert(deviceId)
    }
    
    func onDeviceDiscovered(deviceId: String, rssi: Double) {
        // if the device detected is not on our map we won't connect to it
        if !anchorsPositions.keys.contains(deviceId) {
            return
        }
        
        // if we are under our connection limit and the device is in our map we can connect to it
        if connectedDevices.count < self.connectionLimit{
            self.uwbManager.connectTo(deviceID: deviceId)
        }
    }
    
    func didUpdatePosition(deviceId: String, distance: Double) {
        // 1. We update
        var anchor = getAnchor(deviceID: deviceId, distance: distance)
        self.anchors[deviceId] = anchor
        
        // 2. We check and remove anchors who exceeded the timout
        let now = Date().timeIntervalSince1970
        
        self.anchors = self.anchors.filter { (_, anchor) in
            guard let timestamp = anchor.timestamp else {
                return true // keep anchors without timestamp (Shouldn't really happen)
            }
            return now - timestamp <= self.connectionTimeout
        }
        
    }
    
}

extension PositionCoordinator: AccelerometerDelegate{
    func onUpdate(vector: Vector3D) {
        <#code#>
    }
}
