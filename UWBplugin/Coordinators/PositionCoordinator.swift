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
    var lastTime = Date().timeIntervalSince1970
    
    var anchorsPositions: [String: Vector3D]
    var connectionLimit: Int
    var connectionTimeout: Double
    
    // Manager instances
    var uwbManager: UWBManager?
    var accelerometerManager: AccelerometerManager?
    
    // Filtered Position
    var filteredPos: Vector2D? = nil
    
    
    init(anchorsPositions: [String: Vector3D], connectionLimit: Int, connectionTimeout: Double){
        self.anchorsPositions = anchorsPositions
        self.connectionLimit = connectionLimit
        self.connectionTimeout = connectionTimeout
    }
    
    func getAnchor(deviceID: String, distance: Double) -> Anchor{
        return Anchor(
            id: deviceID,
            position: anchorsPositions[deviceID]!,
            distance: distance,
            timestamp: Date().timeIntervalSince1970
        )
    }
    
    func getFilteredPosition() -> Vector2D?{
        return self.filteredPos
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
        print("Connected to device \(deviceId)")
    }
    
    func onDeviceDiscovered(deviceId: String, rssi: Double) {
        // if the device detected is not on our map we won't connect to it
        print("Discovered device \(deviceId)")
        
        if !anchorsPositions.keys.contains(deviceId) {
            return
        }
        
        // if we are under our connection limit and the device is in our map we can connect to it
        if connectedDevices.count < self.connectionLimit{
            self.uwbManager?.connectTo(deviceID: deviceId)
        }
    }
    
    func didUpdatePosition(deviceId: String, distance: Double) {
        // 1. We update
        let anchor = getAnchor(deviceID: deviceId, distance: distance)
        self.anchors[deviceId] = anchor
        
        // 2. We check and remove anchors who exceeded the timout
        let now = Date().timeIntervalSince1970
        
        self.anchors = self.anchors.filter { (_, anchor) in
            guard let timestamp = anchor.timestamp else {
                return true // keep anchors without timestamp (Shouldn't really happen)
            }
            return now - timestamp <= self.connectionTimeout
        }
        
        // 3. We compute trilateration
        if self.anchors.count < 3{
            return
        }
        
        let position = do_trilateration(anchors: self.anchors)
        
        // 4. We pass our computed position through the Kalman Filter
        KalmanFilter.shared.update(z: position.toSIMD())
        let filtered = KalmanFilter.shared.getX()
        let first = filtered[0]
        let second = filtered[1]
        
        self.filteredPos = Vector2D(x: first, y: second)
        print(String(describing: filteredPos))
    }
    
}

extension PositionCoordinator: AccelerometerDelegate{
    func onUpdate(vector: Vector2D) {
        let currentTime = Date().timeIntervalSince1970
        let deltaTime = currentTime - lastTime
        
        if KalmanFilter.shared.getX() == .zero{
            return
        }
        
        let simd2d = vector.toSIMD()
        
        KalmanFilter.shared.updateG(delta_time: deltaTime)
        KalmanFilter.shared.updateF(delta_time: deltaTime)
        
        KalmanFilter.shared.updateU(simd2d)
        KalmanFilter.shared.predict()
    }
}
    
