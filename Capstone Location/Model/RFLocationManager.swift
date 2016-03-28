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
    internal let floorPlanConfiguration: FloorPlanConfiguration
   
    private var flannMatcher: Flann?
    private var samples = [RFTrainingSample]()
    
    var delegate: RFLocationManagerDelegate? = nil
    
    var location: Location?
    
    init(sensorManager: RFSensorManager, database: RFSampleDatabase, floorPlanConfiguration: FloorPlanConfiguration) {
        self.database = database
        self.sensorManager = sensorManager
        self.floorPlanConfiguration = floorPlanConfiguration
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RFLocationManager.updateFlannMatcher), name: RFSampleDatabaseDidUpdateKey, object: database)
        
        sensorManager.delegate = self
        updateFlannMatcher()
    }
    
    let missingRSSIValue: RSSI = -140
    
    func updateFlannMatcher() {
        let intensities = database.samples.map { sample in
            floorPlanConfig.baseStations.map { stationID in
                return sample.sample[stationID] ?? missingRSSIValue
            }
        }
        
        guard intensities.count > 0 else { return }
        
        flannMatcher = Flann(dataSet: intensities)
    }

    func manager(manager: RFSensorManager, didUpdateDevice device: RFDevice) {
        if let location = predictLocationForIntensity(manager.sample()) {
            self.location = location
            delegate?.locationManager(self, didUpdateLocation: location)
        }
    }
    
    private func weightForSignalStrengthDistance(distance: Double) -> Double {
        return 100 / (1 + pow(distance, 1))
    }
    
    func predictLocationForIntensity(intensity: RFSample, nNeighbors: Int = 5) -> Location? {
        guard let flannMatcher = flannMatcher else { return nil }

        let intensityVector = floorPlanConfiguration.baseStations.map { intensity[$0] ?? missingRSSIValue }
        
        let flannMatches = flannMatcher.findNearestNeighbors(intensityVector, nNeighbors: nNeighbors)
        let neighbors = flannMatches.map { (database.samples[$0], $1) }
        
        let totalWeight = neighbors.reduce(0) { $0 + weightForSignalStrengthDistance($1.1) }
        
        let centroid = neighbors.reduce(Point(x: 0, y: 0)) {
            let point = floorPlanConfiguration.locationOfSquare($1.0.square).point
            return $0 + point * (weightForSignalStrengthDistance($1.1) / totalWeight)
        }
        
        return Location(point: centroid, floor: 0)
    }
    
    func startUpdatingLocation() {
        sensorManager.startScanning()
    }
    
    func stopUpdatingLocation() {
        sensorManager.stopScanning()
    }
}

extension GridSquare {
    func locationOnFloorPlan(floorPlan: FloorPlanConfiguration) -> Location {
        return Location(x: 0, y: 0)
    }
}

extension RFLocationManager {
    func computeReprojectionError(trainingSample: RFTrainingSample) -> Double {
        let estimatedLocation = predictLocationForIntensity(trainingSample.sample)!
        return floorPlanConfiguration.locationOfSquare(trainingSample.square).distanceToLocation(estimatedLocation)
    }
}
