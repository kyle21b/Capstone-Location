//
//  ViewController.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 11/13/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import UIKit
import MapKit

class RFMapViewController: UIViewController { //, CLLocationManagerDelegate {
    
    @IBOutlet weak var floorPlanScrollView: FloorPlanScrollView!
    
    let locationManager = CLLocationManager()
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        floorPlanScrollView.floorPlanImage = floorPlanConfig.image
    }
  
    @IBAction func tap(sender: UITapGestureRecognizer) {
        moveToPoint(sender.locationInView(floorPlanScrollView))
    }
    
    @IBAction func pan(sender: UIPanGestureRecognizer) {
        moveToPoint(sender.locationInView(floorPlanScrollView))
    }
    
    func moveToPoint(point: CGPoint) {
        
        let floor = floorPlanScrollView.convertFromScreen(point)
        floorPlanScrollView.location = Location(x: floor.x, y: floor.y)
    }

    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        floorPlanView.location = locations.last
    }*/
}

