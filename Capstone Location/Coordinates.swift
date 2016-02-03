//
//  Coordinates.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/2/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation
import MapKit

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

typealias anchorPoint = (image: CGPoint, geo: CLLocationCoordinate2D)

let a1 = (
    image: CGPoint(x: 284, y: 192),
    geo: CLLocationCoordinate2DMake(40.521807, -74.461135)
)
let a2 = (
    image: CGPoint(x: 1773, y: 3395),
    geo: CLLocationCoordinate2DMake(40.521776, -74.460533)
)

let pixelsPerMeter: CGFloat = {
    let p2 = MKMapPointForCoordinate(a2.geo)
    let p1 = MKMapPointForCoordinate(a1.geo)
    
    let meters = MKMetersBetweenMapPoints(p1, p2)
    let image = hypot(a2.image.x - a1.image.x, a2.image.y - a1.image.y)
    
    return image/CGFloat(meters)
}()

let angle: CGFloat = {
    let p1 = MKMapPointForCoordinate(a1.geo)
    let p2 = MKMapPointForCoordinate(a2.geo)
    
    let thetaF = directionBetweenMapPoints(p1, p2)
    let thetaG = directionBetweenPoints(a1.image, a2.image)
    
    return CGFloat(thetaF - thetaG)
}()

func directionBetweenMapPoints(sourcePoint: MKMapPoint, _ destinationPoint: MKMapPoint) -> Double {
    let x = destinationPoint.x - sourcePoint.x
    let y = destinationPoint.y - sourcePoint.y
    
    return atan2(x, y)
}

func directionBetweenPoints(sourcePoint: CGPoint, _ destinationPoint: CGPoint) -> Double {
    let x = destinationPoint.x - sourcePoint.x
    let y = destinationPoint.y - sourcePoint.y
    
    return Double(atan2(x, y))
}

func pixelCoordinateForWorldCoordinate(world: CLLocationCoordinate2D) -> CGPoint {
    let pointUser = MKMapPointForCoordinate(world)
    let p1 = MKMapPointForCoordinate(a1.geo)
    
    let metersScale = MKMetersPerMapPointAtLatitude(a1.geo.latitude)
    let metersUser = CGPoint(x: (pointUser.x - p1.x) * metersScale, y: (pointUser.y - p1.y) * metersScale)
    
    let affine = CGAffineTransformConcat(CGAffineTransformMakeScale(pixelsPerMeter, pixelsPerMeter), CGAffineTransformMakeRotation(angle))
    let imageFromAnchorPoint = CGPointApplyAffineTransform(metersUser, affine)
    
    return CGPointMake(imageFromAnchorPoint.x + a1.image.x, imageFromAnchorPoint.y + a1.image.y)
}

func worldCoordinateForPixelCoordinate(pixel: CGPoint) -> CLLocationCoordinate2D {
    let imageFromAnchorPoint = CGPointMake(pixel.x - a1.image.x, pixel.y - a1.image.y)
    let affine = CGAffineTransformConcat(CGAffineTransformMakeRotation(-angle), CGAffineTransformMakeScale(1/pixelsPerMeter, 1/pixelsPerMeter))
    
    let metersUser = CGPointApplyAffineTransform(imageFromAnchorPoint, affine)
    let metersScale = MKMetersPerMapPointAtLatitude(a1.geo.latitude)
    
    let p1 = MKMapPointForCoordinate(a1.geo)
    
    let pointUser = MKMapPoint(x: Double(metersUser.x) / metersScale + p1.x, y: Double(metersUser.y) / metersScale + p1.y)
    
    return MKCoordinateForMapPoint(pointUser)
}

extension RFMapViewController {
    func pointCoordinateForPixelCoordinate(point: CGPoint) -> CGPoint {
        let imageSize = floorPlanView.image!.size
        let viewSize = floorPlanView.bounds.size;
        let scale = imagePerPixelScale
        let sizeDiff = CGSizeMake((viewSize.width - imageSize.width*scale)/2, (viewSize.height - imageSize.height*scale)/2)
        let affine = CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale), CGAffineTransformMakeTranslation(sizeDiff.width, sizeDiff.height))
        return CGPointApplyAffineTransform(point, affine)
    }
    
    func pixelCoordinateForPointCoordinate(point: CGPoint) -> CGPoint {
        let imageSize = floorPlanView.image!.size
        let viewSize = floorPlanView.bounds.size;
        let scale = imagePerPixelScale
        let sizeDiff = CGSizeMake((viewSize.width - imageSize.width*scale)/2, (viewSize.height - imageSize.height*scale)/2)
        let affine = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-sizeDiff.width, -sizeDiff.height), CGAffineTransformMakeScale(1/scale, 1/scale))
        return CGPointApplyAffineTransform(point, affine)
    }
    
    var imagePerPixelScale: CGFloat {
        let imageSize = floorPlanView.image!.size
        let viewSize = floorPlanView.bounds.size
        return min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
    }
}
