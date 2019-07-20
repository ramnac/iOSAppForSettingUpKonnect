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

class Bluetooth: NSObject {
    
    static let shared = Bluetooth()
    
    private(set) var state: BluetoothState = .offOrUnknown
    
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
        } else {
            state = .offOrUnknown
        }
    }
}
