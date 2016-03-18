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
    
    enum Mode {
        case Train
        case Predict
    }
    
    var mode: Mode = .Train {
        didSet {
            switch mode {
            case .Train:
                locationManager.stopUpdatingLocation()
                trainButton.title = "Stop"
                navigationItem.rightBarButtonItem = sampleButton
                promptUserForSquare()
            case .Predict:
                locationManager.startUpdatingLocation()
                trainButton.title = "Train"
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    func promptUserForSquare() {
        let controller = UIAlertController(title: "Enter a Square", message: nil, preferredStyle: .Alert)
        controller.addTextFieldWithConfigurationHandler(nil)
        let action = UIAlertAction(title: "Ok", style: .Default) { _ in
            self.squareID = controller.textFields?.first?.text?.capitalizedString
        }
        controller.addAction(action)
        presentViewController(controller, animated: true, completion: nil)
    }
    
    var squareID: String?
    
    @IBOutlet var trainButton: UIBarButtonItem!
    @IBOutlet var sampleButton: UIBarButtonItem!
    
    @IBOutlet weak var floorPlanSelector: UISegmentedControl!
    
    @IBOutlet weak var floorPlanScrollView: FloorPlanScrollView!
    
    var locationManager: IntegratedLocationManager!
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = IntegratedLocationManager()
        locationManager.delegate = self
        
        mode = .Predict
        
        floorPlanScrollView.configureWithFloorPlan(floorPlanConfig)
        floorPlanScrollView.location = Location(point: floorPlanScrollView.selectedImage!.center)
        floorPlanSelector.selectedSegmentIndex = floorPlanConfig.initialFloor
    }
    
    @IBAction func trainModeChanged(sender: UIBarButtonItem) {
        switch mode {
        case .Train: mode = .Predict
        case .Predict: mode = .Train
        }
    }
    
    @IBAction func floorChanged(sender: UISegmentedControl) {
        floorPlanScrollView.selectedFloor = sender.selectedSegmentIndex
    }
  
    @IBAction func tap(sender: UITapGestureRecognizer) {
        //guard mode == .Train else { return }
        //moveToPoint(sender.locationInView(floorPlanScrollView), animated: true)
    }
    
    @IBAction func pan(sender: UIPanGestureRecognizer) {
        //guard mode == .Train else { return }
        //moveToPoint(sender.locationInView(floorPlanScrollView))
    }
    
    func locationManager(manager: IntegratedLocationManager, didUpdateLocation location: Location) {
        floorPlanScrollView.setLocation(location, animated: true)
    }
    
    func moveToPoint(point: CGPoint, animated: Bool = false) {
        let location = Location(point: point.applyTransform(Transform.scale(1/floorPlanScrollView.zoomScale)).toPoint())
        floorPlanScrollView.setLocation(location, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sampleSegue" {
            if let nav = segue.destinationViewController as? UINavigationController, vc = nav.viewControllers.first as? RFTrainingSampleViewController {
                let sample = sensorManager.sample()
                let location = FloorSquare(label: squareID!, floor: 1)
                vc.trainingSample = RFTrainingSample(location: location, sample: sample, nameStamp: guessUserName(), timeStamp: NSDate())
            }
        }
    }
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        floorPlanView.location = locations.last
    }*/
}

