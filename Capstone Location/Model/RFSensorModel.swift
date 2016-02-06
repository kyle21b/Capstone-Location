//
//  RFManager.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 12/19/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol RFSensorManagerDelegate {
    func model(model: RFSensorManager, didUpdateDevice device: RFDevice)
}

extension CBPeripheral {
    public var RFIdentifier: String {
        return identifier.UUIDString
    }
}

protocol RFSensorManager {
    var delegate: RFSensorManagerDelegate? { get set }
    
    var state: State { get }
    func startScanning()
    func stopScanning()
    
    var devices: [RFDevice] { get }
    
    func sample() -> RFSample
}

class BluetoothSensorManager: NSObject, CBCentralManagerDelegate, RFSensorManager {
    private let manager = CBCentralManager(delegate: nil, queue: nil)

    private var CBPeripherals = [CBPeripheral]()
    private var deviceModels = [NSString: RFDevice]()
    
    var state: State = .NotReady
    
    var delegate: RFSensorManagerDelegate?

    override init() {
        super.init()
        manager.delegate = self
    }
    
    var devices: [RFDevice] {
        return Array(deviceModels.values)
    }
    
    func sample() -> RFSample {
        var sample = RFSample()
        for device in deviceModels.values {
            sample[device.identifier] = device.rssi
        }
        return sample
    }
    
    private func didUpdateDevice(device: RFDevice) {
        delegate?.model(self, didUpdateDevice: device)
    }
    
    func startScanning() {
        manager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    func stopScanning() {
        manager.stopScan()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
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
        if let existingDevice = deviceModels[peripheral.RFIdentifier] {
            device = existingDevice
        } else {
            device = RFDevice(identifier: peripheral.RFIdentifier)
        }
        
        device.name = peripheral.name
        device.state = "\(peripheral.state)"
        device.advertisementData = advertisementData
        device.recordRssi(Double(RSSI))
        
        deviceModels[peripheral.RFIdentifier] = device
        
        didUpdateDevice(device)
    }
}
