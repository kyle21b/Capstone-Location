//
//  Tests.swift
//  Flann
//
//  Created by Kyle Bailey on 12/10/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation

let count = 1000000

func makeNDimensionalData(n: Int, count: Int) -> [[Double]] {
    func applyForDimension(n: Int, root: Int, indicies: [Int], apply: (indicies: [Int]) -> ()) {
        guard n > 0 else {
            apply(indicies: indicies)
            return
        }
        for i in 0..<root {
            let newIndicies = indicies + [i]
            applyForDimension(n-1, root: root, indicies: newIndicies, apply: apply)
        }
    }
    
    var data = [[Double]]()
    
    let root = Int(round(pow(Double(count), 1.0/Double(n))))
    
    applyForDimension(n, root: root, indicies: []) {
        let sample = $0.map { Double($0) }
        data.append(sample)
    }
    
    return data
}

func testExample() {
    
    let data = makeNDimensionalData(3, count: count)
    
    var parameters = DEFAULT_FLANN_PARAMETERS
    //parameters.algorithm = FLANN_INDEX_KDTREE
    //parameters.centers_init = FLANN_CENTERS_KMEANSPP
    parameters.log_level = FLANN_LOG_DEBUG
    
    let flann = Flann(dataSet: data, parameters: parameters)
    
    /*
    measureBlock {
        flann.radiusSearch([10,10,10], radius: 1.5, maxN: 20)
    }
    */
    
    let start = NSDate()
    
    for _ in 1...10000 {
        let results = flann.radiusSearch([10,10,10], radius: 100.0, maxN: 20)
        //assert(results.count == 7)
    }
   
    let end = NSDate()
    
    print(end.timeIntervalSinceDate(start))
}

