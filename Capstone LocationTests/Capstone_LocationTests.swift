//
//  Capstone_LocationTests.swift
//  Capstone LocationTests
//
//  Created by Kyle Bailey on 12/28/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import XCTest

class Capstone_LocationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testXML() {
        let xmlString = String(data: floorPlanConfig.asXML(), encoding: NSUTF8StringEncoding)!
        print(xmlString)
        sleep(1)
    }
    
    func testJSON() {
        let jsonString = String(data: floorPlanConfig.asJSON(), encoding: NSUTF8StringEncoding)!
        print(jsonString)
        sleep(1)
    }
    
    func testVectorLength() {
        assert(length([2,10,11]) == 15)
    }
    
    let data: [[Double]] = {
        var data = [[Double]]()
        let quantity = 0...50
        for i in quantity {
            for j in quantity {
                for k in quantity {
                    data.append([Double(i),Double(j),Double(k)])
                }
            }
        }
        return data
    }()
    
    func testFLANN() {
        
        let flann = Flann(dataSet: data)
        
        let firstTest = flann.radiusSearch([25,25,25], radius: 1)
        assert(firstTest.count == 7)
        
    }
    
    func testPerformanceExample() {
        
        let flann = Flann(dataSet: data)
        self.measureBlock {
            flann.radiusSearch([25,25,25], radius: 1)
        }
        
    }
    
}
