//
//  Flann.swift
//  Flann
//
//  Created by Kyle Bailey on 12/10/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation

private extension String {
    var cString: [Int8] {
        return nulTerminatedUTF8.map { Int8($0) }
    }
}

private extension Array {
    func unflatten(rows rows: Int, columns: Int) -> [[Element]] {
        return (0..<rows).map {
            let start = $0 * columns
            let end = ($0 + 1) * columns
            return Array(self[start..<end])
        }
    }
}

public typealias Neighbor = (index: Int, distance: Double)

public class Flann {
    private var parameters: FLANNParameters = DEFAULT_FLANN_PARAMETERS
    private let index: flann_index_t
    
    private let rows: Int
    private let columns: Int
    
    public init(dataSet: [[Double]], parameters: FLANNParameters = DEFAULT_FLANN_PARAMETERS) {
        self.parameters = parameters

        let rows = dataSet.count
        let columns = dataSet.first!.count
        
        self.rows = rows
        self.columns = columns
        
        var data = Array(dataSet.flatten())
        index = flann_build_index_double(&data, Int32(rows), Int32(columns), nil, &self.parameters)
    }
    
    deinit {
        flann_free_index_double(index, &parameters)
    }

    private func searchHelper(nNeighbors: Int, searchFunction: (inout [Int32], inout [Double]) -> (Int32)) -> [Neighbor] {
        var indicies = [Int32](count: nNeighbors, repeatedValue: 0)
        var distances = [Double](count: nNeighbors, repeatedValue: 0)
        
        let n = searchFunction(&indicies, &distances)
        guard n > 0 else { return [] }
        
        let neighbors: [Neighbor] = (0..<Int(n)).map { (Int(indicies[$0]), distances[$0]) }

        for (_, distance) in neighbors {
            assert(!distance.isNaN)
        }

        return neighbors
    }
    
    public func radiusSearch(var testPoint: [Double], radius: Float, maxN: Int) -> [Neighbor] {
        assert(testPoint.count == columns)
        return searchHelper(maxN) { (inout indicies: [Int32], inout distances: [Double]) -> (Int32) in
            flann_radius_search_double(self.index, &testPoint, &indicies, &distances, Int32(maxN), radius + FLT_EPSILON, &self.parameters)
        }
    }
    
    public func findNearestNeighbors(testPoint: [Double], nNeighbors: Int) -> [Neighbor] {
        return findNearestNeighbors([testPoint], nNeighbors: nNeighbors)
    }
    
    public func findNearestNeighbors(testPoints: [[Double]], nNeighbors: Int) -> [Neighbor] {
        for point in testPoints {
            assert(point.count == columns)
        }
        var flattened = Array(testPoints.flatten())
        return searchHelper(nNeighbors) { (inout indicies: [Int32], inout distances: [Double]) -> (Int32) in
            Flann.flann_find_nearest_neighbors_wrapper(self.index, &flattened, Int32(testPoints.count), &indicies, &distances, Int32(nNeighbors), &self.parameters)
        }
    }
    
    private static func flann_find_nearest_neighbors_wrapper(index_ptr: flann_index_t, _ testset: UnsafeMutablePointer<Double>, _ tcount: Int32, _ result: UnsafeMutablePointer<Int32>, _ dists: UnsafeMutablePointer<Double>, _ nn: Int32, _ flann_params: UnsafeMutablePointer<FLANNParameters>) -> Int32 {
        let result = flann_find_nearest_neighbors_index_double(index_ptr, testset, tcount, result, dists, nn, flann_params);
        return result == 0 ? nn : result
    }
    
    public func computeClusterCenters(dataSet: [[Double]], clusters: Int) -> [[Double]] {
        for point in dataSet {
            assert(point.count == columns)
        }
        var data = Array(dataSet.flatten())
        var result = [Double](count: clusters * columns, repeatedValue: 0)
        let numClusters = flann_compute_cluster_centers_double(&data, Int32(rows), Int32(columns), Int32(clusters), &result, &parameters)
        guard numClusters > 0 else { return [] }
        return result.unflatten(rows: Int(numClusters), columns: columns)
    }
    
    public init(filename: String, rows: Int, cols: Int) {
        var chars = filename.cString
        index = flann_load_index_double(&chars, nil, Int32(rows), Int32(cols))
        
        self.rows = rows
        self.columns = cols
    }
    
    public func saveIndex(filename: String) {
        var chars = filename.cString
        flann_save_index_double(index, &chars)
    }
    
    public static func setLogVerbosity(level: Int) {
        flann_log_verbosity(Int32(level))
    }
    
    public static func setDistanceType(distanceType: flann_distance_t, order: Int = 0) {
        flann_set_distance_type(distanceType, Int32(order))
    }
}

/*
private extension String {
var cString: [Int8] {
return nulTerminatedUTF8.map { Int8($0) }
}
}

private extension Array {
func unflatten(rows rows: Int, columns: Int) -> [[Element]] {
return (0..<rows).map {
let start = $0 * columns
let end = ($0 + 1) * columns
return Array(self[start..<end])
}
}
}

public typealias Neighbor = (index: Int, distance: Double)

public class Flann {
private var parameters: FLANNParameters = DEFAULT_FLANN_PARAMETERS
private let index: flann_index_t

private let rows: Int
private let columns: Int

public init(dataSet: [[Double]], parameters: FLANNParameters = DEFAULT_FLANN_PARAMETERS) {
self.parameters = parameters

let rows = dataSet.count
let columns = dataSet.first!.count

self.rows = rows
self.columns = columns

var data = Array(dataSet.flatten())
index = flann_build_index_double(&data, Int32(rows), Int32(columns), nil, &self.parameters)
}

deinit {
flann_free_index_double(index, &parameters)
}

private func searchHelper(nNeighbors: Int, searchFunction: (inout [Int32], inout [Double]) -> (Int32)) -> [Neighbor] {
var indicies = [Int32](count: nNeighbors, repeatedValue: 0)
var distances = [Double](count: nNeighbors, repeatedValue: 0)

let n = searchFunction(&indicies, &distances)
guard n > 0 else { return [] }

let neighbors: [Neighbor] = (0..<Int(n)).map { (Int(indicies[$0]), distances[$0]) }

for (_, distance) in neighbors {
assert(!distance.isNaN)
}

return neighbors
}

public func radiusSearch(var testPoint: [Double], radius: Float, maxN: Int) -> [Neighbor] {
assert(testPoint.count == columns)
return searchHelper(maxN) { (inout indicies: [Int32], inout distances: [Double]) -> (Int32) in
flann_radius_search_double(self.index, &testPoint, &indicies, &distances, Int32(maxN), radius + FLT_EPSILON, &self.parameters)
}
}

public func findNearestNeighbors(testPoint: [Double], nNeighbors: Int) -> [Neighbor] {
return findNearestNeighbors([testPoint], nNeighbors: nNeighbors)
}

public func findNearestNeighbors(testPoints: [[Double]], nNeighbors: Int) -> [Neighbor] {
for point in testPoints {
assert(point.count == columns)
}
var flattened = Array(testPoints.flatten())
return searchHelper(nNeighbors) { (inout indicies: [Int32], inout distances: [Double]) -> (Int32) in
Flann.flann_find_nearest_neighbors_wrapper(self.index, &flattened, Int32(testPoints.count), &indicies, &distances, Int32(nNeighbors), &self.parameters)
}
}

private static func flann_find_nearest_neighbors_wrapper(index_ptr: flann_index_t, _ testset: UnsafeMutablePointer<Double>, _ tcount: Int32, _ result: UnsafeMutablePointer<Int32>, _ dists: UnsafeMutablePointer<Double>, _ nn: Int32, _ flann_params: UnsafeMutablePointer<FLANNParameters>) -> Int32 {
let result = flann_find_nearest_neighbors_index_double(index_ptr, testset, tcount, result, dists, nn, flann_params);
return result == 0 ? nn : result
}

public func computeClusterCenters(dataSet: [[Double]], clusters: Int) -> [[Double]] {
for point in dataSet {
assert(point.count == columns)
}
var data = Array(dataSet.flatten())
var result = [Double](count: clusters * columns, repeatedValue: 0)
let numClusters = flann_compute_cluster_centers_double(&data, Int32(rows), Int32(columns), Int32(clusters), &result, &parameters)
guard numClusters > 0 else { return [] }
return result.unflatten(rows: Int(numClusters), columns: columns)
}

public init(filename: String, rows: Int, cols: Int) {
var chars = filename.cString
index = flann_load_index_double(&chars, nil, Int32(rows), Int32(cols))

self.rows = rows
self.columns = cols
}

public func saveIndex(filename: String) {
var chars = filename.cString
flann_save_index_double(index, &chars)
}

public static func setLogVerbosity(level: Int) {
flann_log_verbosity(Int32(level))
}

public static func setDistanceType(distanceType: flann_distance_t, order: Int = 0) {
flann_set_distance_type(distanceType, Int32(order))
}
}
*/
