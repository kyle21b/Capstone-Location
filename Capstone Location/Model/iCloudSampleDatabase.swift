//
//  iCloudSampleDatabase.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/17/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

class iCloudSampleDatabase: RFSampleDatabase {
    let baseStations: [RFIdentifier]
    var samples: [RFTrainingSample]
    
    required init(baseStations: [RFIdentifier]) {
        self.baseStations = baseStations
        self.samples = iCloudSampleDatabase.getSamplesFromDB()
    }
    
    class func getSamplesFromDB() -> [RFTrainingSample] {
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        let predicate = NSPredicate(format:"TRUEPREDICATE")
        let query = CKQuery(recordType: "TrainingSample", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            if (error != nil)
            {
                print("theres an error")
            }
            else
            {
                let objects = results
                return objects.flatMap{RFTrainingSample(parseObject: $0) }
            }
            
        }
        
    }
    
    func addSample(trainingSample: RFTrainingSample) {
        trainingSample.save()
        samples.append(trainingSample)
        notifyDidUpdate()
    }
    
    func removeSample(trainingSample: RFTrainingSample) {
        fatalError()
    }
}

private extension Location {
    init?(recordObject: CKRecord) {
        
        guard recordObject.recordType == "Location",
            let x = recordObject.objectForKey("x") as? Double,
            y = recordObject.objectForKey("y") as? Double,
            floor = recordObject.objectForKey("floor") as? Int else { return nil }
        
        self.init(x: x, y: y, floor: floor)
    }
    func asRecord() -> CKRecord {
        let record = CKRecord(recordType: "Locations")
        record.setObject(point.x, forKey: "x")
        record.setObject(point.y, forKey: "y")
        record.setObject(floor, forKey: "floor")
        return record
    }
}

private extension RFTrainingSample {
    init?(parseObject: CKRecord) {
        guard parseObject.recordType == "RFTrainingSample",
            let parseLocation = parseObject.objectForKey("location") as? PFObject,
            location = Location(parseObject: parseLocation),
            sample = parseObject.objectForKey("sample") as? RFSample,
            nameStamp = parseObject.objectForKey("nameStamp") as? String else { return nil }
        
        self.init(location: location, sample: sample, nameStamp: nameStamp, timeStamp: parseObject.createdAt!)
    }
    
    func save() {
        let location = self.location.asRecord()
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        publicData.saveRecord(location, completionHandler: {(record:CKRecord?, error:NSError?) -> Void in
            if error != nil{
                print(error)
            }
            let trainingSample =  CKRecord(recordType: "RFTrainingSample")
            
            trainingSample.setObject(location, forKey: "location")
            trainingSample.setObject(self.sample, forKey: "sample")
            trainingSample.setObject(self.nameStamp, forKey: "nameStamp")
            publicData.saveRecord(trainingSample, completionHandler: {(record:CKRecord?, error:NSError?) -> Void in
                if error != nil{
                    print(error)
                }
                
            })
        })
    }
}