//
//  ViewModel.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 7/21/25.
//
import Foundation


class ViewModel: ObservableObject{
    // these should be environment variables
    var mapURL = "casa.json"
    var refreshRate = Float(0.1)
    var connectionLimit = 6
    var connectionTimout = 10.0
    
    private(set) var anchorMap: [String: Vector3D]?
    private(set) var posCoordinator: PositionCoordinator?
    private(set) var posWrapper: PositionCoordinatorWrapper?
    private var anchorsFileURL: URL?
    
//    init(){
//        // We first read the Campus Map
//        self.anchorMap = MapReader.readCoordinates(from: mapURL)
//        
//        //We initialize a single operation queue for the Accelerometer and UWB modules
//        let queue = OperationQueue()
//        queue.name = "UWB and Accelerometer queue"
//        queue.maxConcurrentOperationCount = 1
//        
//        let posCoordinator = PositionCoordinator(anchorsPositions: anchorMap, connectionLimit: connectionLimit, connectionTimeout: connectionTimout)
//        
//        // Create wrapper for UI binding
//        posWrapper = PositionCoordinatorWrapper(coordinator: posCoordinator)
//        
//        let accelerometerManager = AccelerometerManager(refreshRate: refreshRate, delegate: posCoordinator, accelerometerQueue: queue)
//        let uwbManager = UWBManager(delegate: posCoordinator, UWBQueue: queue)
//        uwbManager.startScanning()
//        accelerometerManager.startListening()
//        
//        // IMPORTANT: add the delegates to the Position Coordinator
//        posCoordinator.accelerometerManager = accelerometerManager
//        posCoordinator.uwbManager = uwbManager
//    }
    
    func setAnchorsFileURL(_ url: URL) {
        anchorsFileURL = url
    }
        
    
    func start() {
        guard let fileURL = anchorsFileURL else {
            fatalError("Anchors file URL not set before calling start()")
        }
        
        // Load anchorsPositions from the JSON file chosen by user
        let anchorsPositions = MapReader.readCoordinates(fromFileURL: anchorsFileURL!)
        
        // Create PositionCoordinator
        let coordinator = PositionCoordinator(
            anchorsPositions: anchorsPositions,
            connectionLimit: 6,
            connectionTimeout: 10
        )
        
        posCoordinator = coordinator
        posWrapper = PositionCoordinatorWrapper()
        posWrapper?.coordinator = coordinator
        
        // Start the managers and queues like before
        let queue = OperationQueue()
        queue.name = "UWB and Accelerometer queue"
        queue.maxConcurrentOperationCount = 1
        
        let accelerometerManager = AccelerometerManager(
            refreshRate: 0.1,
            delegate: coordinator,
            accelerometerQueue: queue
        )
        let uwbManager = UWBManager(delegate: coordinator, UWBQueue: queue)
        
        uwbManager.startScanning()
        accelerometerManager.startListening()
        
        coordinator.accelerometerManager = accelerometerManager
        coordinator.uwbManager = uwbManager
    }
}
