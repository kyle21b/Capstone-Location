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

class RFLocationManager: NSObject, RFSensorManagerDelegate {
    internal let database: RFSampleDatabase
    internal let sensorManager: RFSensorManager
   
    private var flannMatcher: Flann!
    
    var delegate: RFLocationManagerDelegate? = nil
    
    var location: Location?
    
    init(model: RFSensorManager, database: RFSampleDatabase) {
        self.database = database
        self.sensorManager = model
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFlannMatcher", name: RFSampleDatabaseDidUpdateKey, object: database)
        
        sensorManager.delegate = self
        updateFlannMatcher()
    }
    
    let missingRSSIValue: RSSI = -140
    
    func updateFlannMatcher() {
        let intensities = database.samples.map { sample in
            database.baseStations.map { stationID in
                return sample.sample[stationID] ?? missingRSSIValue
            }
        }
        
        flannMatcher = Flann(dataSet: intensities)
    }

    func manager(manager: RFSensorManager, didUpdateDevice device: RFDevice) {
        let location = predictLocationForIntensity(manager.sample())
        self.location = location
        delegate?.locationManager(self, didUpdateLocation: location)
    }
    
    private func weightForSignalStrengthDistance(distance: Double) -> Double {
        return 100 / (1 + pow(distance, 1))
    }
    
    /*
    func predictLocationForIntensity(intensity: RFSample) -> Location? {
        let intensityVector = database.baseStations.map { intensity[$0] ?? missingRSSIValue }
        
        let flannMatches = flannMatcher.findNearestNeighbors(intensityVector, nNeighbors: 1)
        let neighbors = flannMatches.map { (database.samples[$0], $1) }
        
        return neighbors.first?.0.location
    }*/
    
    func predictLocationForIntensity(intensity: RFSample, nNeighbors: Int = 3) -> Location {
        let intensityVector = database.baseStations.map { intensity[$0] ?? missingRSSIValue }
        
        let flannMatches = flannMatcher.findNearestNeighbors(intensityVector, nNeighbors: nNeighbors)
        let neighbors = flannMatches.map { (database.samples[$0], $1) }
        
        /*
        let floor = 1
        let matchingNeighbors = neighbors
        for (sample, _) in matchingNeighbors {
            assert(sample.location.floor == floor)
        }*/
        
        let totalWeight = neighbors.reduce(0) { $0 + weightForSignalStrengthDistance($1.1) }
        
        let centroid = neighbors.reduce(Point(x: 0, y: 0)) {
            $0 + $1.0.location.point * (weightForSignalStrengthDistance($1.1) / totalWeight)
        }
        
        return Location(point: centroid, floor: 1)
    }
    
    func startUpdatingLocation() {
        sensorManager.startScanning()
    }
    
    func stopUpdatingLocation() {
        sensorManager.stopScanning()
    }
}

extension RFLocationManager {
    func computeReprojectionError(trainingSample: RFTrainingSample) -> Double {
        let estimatedLocation = predictLocationForIntensity(trainingSample.sample)
        return trainingSample.location.distanceToLocation(estimatedLocation)
    }
}
