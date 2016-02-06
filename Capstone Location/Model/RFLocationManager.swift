//
//  BluetoothEstimator.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 12/28/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation

protocol RFLocationManagerDelegate {
    func locationManager(manager: RFLocationManager, didUpdateLocation location: Location)
}

class RFLocationManager: RFSensorManagerDelegate {
    internal let database: RFSampleDatabase
    internal let sensorModel: RFSensorManager
   
    private let flannMatcher: Flann
    
    var delegate: RFLocationManagerDelegate? = nil
    
    var location: Location?
    
    init(model: RFSensorManager, dataBase: RFSampleDatabase) {
        self.database = dataBase
        self.sensorModel = model
        
        let intensities = dataBase.samples.map { sample in
            dataBase.baseStations.map { stationID in
                sample.sample[stationID]! ?? -140
            }
        }
        
        flannMatcher = Flann(dataSet: intensities)
        
        sensorModel.delegate = self
    }

    func model(model: RFSensorManager, didUpdateDevice device: RFDevice) {
        location = predictLocationForIntensity(model.sample())
    }
    
    private func weightForSignalStrengthDistance(distance: Double) -> Double {
        return 100 / (1 + pow(distance, 1))
    }
    
    func predictLocationForIntensity(intensity: RFSample, nNeighbors: Int = 5) -> Location {
        let intensityVector = database.baseStations.map { intensity[$0]! }
        
        let flannMatches = flannMatcher.findNearestNeighbors(intensityVector, nNeighbors: nNeighbors)
        let neighbors = flannMatches.map { (database.samples[$0], $1) }
        
        let floor = 1
        let matchingNeighbors = neighbors
        for (sample, _) in matchingNeighbors {
            assert(sample.location.floor == floor)
        }
        
        let totalWeight = neighbors.reduce(0) { $0 + weightForSignalStrengthDistance($1.1) }
        
        let centroid = neighbors.reduce(Point(x: 0, y: 0)) {
            $0 + $1.0.location.point * (weightForSignalStrengthDistance($1.1) / totalWeight)
        }
        
        return Location(point: centroid, floor: floor)
    }
    
    func startUpdatingLocation() {
        sensorModel.startScanning()
    }
    
    func stopUpdatingLocation() {
        sensorModel.stopScanning()
    }
}

extension RFLocationManager {
    func computeReprojectionError(trainingSample: RFTrainingSample) -> Double {
        let estimatedLocation = predictLocationForIntensity(trainingSample.sample)
        return trainingSample.location.distanceToLocation(estimatedLocation)
    }
}
