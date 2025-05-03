//
//  Untitled.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 4/27/25.
//
import SwiftUI
import EstimoteUWB

struct ContentView: View {
    let uwb = EstimoteUWBManagerExample()
    
    var body: some View {
        Text("Estimote UWB")
            .padding()
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
    }
    
    // OPTIONAL
    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager) {
        // there is a connection
        if let objectiveDevice = self.objectiveDevice{
            print("Already connected to \(objectiveDevice), devide \(device) tried to connect")
        // there is not a connection yet
        }else{
            self.objectiveDevice = device
            print("Connecting to \(device.publicIdentifier)")
            self.uwbManager?.connect(to: device)
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
