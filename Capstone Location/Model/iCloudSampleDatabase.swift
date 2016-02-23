//
//  iCloudSampleDatabase.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/17/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation
import CloudKit

class iCloudSampleDatabase: RFSampleDatabase {
    required init(baseStations: [RFIdentifier]) {
        self.baseStations = baseStations
        self.samples = []
    }
    
    let baseStations: [RFIdentifier]
    var samples: [RFTrainingSample]
    
    func addSample(trainingSample: RFTrainingSample) {
        samples.append(trainingSample)
        notifyDidUpdate()
        fatalError()
    }
    
    func removeSample(trainingSample: RFTrainingSample) {
        fatalError()
    }
}