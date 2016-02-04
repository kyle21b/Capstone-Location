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
    @IBOutlet weak var floorPlanView: FloorPlanView!
    
    let locationManager = CLLocationManager()
    
    override func loadView() {
        super.loadView()
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
  
    @IBAction func tap(sender: UITapGestureRecognizer) {
        moveToPoint(sender.locationInView(floorPlanView))
    }
    
    @IBAction func pan(sender: UIPanGestureRecognizer) {
        moveToPoint(sender.locationInView(floorPlanView))
    }
    
    func moveToPoint(point: CGPoint) {
        let floor = floorPlanView.convertFromScreenCoordinate(point)
        
        floorPlanView.location = Location(x: floor.x, y: floor.y)
    }

    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        floorPlanView.location = locations.last
    }*/
}

