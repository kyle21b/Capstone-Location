//
//  ViewController.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 11/13/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import UIKit
import MapKit

class RFMapViewController: UIViewController, IntegratedLocationManagerDelegate {
    
    @IBOutlet weak var floorPlanSelector: UISegmentedControl!
    
    @IBOutlet weak var floorPlanScrollView: FloorPlanScrollView!
    
    var locationManager: IntegratedLocationManager!
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = IntegratedLocationManager()
        //locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        floorPlanScrollView.configureWithFloorPlan(floorPlanConfig)
        floorPlanScrollView.location = Location(point: floorPlanScrollView.selectedImage!.center)
        floorPlanSelector.selectedSegmentIndex = floorPlanConfig.initialFloor
    }
    
    @IBAction func floorChanged(sender: UISegmentedControl) {
        floorPlanScrollView.selectedFloor = sender.selectedSegmentIndex
    }
  
    @IBAction func tap(sender: UITapGestureRecognizer) {
        moveToPoint(sender.locationInView(floorPlanScrollView), animated: true)
    }
    
    @IBAction func pan(sender: UIPanGestureRecognizer) {
        moveToPoint(sender.locationInView(floorPlanScrollView))
    }
    
    func locationManager(manager: IntegratedLocationManager, didUpdateLocation location: Location) {
        floorPlanScrollView.setLocation(location, animated: true)
    }
    
    func moveToPoint(point: CGPoint, animated: Bool = false) {
        let floorPoint = floorPlanScrollView.convertFromScreen(point)
        let location = Location(point: floorPoint)
        floorPlanScrollView.setLocation(location, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sampleSegue" {
            if let nav = segue.destinationViewController as? UINavigationController, vc = nav.viewControllers.first as? RFTrainingSampleViewController {
                let sample = locationManager.locationManager.sensorManager.sample()
                if let location = floorPlanScrollView.location {
                    vc.trainingSample = RFTrainingSample(location: location, sample: sample)
                }
            }
        }
    }
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        floorPlanView.location = locations.last
    }*/
}

