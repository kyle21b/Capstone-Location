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

extension DictionaryConvertible {
    var parseClassName: String {
        return String(self.dynamicType)
    }

    init?(parseObject: PFObject) {
        var dict = AnyDictionary()
        for key in parseObject.allKeys {
            dict[key] = parseObject.valueForKey(key)
        }
        self.init(dictionary: dict)
    }
    
    func asParseObject() -> PFObject {
        return PFObject(className: self.parseClassName, dictionary: self.asDictionary())
    }
}

class ParseSampleDatabase: RFSampleDatabase {
    let baseStations: [RFIdentifier]
    
    var samplesBySquare = [GridSquare: [RFTrainingSample]]()
    var samples: [RFTrainingSample] {
        return Array(samplesBySquare.values.flatten())
    }
    
    static var onceToken: dispatch_once_t = 0

    required init(baseStations: [RFIdentifier]) {
        dispatch_once(&ParseSampleDatabase.onceToken) {
            Parse.setApplicationId("yoUZSuVpCFUZ7JPwv8wOAiRIrDQbY27FwAd037if", clientKey: "y1tAim2rlMYOQqS6Mrlplb10dV2sclh2AObxa8ZK")
        }
        self.baseStations = baseStations
        reloadSamples()
    }
    
    func reloadSamples() {
        print("reloaded samples")
        
        let query = PFQuery(className: "RFTrainingSample")
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            let samples = objects?.flatMap { RFTrainingSample(parseObject: $0) }
            
            if let samples = samples {
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateWithSamples(samples)
                }
            }
        }
    }
    
    func updateWithSamples(samples: [RFTrainingSample]) {
        var samplesBySquare = [GridSquare: [RFTrainingSample]]()
        for sample in samples {
            var samplesForSquare = samplesBySquare[sample.square] ?? []
            samplesForSquare.append(sample)
            samplesBySquare[sample.square] = samplesForSquare
        }
        self.samplesBySquare = samplesBySquare
        notifyDidUpdate()
    }
    
    func addSample(trainingSample: RFTrainingSample) {
        trainingSample.asParseObject().saveInBackground()
        
        var samples = samplesBySquare[trainingSample.square] ?? []
        samples.append(trainingSample)
        samplesBySquare[trainingSample.square] = samples
        
        notifyDidUpdate()
    }
    
    func removeSample(trainingSample: RFTrainingSample) {
        //let objects = try! PFQuery(className: "RFTrainingSample", predicate: predicate).findObjects()
        fatalError()
    }
    
    func samplesForSquare(square: GridSquare) -> [RFTrainingSample] {
        return samplesBySquare[square] ?? []
    }
}
