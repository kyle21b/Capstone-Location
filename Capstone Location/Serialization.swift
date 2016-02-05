//
//  Serialization.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/4/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation
import MapKit

typealias AnyDictionary = [String: AnyObject]
protocol DictionaryConvertible {
    init?(dictionary: AnyDictionary)
    func asDictionary() -> AnyDictionary
}

extension DictionaryConvertible {
    init?(url: NSURL) {
        guard let dict = NSDictionary(contentsOfURL: url) as? AnyDictionary else { return nil }
        self.init(dictionary: dict)
    }
    
    func saveToURL(url: NSURL){
        let dict = asDictionary() as NSDictionary
        dict.writeToURL(url, atomically: true)
    }
}

extension WorldPoint: DictionaryConvertible {
    init?(dictionary: AnyDictionary) {
        guard let lat = dictionary["lat"] as? Double, lon = dictionary["lon"] as? Double else { return nil }
        self.init(latitude: lat, longitude: lon)
    }
    
    func asDictionary() -> AnyDictionary {
        return ["lat": latitude, "lon": longitude]
    }
}

extension FloorPoint: DictionaryConvertible {
    init?(dictionary: AnyDictionary) {
        guard let x = dictionary["x"] as? Double, y = dictionary["y"] as? Double else { return nil }
        self.init(x: x, y: y)
    }
    
    func asDictionary() -> AnyDictionary{
        return ["x": x, "y": y]
    }
}

extension AnchorPoint: DictionaryConvertible {
    init?(dictionary: AnyDictionary) {
        guard let floorDict = dictionary["floor"] as? AnyDictionary, worldDict = dictionary["world"] as? AnyDictionary else { return nil }
        guard let floor = FloorPoint(dictionary: floorDict), world = WorldPoint(dictionary: worldDict) else { return nil }
        self.init(floor: floor, world: world)
    }
    
    func asDictionary() -> AnyDictionary{
        return ["floor": floor.asDictionary(), "world": world.asDictionary()]
    }
}


