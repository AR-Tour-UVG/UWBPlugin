//
//  Main.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 7/23/25.
//

import Foundation


var viewModel:ViewModel? = nil
var positionCoordinator:PositionCoordinator? = nil
var anchorMap: [String: Vector3D]? = nil


@_cdecl("setAnchorMap")
public func setAnchorMap(_ str: UnsafePointer<CChar>?) {
    guard let str = str else {
        fatalError("String parameter is nill")
    }
    let swiftString = String(cString: str)
    let anchorMap_ = MapReader.readCoordinatesFromString(jsonMap: swiftString)
    anchorMap = anchorMap_
}

@_cdecl("start")
public func setAnchorMap() {
    guard anchorMap != nil else{
        fatalError("anchorMap is nill, make sure to assign a value via setAnchorMap function before.")
    }
    viewModel = ViewModel(anchorMap: anchorMap!)
    positionCoordinator = viewModel?.getPositionCoordinator()
}

@_cdecl("getCoords")
public func getCoords() -> UnsafeMutablePointer<CChar> {
    var coords: [String: Any]  // Use 'Any' so we can put Double or nil
    
    if let position = positionCoordinator?.getFilteredPosition() {
        coords = [
            "x": position.x,
            "y": position.y
        ]
    } else {
        coords = [
            "x": NSNull(),  // JSON-compatible representation of null
            "y": NSNull()
        ]
    }
    
    if let jsonData = try? JSONSerialization.data(withJSONObject: coords, options: []),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        
        // Return a C string (null-terminated UTF8)
        let cString = strdup(jsonString)
        return UnsafeMutablePointer(cString!)
    } else {
        // Return an empty JSON object on error
        return strdup("{}")
    }
}

@_cdecl("freeCString")
public func freeCString(_ ptr: UnsafeMutablePointer<CChar>?) {
    if let ptr = ptr {
        free(ptr)
    }
}
