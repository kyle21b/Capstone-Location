//
//  RFTrainingSampleViewController.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/5/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import UIKit

class RFTrainingSampleViewController: UITableViewController {
    
    var trainingSample: RFTrainingSample!
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        ParseSampleDatabase(baseStations: []).addSample(trainingSample)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return trainingSample.sample.count
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = trainingSample.location.point.description
                cell.detailTextLabel?.text = "Location"
            case 1:
                cell.textLabel?.text = trainingSample.location.floor.description
                cell.detailTextLabel?.text = "Floor"
            default: break
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("subtitleCell", forIndexPath: indexPath)
            let key = Array(trainingSample.sample.keys)[indexPath.row]
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = trainingSample.sample[key]?.description
            return cell

        default: fatalError()
        }
    }
}