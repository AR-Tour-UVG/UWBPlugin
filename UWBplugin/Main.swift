//
//  Main.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 7/23/25.
//

import Foundation


let viewModel = ViewModel()
let positionCoordinator = viewModel.getPositionCoordinator()


@_cdecl("getCoords")
public func getCoords() -> UnsafeMutablePointer<CChar> {
    var coords: [String: Any]  // Use 'Any' so we can put Double or nil
        
    if let position = positionCoordinator.getFilteredPosition() {
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
