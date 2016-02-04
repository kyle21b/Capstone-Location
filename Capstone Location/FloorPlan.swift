//
//  Coordinates.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/2/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation
import MapKit

struct CoordinateSpace<T: FloatingPointType> {
    let xSpan, ySpan: ClosedInterval<T>
}

let worldCoordinateSpace = CoordinateSpace<Double>(xSpan: -180...180, ySpan: -90...90)

let floorPlanConfig: AnchoredFloorPlanConfiguation = {
    let a1 = (
        image: FloorPoint(x: 284, y: 192),
        world: WorldPoint(latitude: 40.521807, longitude: -74.461135)
    )

    let a2 = (
        image: FloorPoint(x: 1773, y: 3395),
        world: WorldPoint(latitude: 40.521776, longitude: -74.460533)
    )
    
    let imageCoordinateSpace = CoordinateSpace<Double>(xSpan: 0...2085-1, ySpan: 0...3584-1)

    return AnchoredFloorPlanConfiguation(imageCoordinateSpace: imageCoordinateSpace, beaconLocations: [:], a1: a1, a2: a2)
}()

class FloorPlanConfiguration {
    let imageCoordinateSpace: CoordinateSpace<Double>
    let beaconLocations: [RFIdentifier: FloorPoint]
    
    init(imageCoordinateSpace: CoordinateSpace<Double>, beaconLocations: [RFIdentifier: FloorPoint]) {
        self.imageCoordinateSpace = imageCoordinateSpace
        self.beaconLocations = beaconLocations
    }
}

class AnchoredFloorPlanConfiguation: FloorPlanConfiguration {
    typealias AnchorPoint = (image: FloorPoint, world: WorldPoint)
    let a1, a2: AnchorPoint
    
    let transformation: CGAffineTransform
    let imagePointsPerMeter: Double
    
    init(imageCoordinateSpace: CoordinateSpace<Double>, beaconLocations: [RFIdentifier: FloorPoint], a1: AnchorPoint, a2: AnchorPoint) {
        self.a1 = a1
        self.a2 = a2
        
        let (transformation, imagePointsPerMeter, _) = AnchoredFloorPlanConfiguation.transformationFromWorldToImage(a1, a2)
        
        self.transformation = transformation
        self.imagePointsPerMeter = imagePointsPerMeter
        
        super.init(imageCoordinateSpace: imageCoordinateSpace, beaconLocations: beaconLocations)
    }
    
    class func directionBetweenPoints<T: PointType>(sourcePoint: T, _ destinationPoint: T) -> Double {
        let x = destinationPoint.x - sourcePoint.x
        let y = destinationPoint.y - sourcePoint.y
        
        return atan2(x, y)
    }
    
    class func transformationFromWorldToImage(a1: AnchorPoint, _ a2: AnchorPoint) -> (transform: CGAffineTransform, imagePointsPerMeter: Double, angle: Double) {
        let p2 = MKMapPointForCoordinate(a2.world)
        let p1 = MKMapPointForCoordinate(a1.world)
        
        let meters = MKMetersBetweenMapPoints(p1, p2)
        let image = hypot(a2.image.x - a1.image.x, a2.image.y - a1.image.y)
        
        let imagePointsPerMeter = image/meters
    
        let thetaF = directionBetweenPoints(p1, p2)
        let thetaG = directionBetweenPoints(a1.image, a2.image)
        
        let angle = thetaF - thetaG
        
        let scale = CGAffineTransformMakeScale(CGFloat(imagePointsPerMeter), CGFloat(imagePointsPerMeter))
        let rotation = CGAffineTransformMakeRotation(CGFloat(angle))
        
        return (CGAffineTransformConcat(scale, rotation), imagePointsPerMeter, angle)
    }
    
    func convertToWorld(imagePoint: FloorPoint) -> WorldPoint {
        let imageFromAnchorPoint = Point(x: imagePoint.x - a1.image.x, y: imagePoint.y - a1.image.y).toCGPoint()
       
        let affine = CGAffineTransformInvert(transformation)
        let metersUser = CGPointApplyAffineTransform(imageFromAnchorPoint, affine)
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
        
        let imageFromAnchorPoint = CGPointApplyAffineTransform(metersUser, transformation).toPoint()
        
        return Point(x: imageFromAnchorPoint.x + a1.image.x, y: imageFromAnchorPoint.y + a1.image.y)
    }
}

extension FloorPlanView {
    func convertFromScreenCoordinate(point: ScreenPoint) -> FloorPoint {
        let imageSize = image!.size
        let viewSize = bounds.size;
        let scale = imagePerPixelScale
        let sizeDiff = CGSizeMake((viewSize.width - imageSize.width*scale)/2, (viewSize.height - imageSize.height*scale)/2)
        let affine = CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale), CGAffineTransformMakeTranslation(sizeDiff.width, sizeDiff.height))
        return CGPointApplyAffineTransform(point, affine).toPoint()
    }
    
    func convertToScreenCoordinate(point: PointType) -> ScreenPoint {
        let imageSize = image!.size
        let viewSize = bounds.size;
        let scale = imagePerPixelScale
        let sizeDiff = CGSizeMake((viewSize.width - imageSize.width*scale)/2, (viewSize.height - imageSize.height*scale)/2)
        let affine = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-sizeDiff.width, -sizeDiff.height), CGAffineTransformMakeScale(1/scale, 1/scale))
        return CGPointApplyAffineTransform(point.toCGPoint(), affine)
    }
    
    var imagePerPixelScale: CGFloat {
        let imageSize = image!.size
        let viewSize = bounds.size
        return min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
    }
}
