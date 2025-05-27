//
//  MapReader.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 5/26/25.
//
import Foundation


class MapReader {
    static func readCoordinates(from fileName: String) -> [String: Coordinate] {
        // Separate name and extension
        let fileComponents = fileName.split(separator: ".")
        guard fileComponents.count == 2 else {
            print("Invalid filename format. Expected 'name.extension'")
            return [:]
        }

        let name = String(fileComponents[0])
        let ext = String(fileComponents[1])

        // Look for the file inside the 'Maps' folder in the app bundle
        guard let fileURL = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("File not found in bundle")
            return [:]
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let result = try decoder.decode([String: Coordinate].self, from: data)
            return result
        } catch {
            print("Failed to read or decode JSON: \(error)")
            return [:]
        }
    }
}
