//
//  Flann.swift
//  Flann
//
//  Created by Kyle Bailey on 12/10/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation

public class Flann {
    public typealias Neighbor = (index: Int, distance: Double)

    private let dataSet: [[Double]]
    
    private let rows: Int
    private let columns: Int
    
    public init(dataSet: [[Double]]) {
        self.dataSet = dataSet

        rows = dataSet.count
        columns = dataSet.first?.count ?? 0
        
        for data in dataSet {
            assert(data.count == columns)
        }
    }

    public func findNearestNeighbors(testPoint: [Double], nNeighbors: Int) -> [Neighbor] {
        if rows == 0 { return [] }
        
        assert(testPoint.count == columns)

        var neighbors = dataSet.enumerate().map { ($0, findDistance(testPoint, point: $1)) }
        neighbors.sortInPlace { $0.1 < $1.1 }
        return Array(neighbors.prefix(nNeighbors))
    }
    
    public func radiusSearch(testPoint: [Double], radius: Double) -> [Neighbor] {
        assert(testPoint.count == columns)

        let neighbors = dataSet.enumerate().flatMap { (index: Int, element: [Double]) -> Neighbor? in
            let distance = findDistance(testPoint, point: element)
            guard distance <= Double(radius) else { return nil }
            return (index, distance)
        }

        return neighbors.sort { $0.1 < $1.1 }
    }
}

/*
private func findDistance(testPoints: [[Double]], point: [Double]) -> Double {
    let distances = testPoints.map { findDistance($0, point: point) }
    return distances.minElement()!
}*/

private func findDistance(testPoint: [Double], point: [Double]) -> Double {
    assert(testPoint.count == point.count)
    var total: Double = 0
    for i in 0..<testPoint.count {
        let difference = testPoint[i] - point[i]
        total = hypot(total, difference)
    }
    return total
}
