//
//  Defines.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/3/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation
import MapKit

typealias WorldPoint = CLLocationCoordinate2D
typealias FloorPoint = Point
typealias ScreenPoint = CGPoint

protocol PointType {
    var x: Double { get }
    var y: Double { get }
}

struct Point: PointType {
    let x, y: Double
}

extension MKMapPoint: PointType {}

extension PointType {
    func toCGPoint() -> CGPoint { return CGPoint(x: x, y: y) }
}

extension CGPoint {
    func toPoint() -> Point { return Point(x: Double(x), y: Double(y)) }
}

struct Location {
    let point: Point
    let floor: Int
    
    init(x: Double, y: Double, floor: Int = 0) {
        self.point = Point(x: x,y: y)
        self.floor = floor
    }
    
    init(point: Point, floor: Int = 0) {
        self.point = point
        self.floor = floor
    }
}

extension Location: CustomStringConvertible {
    var description: String {
        return "(x: \(point.x), y: \(point.y))"
    }
}

extension PointType {
    func distanceToPoint(point: Self) -> Double {
        return hypot(x - point.x, y - point.y)
    }
}

extension Location {
    func distanceToLocation(location: Location) -> Double {
        assert(floor == location.floor)
        return point.distanceToPoint(location.point)
    }
}

func * (location: Point, multiplier: Double) -> Point {
    return Point(x: location.x*multiplier, y: location.y*multiplier)
}

func / (location: Point, divisor: Double) -> Point {
    return Point(x: location.x/divisor, y: location.y/divisor)
}

func + (left: Point, right: Point) -> Point {
    return Point(x: left.x+right.x, y: left.y+right.y)
}

extension CLLocation {
    convenience init(location: CLLocationCoordinate2D) {
        self.init(latitude: location.latitude, longitude: location.longitude)
    }
}

extension CLLocationCoordinate2D {
    func distanceFromCoordinate(coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        return CLLocation(location: self).distanceFromLocation(CLLocation(location: coordinate))
    }
}


