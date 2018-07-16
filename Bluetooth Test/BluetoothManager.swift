//
//  BluetoothManager.swift
//  Bluetooth Test
//
//  Created by Max Langer on 11.07.18.
//  Copyright © 2018 Max Langer. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothManager: NSObject {
    
    // MARK: - Variables
    let queue = DispatchQueue(label: "BluetoothBackgroundQueue")
    
    lazy var peripheralManager: CBPeripheralManager = {
        return CBPeripheralManager(delegate: self, queue: self.queue)
    }()
    
    lazy var centralManager: CBCentralManager = {
        return CBCentralManager(delegate: self, queue: self.queue)
    }()
    
    private var peripheralState = State.none
    private var centralState = State.none
    
    var peripheralCallback: PeripheralCallback?
    
    var sightings = Set<Sighting>() {
        didSet {
            print(sightings)
            self.peripheralCallback?(Array(self.sightings))
        }
    }
    
    
    // MARK: - Initialization
    
    convenience init(callback: @escaping PeripheralCallback) {
        self.init()
        self.peripheralCallback = callback
    }
 
    
    // MARK: - Start & Stop
    
    func start() {
        guard !self.peripheralManager.isAdvertising, !self.centralManager.isScanning else { return }
        
        if self.isAuthorized, self.peripheralState == .none, self.centralState == .none {
            self.peripheralState = .starting
            self.centralState = .starting
            
            return
        }
        
        self.startCentral()
        self.startPeripheral()
    }
    
    func stop() {
        self.peripheralManager.stopAdvertising()
        self.centralManager.stopScan()
    }
    
    var isAuthorized: Bool {
        switch CBPeripheralManager.authorizationStatus() {
        case .notDetermined, .authorized:
            return true
        case .restricted, .denied:
            return false
        }
    }
    
}

// MARK: - Types
extension BluetoothManager {
    
    typealias PeripheralCallback = ([Sighting]) -> Void
    
    fileprivate enum State {
        case starting, started, none
    }
    
    struct Sighting: Hashable {

        var name: String
        
        var rssi: NSNumber
        
        static func ==(lhs: Sighting, rhs: Sighting) -> Bool {
            return lhs.name == rhs.name
        }
        
        var hashValue: Int {
            return self.name.hashValue
        }

    }
    
}

// MARK: - Central Manager Delegate
extension BluetoothManager: CBCentralManagerDelegate {
    
    fileprivate func startCentral() {
        self.centralState = .started
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name else { return }
        
        self.sightings.update(with: Sighting(name: name, rssi: RSSI))
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if self.centralState == .starting {
           self.startCentral()
        }
    }
    
}

// MARK: - Peripheral Manager Delegate
extension BluetoothManager: CBPeripheralManagerDelegate {
    
    fileprivate func startPeripheral() {
        self.peripheralState = .started
        let info = ["kCBAdvBla": "Butterhabicht"]
        
        self.peripheralManager.startAdvertising(info)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if self.peripheralState == .starting {
            self.startPeripheral()
        }
    }
    
}

