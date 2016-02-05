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

let floorPlanConfig: AnchoredFloorPlanConfiguation = {
    let a1 = AnchorPoint(
        floor: FloorPoint(x: 284, y: 192),
        world: WorldPoint(latitude: 40.521807, longitude: -74.461135)
    )

    let a2 = AnchorPoint(
        floor: FloorPoint(x: 1773, y: 3395),
        world: WorldPoint(latitude: 40.521776, longitude: -74.460533)
    )
    
    let image = FloorPlanImage(named: "img-Y13162350-0001")!

    let config = AnchoredFloorPlanConfiguation(image: image, beaconLocations: [:], a1: a1, a2: a2)
    
    let xmlString = String(data: config.asJSON(), encoding: NSUTF8StringEncoding)!
    print(xmlString)
    
    return config
}()

class FloorPlanConfiguration: DictionaryConvertible {
    let image: FloorPlanImage
    
    let beaconLocations: [RFIdentifier: FloorPoint]
    
    init(image: FloorPlanImage, beaconLocations: [RFIdentifier: FloorPoint]) {
        self.image = image
        self.beaconLocations = beaconLocations
    }
    
    required init?(dictionary: AnyDictionary) {
        fatalError()
    }
    
    func asDictionary() -> AnyDictionary {
        return [
            "image": image.asDictionary(),
            "beaconLocations": beaconLocations.asDictionary(),
        ]
    }
}

class AnchoredFloorPlanConfiguation: FloorPlanConfiguration {
    let a1, a2: AnchorPoint
    
    let transformation: Transform
    let imagePointsPerMeter: Double
    
    init(image: FloorPlanImage, beaconLocations: [RFIdentifier: FloorPoint], a1: AnchorPoint, a2: AnchorPoint) {
        self.a1 = a1
        self.a2 = a2
        
        let (imagePointsPerMeter, angle) = AnchoredFloorPlanConfiguation.transformationFromWorldToImage(a1, a2)
        
        let scale = Transform.scale(CGFloat(imagePointsPerMeter))
        let rotation = Transform.rotate(CGFloat(angle))
        
        self.transformation = scale.concat(rotation)
        self.imagePointsPerMeter = imagePointsPerMeter
        
        super.init(image: image, beaconLocations: beaconLocations)
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
