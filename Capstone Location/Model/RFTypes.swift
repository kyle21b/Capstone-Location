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

protocol StateMachine {
    var state: State { get }
}

typealias RFIdentifier = String
typealias RSSI = Double

typealias RFSample = [RFIdentifier: RSSI]

struct RFTrainingSample {
    let location: Location
    let sample: RFSample
}

struct RFDevice {
    typealias Measurement = (RSSI: RSSI, timestamp: NSDate)

    let identifier: RFIdentifier
    
    init(identifier: RFIdentifier) {
        self.identifier = identifier
    }
    
    var name: String?
    var state: String?
    
    var advertisementData = [String: AnyObject]()
    var measurements = [Measurement]()
    
    var rssi: RSSI? {
        return measurements.last?.RSSI
    }
    
    mutating func recordRssi(rssi: RSSI) {
        let measurement = (rssi, NSDate())
        measurements.append(measurement)
    }
    
    var displayName: String {
        return name ?? identifier
    }
}

protocol RFSensorManagerDelegate {
    func manager(manager: RFSensorManager, didUpdateDevice device: RFDevice)
}

protocol RFSensorManager {
    var delegate: RFSensorManagerDelegate? { get set }
    
    var state: State { get }
    func startScanning()
    func stopScanning()
    
    var devices: [RFDevice] { get }
    
    func sample() -> RFSample
}

protocol RFSampleDatabase {
    init(baseStations: [RFIdentifier])
    var baseStations: [RFIdentifier] { get }
    
    var samples: [RFTrainingSample] { get }
    func addSample(trainingSample: RFTrainingSample)
}

