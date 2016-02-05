//
//  IntegrationModel.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/2/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation


protocol IntegratedLocationManagerDelegate {
    func locationManager(manager: IntegratedLocationManager, didUpdateLocation location: Location)
}

class IntegratedLocationManager: RFLocationEstimatorDelegate {
    let estimator: RFLocationEstimator
    
    var location: Location? { return estimator.location }
    
    var delegate: IntegratedLocationManagerDelegate?
    
    init(estimator: RFLocationEstimator) {
        self.estimator = estimator
        self.estimator.delegate = self
    }
    
    func locationEstimator(estimator: RFLocationEstimator, didUpdateLocation location: Location) {
        delegate?.locationManager(self, didUpdateLocation: location)
    }
}