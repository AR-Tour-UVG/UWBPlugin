//
//  ViewModel.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 7/21/25.
//
import Foundation


class ViewModel{
    // these should be environment variables
    var mapURL = "casa.json"
    var refreshRate = Float(0.1)
    var connectionLimit = 6
    var connectionTimout = 10.0
    
    var anchorMap: [String: Vector3D]
    
    init(){
        // We first read the Campus Map
        self.anchorMap = MapReader.readCoordinates(from: mapURL)
        
        //We initialize a single operation queue for the Accelerometer and UWB modules
        let queue = OperationQueue()
        queue.name = "UWB and Accelerometer queue"
        queue.maxConcurrentOperationCount = 1
        
        let posCoordinator = PositionCoordinator(anchorsPositions: anchorMap, connectionLimit: connectionLimit, connectionTimeout: connectionTimout)
        
        let accelerometerManager = AccelerometerManager(refreshRate: refreshRate, delegate: posCoordinator, accelerometerQueue: queue)
        let uwbManager = UWBManager(delegate: posCoordinator, UWBQueue: queue)
        uwbManager.startScanning()
        accelerometerManager.startListening()
        
        // IMPORTANT: add the delegates to the Position Coordinator
        posCoordinator.accelerometerManager = accelerometerManager
        posCoordinator.uwbManager = uwbManager
    }
}
