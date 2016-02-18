//
//  iCloudSampleDatabase.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/17/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation

class iCloudSampleDatabase: RFSampleDatabase {
    required init(baseStations: [RFIdentifier]) {
        self.baseStations = baseStations
        self.samples = []
    }
    
    let baseStations: [RFIdentifier]
    let samples: [RFTrainingSample]
    
    func addSample(trainingSample: RFTrainingSample) {
        
    }
}