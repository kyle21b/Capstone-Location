//
//  FloorPlanView.swift
//  
//
//  Created by Kyle Bailey on 2/3/16.
//
//

import UIKit
import SVPulsingAnnotationView

protocol FloorPlanScrollViewDelegate: AnyObject {
    func floorPlanScrollViewDidSelectSquare(square: GridSquare)
}

class FloorPlanScrollView: UIScrollView, UIScrollViewDelegate {
    var floorPlanDelegate: FloorPlanScrollViewDelegate?
    
    func configureWithFloorPlan(floorPlanConfig: FloorPlanConfiguration) {
        floorPlanImages = floorPlanConfig.images
        selectedFloor = floorPlanConfig.initialFloor
        zoomToRect(floorPlanView.bounds, animated: false)
    }
    
    var floorPlanImages = [FloorPlanImage]()

    var selectedFloor = 0 {
        didSet {
            selectedImage = floorPlanImages[selectedFloor]
            refreshGridView()
        }
    }
    
    var selectedSquare: GridSquare? {
        didSet {
            if let selectedSquare = selectedSquare {
                floorPlanDelegate?.floorPlanScrollViewDidSelectSquare(selectedSquare)
                floorGridView?.selectSquare(selectedSquare)
            }
        }
    }
    
    private var selectedImage: FloorPlanImage? {
        didSet {
            floorPlanView.image = selectedImage?.image
        }
    }
    
    let userLocationView = SVPulsingAnnotationView(annotation: nil, reuseIdentifier: nil)
    
    let floorPlanView: FloorPlanView
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
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
        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(FloorPlanScrollView.tap(_:)))
        
        refreshGridView()
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
    
    var floorGridView: FloorGridView?
    
    func refreshGridView() {
        self.floorGridView?.removeFromSuperview()
        let floorGridView = FloorGridView(gridConfiguration: floorPlanConfig.gridConfigurations[selectedFloor])
        self.floorGridView = floorGridView
        floorPlanView.addSubview(floorGridView)
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
    
    func tap(gesture: UITapGestureRecognizer) {
        let location = gesture.locationInView(self)
        let hitView = hitTest(location, withEvent: nil)
        if let squareView = hitView as? FloorGridView.SquareView {
            selectedSquare = squareView.square
        }
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

let disabledColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
let enabledColor = UIColor.greenColor()

class FloorGridView: UIView {
    class SquareView: UIView {
        var square: GridSquare! {
            didSet {
                label.text = square.identifier
            }
        }
        
        var selected = false {
            didSet {
                guard selected != oldValue else { return }
                let color = selected ? enabledColor : disabledColor
                layer.backgroundColor = color.CGColor
            }
        }
        
        var label = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.borderWidth = 1.0
            layer.backgroundColor = disabledColor.CGColor
            
            addSubview(label)
            label.textAlignment = .Center
            label.frame = bounds
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    required init(gridConfiguration: GridConfiguration) {
        super.init(frame: gridConfiguration.frame)
        let size = gridConfiguration.squareSize
        for square in gridConfiguration.allSquares {
            let (row, column) = (square.row, GridConfiguration.indexOfColumn(square.column))
            let origin = CGPoint(x: size.width * CGFloat(column), y: size.height * CGFloat(row))
            let frame = CGRect(origin: origin, size: size)
            let squareView = SquareView(frame: frame)
            squareView.square = square
            addSubview(squareView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectSquare(square: GridSquare) {
        for case let view as SquareView in subviews {
            view.selected = view.square == square
        }
    }
}
