//
//  RFSampleDatabase.swift
//  Flann
//
//  Created by Kyle Bailey on 12/10/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation
import CoreLocation
import Parse

class ParseSampleDatabase: RFSampleDatabase {
    var samples: [RFTrainingSample] = []
    let baseStations: [RFIdentifier]
    
    required init(baseStations: [RFIdentifier]) {
        self.baseStations = baseStations
    }
    
    func addSample(trainingSample: RFTrainingSample) {
        trainingSample.save()
    }
}

