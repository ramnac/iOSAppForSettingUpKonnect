//
//  BluetoothManager.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BluetoothState {
    case on
    case offOrUnknown
}

protocol BluetoothDelegate: class {
    func bluetoothPoweredOn()
}

class Bluetooth: NSObject {
    
    static let shared = Bluetooth()
    
    private(set) var state: BluetoothState?
    
    weak var delegate: BluetoothDelegate?
    
    private var coreBluetoothManager: CBCentralManager!
    
    private override init() {
        super.init()
        coreBluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension Bluetooth: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            state = .on
            delegate?.bluetoothPoweredOn()
        } else {
            state = .offOrUnknown
        }
    }
}
