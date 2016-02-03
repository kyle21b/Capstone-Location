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

typealias RFSample = [RFIdentifier: RSSI]

struct RFTrainingSample {
    let intensity: RFSample
    let location: Location
}

private func makeFormatter() -> NSNumberFormatter {
    let formatter = NSNumberFormatter()
    formatter.maximumSignificantDigits = 5;
    return formatter
}

struct Location: CustomStringConvertible {
    let x: Double
    let y: Double
    let floor: Int
    
    init(x: Double, y: Double, floor: Int = 0) {
        self.x = x
        self.y = y
        self.floor = floor
    }
    
    var description: String {
        return "(x: \(x), y: \(y))"
    }
}

extension Location {
    func distanceToLocation(location: Location) -> Double {
        return hypot(x - location.x, y - location.y)
    }
}

func * (location: Location, multiplier: Double) -> Location {
    return Location(x: location.x*multiplier, y: location.y*multiplier, floor: location.floor)
}

func / (location: Location, divisor: Double) -> Location {
    return Location(x: location.x/divisor, y: location.y/divisor, floor: location.floor)
}

func + (left: Location, right: Location) -> Location {
    assert(left.floor == right.floor)
    return Location(x: left.x+right.x, y: left.y+right.y, floor: left.floor)
}


