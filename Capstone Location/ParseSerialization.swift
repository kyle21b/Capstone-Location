//
//  ParseSerialization.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/6/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation
import Parse

private extension Location {
    func asPFObject() -> PFObject {
        let object = PFObject(className: "Location")
        object["x"] = point.x
        object["y"] = point.y
        object["floor"] = floor
        return object
    }
}

extension RFIdentifier {
    func stripDashes() -> String {
        return stringByReplacingOccurrencesOfString("-", withString: "")
    }
}

extension RFTrainingSample {
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

