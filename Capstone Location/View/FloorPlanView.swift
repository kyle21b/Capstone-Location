//
//  FloorPlanView.swift
//  
//
//  Created by Kyle Bailey on 2/3/16.
//
//

import UIKit
import SVPulsingAnnotationView

class FloorPlanScrollView: UIScrollView, UIScrollViewDelegate {
    var floorPlanImage: FloorPlanImage? {
        didSet {
            floorPlanView.floorPlanImage = floorPlanImage
            zoomToRect(floorPlanView.bounds, animated: false)
        }
    }
    
    let userLocationView: UIView = {
        /*
        let size: CGFloat = 300
        let view = UIView()
        view.bounds = CGRectMake(0, 0, size, size)
        view.layer.cornerRadius = size/2;
        view.backgroundColor = UIColor.blueColor();
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = true
        view.alpha = 0.7
        return view
        */
        return SVPulsingAnnotationView()
    }()

    let floorPlanView: FloorPlanView
    
    required init?(coder aDecoder: NSCoder) {
        floorPlanView = FloorPlanView(coder: aDecoder)!
        
        super.init(coder: aDecoder)
        
        decelerationRate = UIScrollViewDecelerationRateFast
        
        addSubview(floorPlanView)
        floorPlanView.clipsToBounds = false
        floorPlanView.addSubview(userLocationView)

        let sides: [NSLayoutAttribute] = [.Left, .Right, .Top, .Bottom]
        
        let constraints = sides.map {
            NSLayoutConstraint(item: self, attribute: $0, relatedBy: .Equal, toItem: floorPlanView, attribute: $0, multiplier: 1, constant: 0)
        }
        addConstraints(constraints)
        
        delegate = self
    }
    
    var location: Location? {
        didSet {
            guard let location = location else { return }
            
            //Change image for proper floor
            switch (location.floor) {
            default: break
            }
            
            let screenCoord = convertToScreen(location.point)
            let scrollViewTransform = Transform.scale(1/zoomScale)
            userLocationView.center = screenCoord.applyTransform(scrollViewTransform)
        }
    }
    
    func setLocation(location: Location?, animated: Bool = false) {
        if animated {
            UIView.animateWithDuration(0.3) {
                self.location = location
            }
        } else {
            self.location = location
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return floorPlanView
    }
}

class FloorPlanView: UIImageView {
    var floorPlanImage: FloorPlanImage? {
        didSet {
            guard let floorPlanImage = floorPlanImage else { return }
            
            switch floorPlanImage.underlyingImage {
            case .Image(let image): self.image = image
            default: break
            }
            
            sizeToFit()
        }
    }
}