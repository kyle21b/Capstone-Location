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

struct AnchorPoint {
    let floor: FloorPoint
    let world: WorldPoint
}

class FloorPlanConfiguration: DictionaryConvertible {
    let images: [FloorPlanImage]
    let initialFloor: Int
    
    let beacons: [RFIdentifier]
    
    init(images: [FloorPlanImage], initialFloor: Int = 0, beacons: [RFIdentifier]) {
        self.images = images
        self.initialFloor = initialFloor
        self.beacons = beacons
    }
    
    required init?(dictionary: AnyDictionary) {
        fatalError()
    }
    
    func asDictionary() -> AnyDictionary {
        return [
            "image": images.map { $0.asDictionary() },
            "beacons": beacons,
        ]
    }
}

class AnchoredFloorPlanConfiguation: FloorPlanConfiguration {
    let a1, a2: AnchorPoint
    
    let transformation: Transform
    let imagePointsPerMeter: Double
    
    init(images: [FloorPlanImage], initialFloor: Int = 0, beacons: [RFIdentifier], a1: AnchorPoint, a2: AnchorPoint) {
        self.a1 = a1
        self.a2 = a2
        
        let (imagePointsPerMeter, angle) = AnchoredFloorPlanConfiguation.transformationFromWorldToImage(a1, a2)
        
        let scale = Transform.scale(CGFloat(imagePointsPerMeter))
        let rotation = Transform.rotate(CGFloat(angle))
        
        self.transformation = scale.concat(rotation)
        self.imagePointsPerMeter = imagePointsPerMeter
        
        super.init(images: images, initialFloor: initialFloor, beacons: beacons)
    }
    
    required init?(dictionary: AnyDictionary) {
        fatalError()
    }
    
    override func asDictionary() -> AnyDictionary {
        return super.asDictionary() + [
            "a1" : a1.asDictionary(),
            "a2" : a2.asDictionary()
        ]
    }
}
