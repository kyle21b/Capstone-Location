//
//  RFBrowserViewController.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 12/19/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import UIKit

class RFBrowserViewController: UITableViewController, RFSensorManagerDelegate {
    
    var model: RFSensorManager! = nil
    var devices = [RFDevice]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = BluetoothSensorManager()
        model.delegate = self
        model.startScanning()
    }
    
    func model(model: RFSensorManager, didUpdateDevice device: RFDevice) {
        devices = model.devices
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
       
        let device = devices[indexPath.row]
        
        cell.textLabel?.text = device.displayName
        
        if let rssi = device.rssi {
            cell.detailTextLabel?.text = "RSSI: \(rssi)"
        } else {
            cell.detailTextLabel?.text = "No RSSI"
        }
        
        return cell
    }
    
}


