//
//  UWBManager.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 7/20/25.
//
import EstimoteUWB


class UWBManager{
    var delegate: UWBManagerDelegate
    var manager: EstimoteUWBManager
    var UWBQueue: OperationQueue
    
    init(delegate: UWBManagerDelegate, UWBQueue: OperationQueue){
        self.UWBQueue = UWBQueue
        self.delegate = delegate
        self.manager = EstimoteUWBManager(delegate: self, options: EstimoteUWBOptions(shouldHandleConnectivity: false, isCameraAssisted: false))
    }
    
    func connectTo(deviceID: String){
        UWBQueue.addOperation {
            self.manager.connect(to: deviceID)
        }
    }
    
    func disconnectFrom(deviceId: String){
        UWBQueue.addOperation{
            self.manager.disconnect(from: deviceId)
        }
    }
    
    func startScanning(){
        UWBQueue.addOperation {
            self.manager.startScanning()
        }
    }
    
    func stopScanning(){
        UWBQueue.addOperation {
            self.manager.stopScanning()
        }
    }
}

extension UWBManager: EstimoteUWBManagerDelegate{
    func didUpdatePosition(for device: EstimoteUWBDevice){
        self.UWBQueue.addOperation {
            self.delegate.didUpdatePosition(deviceId: device.publicIdentifier, distance: device.distance)
        }
    }
    
    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager){
        self.UWBQueue.addOperation {
            self.delegate.onDeviceDiscovered(deviceId: device.publicIdentifier, rssi: Double(truncating: rssi))
        }
    }
    
    func didConnect(to device: UWBIdentifiable){
        self.UWBQueue.addOperation {
            self.delegate.didConnect(deviceId: device.publicIdentifier)
        }
    }
    
    func didDisconnect(from device: UWBIdentifiable, error: Error?){}
    
    func didFailToConnect(to device: UWBIdentifiable, error: Error?){}
}
