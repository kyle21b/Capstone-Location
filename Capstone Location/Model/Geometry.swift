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
    let point: FloorPoint
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

extension CGPoint {
    func applyTransform(transform: Transform) -> CGPoint {
        return CGPointApplyAffineTransform(self, transform)
    }
}

extension PointType {
    
}

typealias Transform = CGAffineTransform
extension Transform {
    static func scale(scaleFactor: CGFloat) -> Transform {
        return CGAffineTransformMakeScale(scaleFactor, scaleFactor)
    }
    
    static func rotate(rotation: CGFloat) -> Transform {
        return CGAffineTransformMakeRotation(rotation)
    }
    
    static func translate(x: CGFloat, y: CGFloat) -> Transform {
        return CGAffineTransformMakeTranslation(x, y)
    }
    
    func concat(transform: Transform) -> Transform {
        return CGAffineTransformConcat(self, transform)
    }
    
    func invert() -> Transform {
        return CGAffineTransformInvert(self)
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

extension AnchoredFloorPlanConfiguation {
    class func directionBetweenPoints<T: PointType>(sourcePoint: T, _ destinationPoint: T) -> Double {
        let x = destinationPoint.x - sourcePoint.x
        let y = destinationPoint.y - sourcePoint.y
        
        return atan2(x, y)
    }
    
    class func transformationFromWorldToImage(a1: AnchorPoint, _ a2: AnchorPoint) -> (imagePointsPerMeter: Double, angle: Double) {
        let p2 = MKMapPointForCoordinate(a2.world)
        let p1 = MKMapPointForCoordinate(a1.world)
        
        let meters = MKMetersBetweenMapPoints(p1, p2)
        let image = hypot(a2.floor.x - a1.floor.x, a2.floor.y - a1.floor.y)
        
        let imagePointsPerMeter = image/meters
        
        let thetaF = directionBetweenPoints(p1, p2)
        let thetaG = directionBetweenPoints(a1.floor, a2.floor)
        
        let angle = thetaF - thetaG
        
        return (imagePointsPerMeter, angle)
    }
    
    func convertToWorld(floorPoint: FloorPoint) -> WorldPoint {
        let imageFromAnchorPoint = Point(x: floorPoint.x - a1.floor.x, y: floorPoint.y - a1.floor.y).toCGPoint()
        
        let metersUser = imageFromAnchorPoint.applyTransform(transformation.invert())
        let metersScale = MKMetersPerMapPointAtLatitude(a1.world.latitude)
        
        let p1 = MKMapPointForCoordinate(a1.world)
        
        let pointUser = MKMapPoint(x: Double(metersUser.x) / metersScale + p1.x, y: Double(metersUser.y) / metersScale + p1.y)
        
        return MKCoordinateForMapPoint(pointUser)
    }
    
    func convertFromWorld(worldPoint: WorldPoint) -> FloorPoint {
        let pointUser = MKMapPointForCoordinate(worldPoint)
        let p1 = MKMapPointForCoordinate(a1.world)
        
        let metersScale = MKMetersPerMapPointAtLatitude(a1.world.latitude)
        let metersUser = CGPoint(x: (pointUser.x - p1.x) * metersScale, y: (pointUser.y - p1.y) * metersScale)
        
        let imageFromAnchorPoint = metersUser.applyTransform(transformation).toPoint()
        
        return Point(x: imageFromAnchorPoint.x + a1.floor.x, y: imageFromAnchorPoint.y + a1.floor.y)
    }
}


extension FloorPlanScrollView {
    var imagePerPixelScale: CGFloat {
        let imageSize = floorPlanView.image!.size
        let viewSize = bounds.size
        return min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
    }
    
    var screenTransform: Transform {
        return Transform.scale(CGFloat(imagePerPixelScale))
        /*
        let imageSize = floorPlanView.image!.size
        let viewSize = bounds.size;
        
        let scaleFactor = CGFloat(imagePerPixelScale)
        
        let scale = Transform.scale(scaleFactor)
        
        
        let sizeDiff = CGSizeMake((viewSize.width - imageSize.width*scaleFactor)/2, (viewSize.height - imageSize.height*scaleFactor)/2)
        let translate = Transform.translate(sizeDiff.width, y: sizeDiff.height)
        
        return scale.concat(translate)*/
    }
    
    func convertFromScreen(point: ScreenPoint) -> FloorPoint {
        return point.applyTransform(screenTransform.invert()).toPoint()
    }
    
    func convertToScreen(point: FloorPoint) -> ScreenPoint {
        return point.toCGPoint().applyTransform(screenTransform)
    }
}
