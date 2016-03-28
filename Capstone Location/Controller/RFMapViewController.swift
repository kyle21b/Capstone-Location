//
//  ViewController.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 11/13/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import UIKit
import MapKit

let deviceName: String = {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    return machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8 where value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
}()

class RFMapViewController: UIViewController, IntegratedLocationManagerDelegate, FloorPlanScrollViewDelegate {
    
    enum Mode {
        case Train
        case Predict
    }
    
    var mode: Mode = .Train {
        didSet {
            switch mode {
            case .Train:
                trainButton.title = "Stop"
                navigationItem.rightBarButtonItem = sampleButton
            case .Predict:
                trainButton.title = "Train"
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    var selectedSquare: GridSquare?
    
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
        floorPlanScrollView.floorPlanDelegate = self
        floorPlanSelector.selectedSegmentIndex = floorPlanConfig.initialFloor
        
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func trainModeChanged(sender: UIBarButtonItem) {
        switch mode {
        case .Train: mode = .Predict
        case .Predict: mode = .Train
        }
    }
    
    func floorPlanScrollViewDidSelectSquare(square: GridSquare) {
        selectedSquare = square
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
        guard mode != .Train else { return }
        floorPlanScrollView.setLocation(location, animated: true)
    }
    
    func moveToPoint(point: CGPoint, animated: Bool = false) {
        let location = Location(point: point.applyTransform(Transform.scale(1/floorPlanScrollView.zoomScale)).toPoint())
        floorPlanScrollView.setLocation(location, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sampleSegue" {
            if let nav = segue.destinationViewController as? UINavigationController,
                vc = nav.viewControllers.first as? RFTrainingSampleViewController,
                selectedSquare = selectedSquare,
                heading = locationManager.heading {
                
                let sample = locationManager.locationManager.sensorManager.sample()
                
                vc.trainingSample = RFTrainingSample(square: selectedSquare, heading: heading, sample: sample, nameStamp: guessUserName(), timeStamp: NSDate(), deviceModel: deviceName)
            }
        }
    }
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        floorPlanView.location = locations.last
    }*/
}

