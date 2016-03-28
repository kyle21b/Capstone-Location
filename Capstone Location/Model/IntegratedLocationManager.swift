//
//  IntegrationModel.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/2/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation
import CoreMotion

protocol IntegratedLocationManagerDelegate {
    func locationManager(manager: IntegratedLocationManager, didUpdateLocation location: Location)
}

class IntegratedLocationManager: NSObject, RFLocationManagerDelegate {
   
    let locationManager: RFLocationManager
    let motionManager: CMMotionManager
    
    var location: Location? { return locationManager.location }
    var heading: Double?
    var delegate: IntegratedLocationManagerDelegate?
    
    override init() {
        self.locationManager = RFLocationManager(sensorManager: BluetoothSensorManager(), database: sampleDatabase, floorPlanConfiguration: floorPlanConfig)
        self.motionManager = CMMotionManager()
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { (motion, error) in
            if let yaw = motion?.attitude.yaw {
                self.heading = -yaw * 180 / M_PI
            } else {
                self.heading = nil
            }
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        motionManager.stopDeviceMotionUpdates()
    }
    
    func locationManager(manager: RFLocationManager, didUpdateLocation location: Location) {
        delegate?.locationManager(self, didUpdateLocation: location)
    }

}