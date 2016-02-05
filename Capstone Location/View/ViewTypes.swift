//
//  ViewTypes.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/4/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import UIKit

struct FloorPlanImage {
    enum UnderlyingType {
        case Image(UIImage)
        case PDF(CGPDFPageRef)
    }
    
    let name: String
    let underlyingImage: UnderlyingType
    init?(named name: String) {
        guard let image = UIImage(named: name) else { return nil }
        self.name = name
        self.underlyingImage = .Image(image)
    }
}