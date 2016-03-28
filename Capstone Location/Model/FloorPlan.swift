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

struct GridSquare: Hashable, CustomStringConvertible {
    let row: Int
    let column: String
    let floor: Int
    
    var identifier: String {
        return "\(column)\(row)"
    }
    
    var description: String {
        return "Floor \(floor): " + identifier
    }
    
    var hashValue: Int {
        return row.hashValue &+ column.hashValue
    }
}

func ==(lhs: GridSquare, rhs: GridSquare) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column && lhs.floor == rhs.floor
}

struct GridConfiguration {
    private static let columnIndexMap = [
        "A" : 0,
        "B" : 1,
        "C" : 2
    ]
    
    static func indexOfColumn(column: String) -> Int {
        return columnIndexMap[column]!
    }
    
    let frame: CGRect
    let rows: Int
    let columns: Int
    
    let floor: Int
    
    let allSquares: [GridSquare]
    
    init(frame: CGRect, rows: Int, columns: Int, floor: Int) {
        self.frame = frame
        self.rows = rows
        self.columns = columns
        self.floor = floor
        
        let identifiers = GridConfiguration.columnIndexMap.keys.sort().prefix(columns)
        
        var allSquares = [GridSquare]()
        for columnId in identifiers {
            for row in 0..<rows {
                let square = GridSquare(row: row, column: columnId, floor: floor)
                allSquares.append(square)
            }
        }
        self.allSquares = allSquares
    }
    
    var squareSize: CGSize {
        return CGSize(width: frame.size.width / CGFloat(columns), height: frame.size.height / CGFloat(rows))
    }
}

class FloorPlanConfiguration {
    let images: [FloorPlanImage]
    let initialFloor: Int
    
    let baseStations: [RFIdentifier]
    
    let gridConfigurations: [GridConfiguration]
    
    let allSquares: [GridSquare]

    func frameOfSquare(square: GridSquare) -> CGRect {
        let configuration = gridConfigurations[square.floor]
        let size = configuration.squareSize
        
        let (rowNum, columnNum) = (square.row, GridConfiguration.indexOfColumn(square.column))
        
        var origin = configuration.frame.origin
        
        origin.x += CGFloat(columnNum) * size.width
        origin.y += CGFloat(rowNum) * size.height
        return CGRect(origin: origin, size: size)
    }
    
    func locationOfSquare(square: GridSquare) -> Location {
        let frame = frameOfSquare(square)
        return Location(x: Double(frame.midX), y: Double(frame.midY), floor: square.floor)
    }
    
    init(images: [FloorPlanImage], initialFloor: Int = 0, baseStations: [RFIdentifier], gridConfigurations: [GridConfiguration]) {
        self.images = images
        self.initialFloor = initialFloor
        self.baseStations = baseStations
        self.gridConfigurations = gridConfigurations
        
        self.allSquares = gridConfigurations.flatMap { $0.allSquares }
    }
}

class AnchoredFloorPlanConfiguration: FloorPlanConfiguration {
    let a1, a2: AnchorPoint
    
    let transformation: Transform
    let imagePointsPerMeter: Double
    
    init(images: [FloorPlanImage], initialFloor: Int = 0, baseStations: [RFIdentifier], a1: AnchorPoint, a2: AnchorPoint, gridConfigurations: [GridConfiguration]) {
        self.a1 = a1
        self.a2 = a2
        
        let (imagePointsPerMeter, angle) = AnchoredFloorPlanConfiguration.transformationFromWorldToImage(a1, a2)
        
        let scale = Transform.scale(CGFloat(imagePointsPerMeter))
        let rotation = Transform.rotate(CGFloat(angle))
        
        self.transformation = scale.concat(rotation)
        self.imagePointsPerMeter = imagePointsPerMeter
        
        super.init(images: images, initialFloor: initialFloor, baseStations: baseStations, gridConfigurations: gridConfigurations)
    }
}
