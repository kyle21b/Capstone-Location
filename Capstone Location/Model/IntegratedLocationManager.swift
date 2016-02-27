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
    var delegate: IntegratedLocationManagerDelegate?
    
    override init() {
        self.locationManager = RFLocationManager(model: BluetoothSensorManager(), database: sampleDatabase)
        self.motionManager = CMMotionManager()
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: RFLocationManager, didUpdateLocation location: Location) {
        delegate?.locationManager(self, didUpdateLocation: location)
    }

}