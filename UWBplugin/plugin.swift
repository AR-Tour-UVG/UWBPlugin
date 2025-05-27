//
//  plugin.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 5/27/25.
//
import Foundation


let a = EstimoteUWBManagerExample()


@_cdecl("getCoords")
func getCoords() -> UnsafeMutablePointer<CChar> {
    let res = a.getCoords()
    
    let coords: [String: Float] = [
        "x": res.x,
        "y": res.y,
        "z": res.z
    ]
    
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
