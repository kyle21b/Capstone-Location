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
    
    func configureWithFloorPlan(floorPlanConfig: FloorPlanConfiguration) {
        floorPlanImages = floorPlanConfig.images
        selectedFloor = floorPlanConfig.initialFloor
        zoomToRect(floorPlanView.bounds, animated: false)
    }
    
    var floorPlanImages = [FloorPlanImage]()

    var selectedFloor = 0 {
        didSet {
            selectedImage = floorPlanImages[selectedFloor]
        }
    }
    
    var selectedImage: FloorPlanImage? {
        didSet {
            floorPlanView.image = selectedImage?.image
        }
    }
    
    let userLocationView = SVPulsingAnnotationView(annotation: nil, reuseIdentifier: nil)
    
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
    
    override func layoutSubviews() {
        if let imageSize = selectedImage?.size {
            let size = bounds.size
            let visibleSize = CGSize(width: size.width - contentInset.left - contentInset.right, height: size.height - contentInset.top - contentInset.bottom)
            let (xScale, yScale) = (visibleSize.width / imageSize.width, visibleSize.height / imageSize.height)
            minimumZoomScale = min(xScale, yScale)
        }
        userLocationView.transform = Transform.scale(1.0/zoomScale)
        super.layoutSubviews()
    }
    
    var location: Location? {
        didSet {
            guard let location = location else { return }
            print(location.point)
            
            //Change image for proper floor
            switch (location.floor) {
            default: break
            }
            
            userLocationView.center = location.point.toCGPoint()
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