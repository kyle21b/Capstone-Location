//
//  RFTrainingSampleBrowserViewController.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 2/22/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

import Foundation
import UIKit

class RFTrainingSampleBrowserViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RFTrainingSampleBrowserViewController.reload), name: RFSampleDatabaseDidUpdateKey, object: sampleDatabase)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        sampleDatabase.reloadSamples()
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    func squareForSection(section: Int) -> GridSquare {
        return floorPlanConfig.allSquares[section]
    }
    
    func itemForIndexPath(indexPath: NSIndexPath) -> RFTrainingSample {
        return sampleDatabase.samplesForSquare(squareForSection(indexPath.section))[indexPath.row]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return floorPlanConfig.allSquares.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return squareForSection(section).description
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleDatabase.samplesForSquare(squareForSection(section)).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let sample = itemForIndexPath(indexPath)
     
        cell.textLabel?.text = sample.description
        cell.detailTextLabel?.text = sample.nameStamp
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if case .Delete = editingStyle {
            let sample = sampleDatabase.samples[indexPath.row]
            sampleDatabase.removeSample(sample)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sampleSegue" {
            if let vc = segue.destinationViewController as? RFTrainingSampleViewController {
                if let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell) {
                    vc.trainingSample = itemForIndexPath(indexPath)
                }
            }
        }
    }
}