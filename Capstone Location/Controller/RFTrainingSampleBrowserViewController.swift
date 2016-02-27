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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: RFSampleDatabaseDidUpdateKey, object: sampleDatabase)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleDatabase.samples.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let sample = sampleDatabase.samples[indexPath.row]
     
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
                    vc.trainingSample = sampleDatabase.samples[indexPath.row]
                }
            }
        }
    }
}