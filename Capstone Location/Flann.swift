//
//  Flann.swift
//  Flann
//
//  Created by Kyle Bailey on 12/10/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation

public typealias Neighbor = (index: Int, distance: Double)

public class Flann {
    
    private let dataSet: [[Double]]
    
    private let rows: Int
    private let columns: Int
    
    public init(dataSet: [[Double]]) {
        self.dataSet = dataSet

        rows = dataSet.count
        columns = dataSet.first!.count
        
        for data in dataSet {
            assert(data.count == columns)
        }
    }

    /*
    public func findNearestNeighbors(testPoints: [[Double]], nNeighbors: Int) -> [Neighbor] {
        for point in testPoints {
            assert(point.count == columns)
        }
        var neighbors = dataSet.enumerate().map { ($0, findDistance(testPoints, point: $1)) }
        neighbors.sortInPlace { $0.1 < $1.1 }
        return Array(neighbors.prefix(nNeighbors))
    }*/
    
    public func findNearestNeighbors(testPoint: [Double], nNeighbors: Int) -> [Neighbor] {
        assert(testPoint.count == columns)

        var neighbors = dataSet.enumerate().map { ($0, findDistance(testPoint, point: $1)) }
        neighbors.sortInPlace { $0.1 < $1.1 }
        return Array(neighbors.prefix(nNeighbors))
    }
    
    public func radiusSearch(testPoint: [Double], radius: Double, maxN: Int = Int.max) -> [Neighbor] {
        assert(testPoint.count == columns)

        var neighbors = dataSet.enumerate().flatMap { (index: Int, element: [Double]) -> Neighbor? in
            let distance = findDistance(testPoint, point: element)
            guard distance <= Double(radius) else { return nil }
            return (index, distance)
        }
        neighbors.sortInPlace { $0.1 < $1.1 }
        return Array(neighbors.prefix(maxN))
    }
}

private func findDistance(testPoints: [[Double]], point: [Double]) -> Double {
    let distances = testPoints.map { findDistance($0, point: point) }
    return distances.minElement()!
}

private func findDistance(testPoint: [Double], point: [Double]) -> Double {
    return length(testPoint + neg(point))
}

public func length(vector: [Double]) -> Double {
    return sqrt(sum(vector * vector))
}