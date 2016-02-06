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

extension DictionaryConvertible {
    init?(JSON: NSData) {
        let jsonObject = try? NSJSONSerialization.JSONObjectWithData(JSON, options: [])
        guard let dictionary = jsonObject as? AnyDictionary else { return nil }
        self.init(dictionary: dictionary)
    }
    
    func asJSON() -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(asDictionary(), options: [.PrettyPrinted])
    }
    
    init?(XML: NSData) {
        let xmlObject = try? NSPropertyListSerialization.propertyListWithData(XML, options: [], format: nil)
        guard let dictionary = xmlObject as? AnyDictionary else { return nil }
        self.init(dictionary: dictionary)
    }
    
    func asXML() -> NSData {
        return try! NSPropertyListSerialization.dataWithPropertyList(asDictionary(), format: .XMLFormat_v1_0, options: 0)
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
    
    func asDictionary() -> AnyDictionary {
        return ["x": x, "y": y]
    }
}

extension AnchorPoint: DictionaryConvertible {
    init?(dictionary: AnyDictionary) {
        guard let floorDict = dictionary["floor"] as? AnyDictionary, worldDict = dictionary["world"] as? AnyDictionary else { return nil }
        guard let floor = FloorPoint(dictionary: floorDict), world = WorldPoint(dictionary: worldDict) else { return nil }
        self.init(floor: floor, world: world)
    }
    
    func asDictionary() -> AnyDictionary {
        return ["floor": floor.asDictionary(), "world": world.asDictionary()]
    }
}

extension FloorPlanImage: DictionaryConvertible {
    init?(dictionary: AnyDictionary) {
        guard let name = dictionary["name"] as? String else { return nil }
        self.init(named: name)
    }
    
    func asDictionary() -> AnyDictionary {
        return ["name": name]
    }
}

extension Dictionary where Value: DictionaryConvertible {
    func asDictionary() -> AnyDictionary {
        return mapPairs { ("\($0)", $1.asDictionary()) }
    }
}

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

func +<Key: Hashable, Value>(lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    var merged = lhs
    for (key, value) in rhs {
        merged[key] = value
    }
    return merged
}

extension Dictionary {
    func mapPairs<OutKey: Hashable, OutValue>(@noescape transform: Element throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue] {
        return Dictionary<OutKey, OutValue>(try map(transform))
    }
}
