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

struct FloorSquare {
    let label: String
    let floor: Int
}

extension FloorSquare {
    var description: String {
        return label
    }
}

struct RFTrainingSample {
    let location: FloorSquare
    let sample: RFSample
    let nameStamp: String
    let timeStamp: NSDate
}

extension RFTrainingSample: CustomStringConvertible {
    var description: String {
        return timeStamp.description
    }
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
    
    var averageRSSI: RSSI? {
        let rssiValues = measurements.filter { $0.timestamp.timeIntervalSinceNow >= -4 }.map { $0.RSSI }
        if rssiValues.count == 0 { return nil }
        return sma(rssiValues, count: rssiValues.count)
    }
    
    func sma(array: [Double], count: Int) -> Double {
        let suffix = array.suffix(count)
        let total = suffix.reduce(0) { $0 + $1 }
        return total / Double(suffix.count)
    }
    
    mutating func recordRssi(rssi: RSSI) {
        let measurement = (rssi, NSDate())
        measurements.append(measurement)
    }
    
    var displayName: String {
        if let name = name {
            return "\(name) \(identifier)"
        }
        return identifier
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

let RFSampleDatabaseDidUpdateKey = "RFSampleDatabaseDidUpdate"
protocol RFSampleDatabase: AnyObject {
    init(baseStations: [RFIdentifier])
    var baseStations: [RFIdentifier] { get }
    
    var samples: [RFTrainingSample] { get }
    func addSample(trainingSample: RFTrainingSample)
    func removeSample(trainingSample: RFTrainingSample)
}

extension RFSampleDatabase {
    func notifyDidUpdate() {
        NSNotificationCenter.defaultCenter().postNotificationName(RFSampleDatabaseDidUpdateKey, object: self)
    }
}

