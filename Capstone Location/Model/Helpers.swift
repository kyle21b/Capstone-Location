//
//  Helpers.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/23/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation
import UIKit

func guessUserName() -> String {
    let name = UIDevice.currentDevice().name
    if let range = name.rangeOfString("‘") {
        return name.substringToIndex(range.startIndex)
    }
    return name
}