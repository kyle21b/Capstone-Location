//
//  FloorPlanView.swift
//  
//
//  Created by Kyle Bailey on 2/3/16.
//
//

import UIKit

class FloorPlanView: UIImageView {
    
    let userLocationView: UIView = {
        let view = UIView()
        view.bounds = CGRectMake(0, 0, defaultRadius*2, defaultRadius*2)
        view.layer.cornerRadius = defaultRadius;
        view.backgroundColor = UIColor.blueColor();
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = true
        view.alpha = 0.7
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(userLocationView)
    }
    
    var location: Location? {
        didSet {
            guard let location = location else { return }
            
            //Change image for proper floor
            switch (location.floor) {
            default: break
            }
      
            self.userLocationView.center = convertToScreenCoordinate(location.point)
        }
    }
    
    /*
    func sizeForAccuracy(accuracy: CLLocationAccuracy) -> CGSize {
        if (accuracy > 0) {
            let scale = CGFloat(floorPlanConfig.imagePointsPerMeter) * imagePerPixelScale
            return CGSizeMake(CGFloat(accuracy) * scale * 2, CGFloat(accuracy) * scale * 2)
        } else {
            return CGSizeMake(defaultRadius*2, defaultRadius*2)
        }
    }

    
    func setViewSize(size: CGSize) {
        userLocationView.transform = CGAffineTransformMakeScale(size.width / (defaultRadius*2), size.height / (defaultRadius*2))
    }
*/
}