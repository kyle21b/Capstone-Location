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
        moveToPoint(sender.locationInView(floorPlanScrollView), animated: true)
    }
    
    @IBAction func pan(sender: UIPanGestureRecognizer) {
        moveToPoint(sender.locationInView(floorPlanScrollView))
    }
    
    func moveToPoint(point: CGPoint, animated: Bool = false) {
        let floorPoint = floorPlanScrollView.convertFromScreen(point)
        
        let location = Location(point: floorPoint)

        if animated {
            UIView.animateWithDuration(0.22) {
                self.floorPlanScrollView.location = location
            }
        } else {
            floorPlanScrollView.location = location
        }

    }
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        floorPlanView.location = locations.last
    }*/
}

