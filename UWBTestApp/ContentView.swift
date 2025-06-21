//
//  Untitled.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 4/27/25.
//
import SwiftUI
import EstimoteUWB

struct ContentView: View {
    @ObservedObject var uwb = EstimoteUWBManagerExample()
    
    var body: some View {
        VStack {
            Text("Estimote UWB")
                .font(.title)
                .padding()            
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class EstimoteUWBManagerExample: NSObject, ObservableObject {
    // environment variables
    private var connNumber : Int = 5
    private var timeToLive: Double = 10.0
    
    
    // class variables
    private var uwbManager: EstimoteUWBManager?
    private var distances = Dictionary<String, Distances>(minimumCapacity: 3)
    private var trilateration: Trilateration
    private var place_map: [String: Coordinate]
    
    override init() {
        place_map = MapReader.readCoordinates(from: "315b.json")
        self.trilateration = Trilateration(map: place_map)
    
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
        // we update the distance
        self.distances[device.publicIdentifier] = Distances(distance: abs(device.distance), timestamp: Date().timeIntervalSince1970)
        
        // we get top 3 candidates for trilateration
        let top3 = self.trilateration.pickCoordinates(distances: self.distances)
        
        let coord: Coordinate
        if top3.count == 3{
            coord = self.trilateration.tirlaterate(top3Distances: top3)
            print("Position: \(coord)")
            print("Timestamp: \(Date().timeIntervalSince1970)")
            
        }else{
            // print("Connected to: \(top3.count)")
        }
        
        
    }
    
    // OPTIONAL
    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager) {
        print("Discovered: \(device.publicIdentifier)")
        print(self.distances[device.publicIdentifier] == nil)
        
        // We can only connect to the sensor if it is on the place_map
        guard place_map[device.publicIdentifier] != nil else {
                return 
        }
        
        // if device is not on distnces dictionary AND the length of the dicrionary is less than the max connection number
        if self.distances[device.publicIdentifier] == nil && self.distances.count < self.connNumber {
            // self.distances[device.publicIdentifier] = Distances(distance: 0, timestamp: Date().timeIntervalSince1970)
            self.uwbManager?.connect(to: device.publicIdentifier)
        }
    }
    
    // OPTIONAL
    func didConnect(to device: UWBIdentifiable) {
        print("Connected to: \(device)")
    }
    
    // OPTIONAL
    func didDisconnect(from device: UWBIdentifiable, error: Error?) {
        DispatchQueue.main.async {
            self.distances[device.publicIdentifier] = nil
        }
    }
    
    // OPTIONAL
    func didFailToConnect(to device: UWBIdentifiable, error: Error?) {
        print("Could not connect to: \(device.publicIdentifier)")
    }    
}
