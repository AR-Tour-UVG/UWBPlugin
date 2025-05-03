//
//  Untitled.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 4/27/25.
//
import EstimoteUWB


class UWBManager : NSObject, ObservableObject {
    
    @Published private var lastVal: Float = 0.0
    private var uwbManager: EstimoteUWBManager?
    
    override init(){
        super.init()
        setupUWB()
    }
    
    func getLastVal() -> Float{
        return lastVal
    }
    
    func setLastVal(newVal: Float){
        DispatchQueue.main.async { 
                self.lastVal = newVal
        }
    }
    
    private func setupUWB() {
        uwbManager = EstimoteUWBManager(delegate: self,
                                        options: EstimoteUWBOptions(shouldHandleConnectivity: true,
                                                                    isCameraAssisted: false))
        uwbManager?.startScanning()
    }
    
    
}

extension UWBManager: EstimoteUWBManagerDelegate {
    
    func didUpdatePosition(for device: EstimoteUWBDevice) {
        print("Position updated for device: \(device)")
        print("distance: \(device.distance)")
        setLastVal(newVal: device.distance)
    }
    
    // OPTIONAL
    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager) {
        print("Discovered device: \(device.publicIdentifier) rssi: \(rssi)")
        // if shouldHandleConnectivity is set to true - then you could call manager.connect(to: device)
        // additionally you can globally call discoonect from the scope where you have inititated EstimoteUWBManager -> disconnect(from: device) or disconnect(from: publicId)
    }
    
    // OPTIONAL
    func didConnect(to device: UWBIdentifiable) {
        print("Successfully connected to: \(device.publicIdentifier)")
    }
    
    // OPTIONAL
    func didDisconnect(from device: UWBIdentifiable, error: Error?) {
        print("Disconnected from device: \(device.publicIdentifier)- error: \(String(describing: error))")
    }
    
    // OPTIONAL
    func didFailToConnect(to device: UWBIdentifiable, error: Error?) {
        print("Failed to conenct to: \(device.publicIdentifier) - error: \(String(describing: error))")
    }
}
