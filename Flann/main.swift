//
//  main.swift
//  Flann
//
//  Created by Kyle Bailey on 12/8/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation

let bases = [
    Location(5,42.5,1),
    Location(25,25,1),
    Location(5,7.5,1)
]

func generateIntensityAtLocation(location: Location) -> RFIntensityVector {
    func anomaly() -> Double {
        return Double(arc4random_uniform(15)) - 7
    }
    return bases.map {
        100 - 2 * $0.distanceToLocation(location) + anomaly()
    }
}

var samples = [RFSample]()

let stride: Double = 3.0;
for i in 0...Int(30/stride) {
    for j in 0...Int(50/stride) {
        let location = Location(Double(i)*stride,Double(j)*stride,1)
        let intensity = generateIntensityAtLocation(location)
        samples.append(RFSample(intensity: intensity, location: location))
    }
}

let model = RFModel(samples: samples)

let testLocation = Location(19.34,37.30,1)
for i in 1...7 {
    print("\(i) neighbors")
    let intensity = generateIntensityAtLocation(testLocation)
    let predictedLocation = model.predictLocationForIntensity(intensity, nNeighbors: i)
    let errorAmount = predictedLocation.distanceToLocation(testLocation)
    
    print("Test:\t\t\(testLocation)")
    print("Predict:\t\(predictedLocation)")
    print("Error:\t\t\(errorAmount)")

}

//testExample()



