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
        case PDF(PDFPage)
    }
    
    let name: String
    let underlyingImage: UnderlyingType
    init?(named name: String) {
        guard let image = UIImage(named: name) else { return nil }
        self.name = name
        self.underlyingImage = .Image(image)
    }
}

extension FloorPlanImage {
    var size: CGSize {
        switch underlyingImage {
        case .Image(let image): return image.size
        case .PDF(let pdf): return pdf.size
        }
    }
    
    var center: FloorPoint {
        let size = self.size
        return FloorPoint(x: Double(size.width)/2, y: Double(size.height)/2)
    }
    
    var image: UIImage! {
        switch underlyingImage {
        case .Image(let image): return image
        default: return nil
        }
    }
}

typealias PDFPage = CGPDFPageRef
extension PDFPage {
    var size: CGSize {
        return CGPDFPageGetBoxRect(self, .MediaBox).size
    }
}