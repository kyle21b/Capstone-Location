//
//  BluetoothDeviceViewController.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 12/29/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import UIKit

class RFDeviceViewController: UITableViewController {
    var device: RFDevice? {
        didSet {
            title = device?.displayName
        }
    }
}
