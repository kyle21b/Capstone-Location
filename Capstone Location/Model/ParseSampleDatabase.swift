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
    let samples: [RFTrainingSample]
    let baseStations: [RFIdentifier]
    
    required init(baseStations: [RFIdentifier]) {
        self.baseStations = baseStations
        self.samples = ParseSampleDatabase.getSamplesFromDB()
    }
    
    class func getSamplesFromDB() -> [RFTrainingSample] {
        Parse.setApplicationId("yoUZSuVpCFUZ7JPwv8wOAiRIrDQbY27FwAd037if",
            clientKey: "y1tAim2rlMYOQqS6Mrlplb10dV2sclh2AObxa8ZK")
        let objects = try! PFQuery(className: "RFTrainingSample").findObjects()
        return objects.flatMap { RFTrainingSample(parseObject: $0) }
    }
    
    func addSample(trainingSample: RFTrainingSample) {
        trainingSample.save()
    }
}

private extension Location {
    init?(parseObject: PFObject) {
        try! parseObject.fetchIfNeeded()
        guard parseObject.parseClassName == "Location",
            let x = parseObject["x"] as? Double,
            y = parseObject["y"] as? Double,
            floor = parseObject["floor"] as? Int else { return nil }
        
        self.init(x: x, y: y, floor: floor)
    }
    func asPFObject() -> PFObject {
        let object = PFObject(className: "Location")
        object["x"] = point.x
        object["y"] = point.y
        object["floor"] = floor
        return object
    }
}

private extension RFTrainingSample {
    init?(parseObject: PFObject) {
        guard parseObject.parseClassName == "RFTrainingSample",
            let parseLocation = parseObject["location"] as? PFObject,
            location = Location(parseObject: parseLocation),
            sample = parseObject["sample"] as? RFSample else { return nil }
        
        self.init(location: location, sample: sample)
    }
    func save() {
        let location = self.location.asPFObject()
        location.saveInBackgroundWithBlock { (saved, error) -> Void in
            let trainingSample = PFObject(className: "RFTrainingSample")
            trainingSample["location"] = location
            trainingSample["sample"] = self.sample
            trainingSample.saveInBackgroundWithBlock { (saved, error) -> Void in
                if let error = error {
                    print(error)
                }
            }
        }
    }
}

