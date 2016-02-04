//
//  BluetoothClasses.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/1/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation

enum State {
    case NotReady
    case GettingReady
    case Ready
}

typealias RFIdentifier = String
typealias RSSI = Double
typealias RSSIMeasurement = (RSSI: Double, timestamp: NSDate)

typealias RFSample = [RFIdentifier: RSSI]

struct RFTrainingSample {
    let intensity: RFSample
    let location: Location
}

struct RFDevice {
    let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    var name: String?
    var state: String?
    
    var advertisementData = [String: AnyObject]()
    var measurements = [RSSIMeasurement]()
    
    var rssi: Double? {
        return measurements.last?.RSSI
    }
    
    mutating func recordRssi(rssi: Double) {
        measurements.append((rssi, NSDate()))
    }
    
    var displayName: String {
        return name ?? identifier
    }
}