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

/*
@objc protocol CBCentralManagerWrapperDelegate : NSObjectProtocol {
    func centralManagerDidUpdateState(central: CBCentralManagerWrapper)
    
    optional func centralManager(central: CBCentralManagerWrapper, willRestoreState dict: [String : AnyObject])

    optional func centralManager(central: CBCentralManagerWrapper, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)

    optional func centralManager(central: CBCentralManagerWrapper, didConnectPeripheral peripheral: CBPeripheral)
    
    optional func centralManager(central: CBCentralManagerWrapper, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?)
    
    optional func centralManager(central: CBCentralManagerWrapper, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
}

class CBCentralManagerWrapper: NSObject, CBCentralManagerDelegate {
    private var delegates = [CBCentralManagerWrapperDelegate]()
    
    func addDelegate(delegate: CBCentralManagerWrapperDelegate) {
        delegates.append(delegate)
    }
    
    func removeDelegate(delegate: CBCentralManagerWrapperDelegate) {
        delegates.remove(delegate)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        for delegate in delegates {
            delegate.centralManagerDidUpdateState(self)
        }
    }

    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        
    }

    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
    }

    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
    }
}*/

class BluetoothSensorManager: NSObject, CBCentralManagerDelegate, RFSensorManager {
    private var manager: CBCentralManager!

    private var CBPeripherals = [CBPeripheral]()
    private var devicesByIdentifier = [RFIdentifier: RFDevice]()
    
    private var shouldBeScanning = false
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
            sample[device.identifier] = device.rssi
        }
        return sample
    }
    
    private func didUpdateDevice(device: RFDevice) {
        delegate?.manager(self, didUpdateDevice: device)
    }
    
    func startScanning() {
        shouldBeScanning = true
        if readyToScan {
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey : true]
            manager.scanForPeripheralsWithServices(nil, options: options)
        }
    }
    
    func stopScanning() {
        shouldBeScanning = false
        manager.stopScan()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            readyToScan = true
            if shouldBeScanning {
                startScanning()
            }
        case .Resetting: print("resetting")
        default: print(central.state.description)
        }
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print(dict)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        guard RSSI != 127 else {
            return
        }
        
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
        
        didUpdateDevice(device)
    }
}
