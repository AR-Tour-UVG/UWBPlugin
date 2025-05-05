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

            if !uwb.distances.isEmpty {
                ForEach(Array(uwb.distances), id: \.key) { key, value in
                        Text(String(format: "Device %@: %.2f meters", key, value))
                            .font(.headline)
                            .padding()
                }
            } else {
                Text("No devices connected")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class EstimoteUWBManagerExample: NSObject, ObservableObject {
    private var uwbManager: EstimoteUWBManager?
    private var objectiveDevice: UWBIdentifiable?
    @Published public var distances = Dictionary<String, Float>(minimumCapacity: 3)
    
    override init() {
        super.init()
        setupUWB()
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
        print("Update possition for \(device.publicIdentifier) at distance: \(device.distance)")
        DispatchQueue.main.async {
            self.distances[device.publicIdentifier] = device.distance  // 👈 Update here
        }
    }
    
    // OPTIONAL
    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager) {
        // there is a connection
        if !self.distances.keys.contains(device.publicIdentifier){
            self.distances[device.publicIdentifier] = 0
            manager.connect(to: device.publicIdentifier)
        }else{
            print("Already connected to \(device.publicIdentifier)")
        }
    }
    
    // OPTIONAL
    func didConnect(to device: UWBIdentifiable) {
        print("Connected to \(device)")
    }
    
    // OPTIONAL
    func didDisconnect(from device: UWBIdentifiable, error: Error?) {
        
    }
    
    // OPTIONAL
    func didFailToConnect(to device: UWBIdentifiable, error: Error?) {
        print("Could not connect to: \(device.publicIdentifier)")
    }

    // OPTIONAL PROTOCOL FOR BEACON BLE RANGING
//    func didRange(for beacon: EstimoteBLEDevice) {
//        print("Beacon did range: \(beacon)")
//    }
}
