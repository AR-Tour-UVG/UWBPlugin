//
//  Trilateration.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 5/22/25.
//

import Foundation

class Trilateration{
    private var map: Dictionary<String, Coordinate>
    
    init(map: Dictionary<String, Coordinate>){
        self.map = map
    }
    
    public func pickCoordinates(distances: Dictionary<String, Distances>) -> Array<(key: String, value: Distances)>{
        let top3 = distances
            .sorted { $0.value.timestamp > $1.value.timestamp }
            .prefix(3)
        
        return Array(top3)
    }
    
    public func tirlaterate(top3Distances: Array<(key: String, value: Distances)>) -> Coordinate{
        // Preallocate array of capacity 3 (empty but optimized for 3 elements)
        var distance_point_pairs = [ (Float, Coordinate) ]()
        distance_point_pairs.reserveCapacity(3)
        
        for (key, distance) in top3Distances {
            if let coord = map[key] {
                distance_point_pairs.append((distance.distance, coord))
            }
        }
        
        let result: Coordinate = self.tirlaterate_3D(distance_coord: distance_point_pairs)
        return result
    }
    
    private func tirlaterate_3D(distance_coord: [(Float, Coordinate)]) -> Coordinate{
        let d1: Float = distance_coord[0].0
        let x1: Float = distance_coord[0].1.x
        let y1: Float = distance_coord[0].1.y
        let z1: Float = distance_coord[0].1.z
        
        let d2: Float = distance_coord[1].0
        let x2: Float = distance_coord[1].1.x
        let y2: Float = distance_coord[1].1.y
        let z2: Float = distance_coord[1].1.z
        
        let d3: Float = distance_coord[2].0
        let x3: Float = distance_coord[2].1.x
        let y3: Float = distance_coord[2].1.y
        let z3: Float = distance_coord[2].1.z
        
        
        // First EQ
        let A = 2 * (x1 - x2)
        let B = 2 * (y1 - y2)
        let C = 2 * (z1 - z2)
        // let D = pow(d2, 2) - (d1 ** 2) - (x2 ** 2) - (y2 ** 2) - (z2 ** 2) + (x1 ** 2) + (y1 ** 2) + (z1 ** 2)
        let D = pow(d2, 2) - pow(d1,2) - pow(x2,2) - pow(y2,2) - pow(z2,2) + pow(x1, 2) + pow(y1, 2) + pow(z1, 2)
        
        // Second EQ
        let E = 2 * (x1 - x3)
        let F = 2 * (y1 - y3)
        let G = 2 * (z1 - z3)
        let H = pow(d3, 2) - pow(d1, 2) - pow(x3, 2) - pow(y3, 2) - pow(z3, 2) + pow(x1, 2) + pow(y1, 2) + pow(z1, 2)

        // Aux EQ
        let afeb = (A * F - E * B)

        let alpha = (-B * G + C * F) / afeb
        let beta = (-B * H + D * F) / afeb

        let phi = (A * G - E * C) / afeb
        let roh = (A * H - E * D) / afeb

        // Coefficients
        let first = pow(alpha, 2) + pow(phi, 2) + 1
        let second = -(2 * alpha * beta) + (2 * x1 * alpha) - (2 * phi * roh) + (2 * y1 * phi) - (2 * z1)
        let third = pow(beta, 2) + pow(x1, 2) - (2 * x1 * beta) + pow(roh, 2) + pow(y1, 2) - (2 * y1 * roh) + pow(z1, 2) - pow(d1, 2)
        
        let discriminant = pow(second, 2) - 4 * first * third
        
        var z: Float = 0.0
        
        if discriminant > 0 {
            if let value = self.solveQuadratic(a: first, b: second, c: third, discriminant: discriminant){
                z = value[0]
            }
        }
        
        let x = beta - alpha * z
        let y = roh - phi * z
        return Coordinate(x: x, y: y, z: z)
    }
    
    private func solveQuadratic(a: Float, b: Float, c: Float, discriminant: Float) -> [Float]? {
        guard a != 0 else { return nil } // Not a quadratic
        guard discriminant >= 0 else { return nil } // No real roots

        let sqrtDisc = sqrt(discriminant)
        let root1 = (-b + sqrtDisc) / (2 * a)
        let root2 = (-b - sqrtDisc) / (2 * a)
        return [root1, root2]
    }
    
}
