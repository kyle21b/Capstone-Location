//
//  ViewController.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 11/13/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import UIKit
import MapKit

let defaultRadius: CGFloat = 22.0

class RFMapViewController: UIViewController { //, CLLocationManagerDelegate {
    @IBOutlet weak var floorPlanView: UIImageView!
    
    let locationManager = CLLocationManager()
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
    
    override func loadView() {
        super.loadView()
        floorPlanView.addSubview(userLocationView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        */
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateView()
    }
    
    var location: CLLocation? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        guard let location = location else { return }
        
        let pixel = pixelCoordinateForWorldCoordinate(location.coordinate)
        let point = pointCoordinateForPixelCoordinate(pixel)
        
        let size = sizeForAccuracy(location.horizontalAccuracy)
        
        self.userLocationView.center = point
        self.setViewSize(size)
    }
    
    func sizeForAccuracy(accuracy: CLLocationAccuracy) -> CGSize {
        if (accuracy > 0) {
            let scale = pixelsPerMeter * imagePerPixelScale
            return CGSizeMake(CGFloat(accuracy) * scale * 2, CGFloat(accuracy) * scale * 2)
        } else {
            return CGSizeMake(defaultRadius*2, defaultRadius*2)
        }
    }

    @IBAction func tap(sender: UITapGestureRecognizer) {
        moveToPoint(sender.locationInView(floorPlanView))
    }
    
    @IBAction func pan(sender: UIPanGestureRecognizer) {
        moveToPoint(sender.locationInView(floorPlanView))
    }
    
    func moveToPoint(point: CGPoint) {
        let pixel = pixelCoordinateForPointCoordinate(point)
        let world = worldCoordinateForPixelCoordinate(pixel)
        
        location = CLLocation(location: world)
    }
    
    func setViewSize(size: CGSize) {
        userLocationView.transform = CGAffineTransformMakeScale(size.width / (defaultRadius*2), size.height / (defaultRadius*2))
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
}

