//
//  RFSampleDatabase.swift
//  Flann
//
//  Created by Kyle Bailey on 12/10/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation
import CoreLocation

//Trivial Implementation
class RFSampleDatabase {
    let samples: [RFTrainingSample]
    let baseStations: [RFIdentifier]
    
    init(samples: [RFTrainingSample], baseStations: [String]) {
        self.samples = samples
        self.baseStations = baseStations
    }
}

