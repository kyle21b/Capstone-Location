//
//  RFManager.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 12/19/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBPeripheral {
    public var RFIdentifier: String {
        return identifier.UUIDString
    }
}

extension Array where Element: NSObjectProtocol {
    func indexOf(element: Element) -> Int? {
        return indexOf { element.isEqual($0) }
    }
    
    mutating func remove(element: Element) {
        if let index = self.indexOf(element) {
            self.removeAtIndex(index)
        }
    }
}

extension Array where Element: Equatable {
    mutating func remove(element: Element) {
        if let index = self.indexOf(element) {
            self.removeAtIndex(index)
        }
    }
}

extension CBCentralManagerState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Unknown: return "Unknown"
        case .Resetting: return "Resetting"
        case .Unsupported: return "Unsupported"
        case .Unauthorized: return "Unauthorized"
        case .PoweredOff: return "PoweredOff"
        case .PoweredOn: return "PoweredOn"
        }
    }
}

class BluetoothSensorManager: NSObject, CBCentralManagerDelegate, RFSensorManager {
    private var manager: CBCentralManager!

    private var CBPeripherals = [CBPeripheral]()
    private var devicesByIdentifier = [RFIdentifier: RFDevice]()
    
    private var scanning = false
    private var readyToScan = false
    
    var state: State = .NotReady
    
    var delegate: RFSensorManagerDelegate?

    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    var devices: [RFDevice] {
        return Array(devicesByIdentifier.values)
    }
    
    func sample() -> RFSample {
        var sample = RFSample()
        for device in devicesByIdentifier.values {
            sample[device.identifier] = device.averageRSSI
        }
        return sample
    }
    
    private func didUpdateDevice(device: RFDevice) {
        if !scanning { return }
        delegate?.manager(self, didUpdateDevice: device)
    }
    
    func startScanning() {
        scanning = true
        if readyToScan {
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey : true]
            manager.scanForPeripheralsWithServices(nil, options: options)
        }
    }
    
    func stopScanning() {
        scanning = false
        manager.stopScan()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            readyToScan = true
            if scanning {
                startScanning()
            }
        default:
            print(central.state.description)
        }
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print(dict)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        guard RSSI != 127 else {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.recordPeripheralData(peripheral, advertisementData: advertisementData, RSSI: RSSI)
        }
    }
    
    func recordPeripheralData(peripheral: CBPeripheral, advertisementData: [String: AnyObject], RSSI: NSNumber) {
        if !CBPeripherals.contains(peripheral) {
            CBPeripherals.append(peripheral)
        }
        
        var device: RFDevice
        if let existingDevice = devicesByIdentifier[peripheral.RFIdentifier] {
            device = existingDevice
        } else {
            device = RFDevice(identifier: peripheral.RFIdentifier)
        }
        
        device.name = peripheral.name
        device.state = String(peripheral.state)
        device.advertisementData = advertisementData
        device.recordRssi(Double(RSSI))
        
        devicesByIdentifier[peripheral.RFIdentifier] = device
        
        dispatch_async(dispatch_get_main_queue()) {
            self.didUpdateDevice(device)
        }
    }
}
