//
//  Untitled.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 4/27/25.
//
import EstimoteUWB


class EstimoteUWBManagerExample: NSObject, ObservableObject {
    // environment variables
    private var connNumber : Int = 5
    private var timeToLive: Double = 10.0
    
    
    // class variables
    private var uwbManager: EstimoteUWBManager?
    private var distances = Dictionary<String, Distances>(minimumCapacity: 3)
    private var trilateration: Trilateration
    
    override init() {
        let json_map = MapReader.readCoordinates(from: "casa.json")
        self.trilateration = Trilateration(map: json_map)
    
        super.init()
        self.setupUWB()
        self.timeoutObserver()
    }
    
    private func timeoutObserver(){
        // Start a timer on a background queue
        DispatchQueue.global(qos: .background).async {
            while true {
                let currentTime = Date().timeIntervalSince1970
                
                DispatchQueue.main.async {
                    for (deviceID, distance_obj) in self.distances {
                        if currentTime - distance_obj.timestamp > self.timeToLive {
                            self.uwbManager?.disconnect(from: deviceID)
                            self.distances.removeValue(forKey: deviceID)
                        }
                    }
                }
                
                // Sleep to avoid busy loop
                Thread.sleep(forTimeInterval: 1.0)
            }
        }
    }
    

    private func setupUWB() {
        uwbManager = EstimoteUWBManager(delegate: self,
                                        options: EstimoteUWBOptions(shouldHandleConnectivity: false,
                                                                    isCameraAssisted: false))
        uwbManager?.startScanning()
        
       
    }
}

// REQUIRED PROTOCOL
extension EstimoteUWBManagerExample: EstimoteUWBManagerDelegate {
    func didUpdatePosition(for device: EstimoteUWBDevice) {
        self.distances[device.publicIdentifier] = Distances(distance: device.distance, timestamp: Date().timeIntervalSince1970)
        let top3 = self.trilateration.pickCoordinates(distances: self.distances)
        let coord: Coordinate = self.trilateration.tirlaterate(top3Distances: top3)
        print("Estimated Position: \(coord)")
    }
    
    // OPTIONAL
    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager) {
        print("Discovered: \(device)")
        if self.distances[device.publicIdentifier] == nil && self.distances.count < self.connNumber {
            self.distances[device.publicIdentifier] = Distances(distance: 0, timestamp: Date().timeIntervalSince1970)
            self.uwbManager?.connect(to: device.publicIdentifier)
        }
    }
    
    // OPTIONAL
    func didConnect(to device: UWBIdentifiable) {
        
    }
    
    // OPTIONAL
    func didDisconnect(from device: UWBIdentifiable, error: Error?) {
        self.distances[device.publicIdentifier] = nil
    }
    
    // OPTIONAL
    func didFailToConnect(to device: UWBIdentifiable, error: Error?) {
        print("Could not connect to: \(device.publicIdentifier)")
    }
}

