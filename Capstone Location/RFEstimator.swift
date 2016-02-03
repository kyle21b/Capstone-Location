//
//  BluetoothEstimator.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 12/28/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation

protocol RFLocationEstimatorDelegate {
    func locationEstimator(estimator: RFLocationEstimator, didUpdateLocation location: Location)
}

class RFLocationEstimator: RFSensorModelDelegate {
    private let database: RFSampleDatabase
    private let sensorModel: RFSensorModel
   
    private let flannMatcher: Flann
    
    var delegate: RFLocationEstimatorDelegate?
    
    var location: Location?
    
    init(model: RFSensorModel, dataBase: RFSampleDatabase, delegate: RFLocationEstimatorDelegate) {
        self.database = dataBase
        self.sensorModel = model
        self.delegate = delegate
        
        let intensities = dataBase.samples.map { sample in
            dataBase.baseStations.map { stationID in
                sample.intensity[stationID]! ?? -140
            }
        }
        
        flannMatcher = Flann(dataSet: intensities)
        
        self.sensorModel.delegate = self
    }

    func model(model: RFSensorModel, didUpdateDevice device: RFDevice) {
        location = predictLocationForIntensity(model.sample(), nNeighbors: 5)
    }
    
    func predictLocationForIntensity(intensity: RFSample, nNeighbors: Int) -> Location {
        let intensityVector = database.baseStations.map { intensity[$0]! }
        
        let flannMatches = flannMatcher.findNearestNeighbors(intensityVector, nNeighbors: nNeighbors)
        let neighbors = flannMatches.map { (database.samples[$0], $1) }
        
        let totalWeight = neighbors.reduce(0) { $0 + weightForSignalStrengthDistance($1.1) }
        
        let floor = 1
        let matchingNeighbors = neighbors
        for (sample, _) in matchingNeighbors {
            assert(sample.location.floor == floor)
        }
        
        return neighbors.reduce(Location(x: 0, y: 0, floor: floor)) { $0 + $1.0.location * (weightForSignalStrengthDistance($1.1) / totalWeight) }
    }
    
    func startUpdatingLocation() {
        sensorModel.startScanning()
    }
    
    func stopUpdatingLocation() {
        sensorModel.stopScanning()
    }
    
    private func weightForSignalStrengthDistance(distance: Double) -> Double {
        return 100 / (1 + pow(distance, 1))
    }
}
