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
    case scanning
    case peripheralDiscovered
    case peripheralConnected
}

protocol BluetoothDelegate: class {
    func didBluetoothPoweredOn()
    func didPeripheralUnreached()
    func didTimeoutOccured()
}

extension BluetoothDelegate {
    func didBluetoothPoweredOn() {}
    func didPeripheralUnreached() {}
    func didTimeoutOccured() {}
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
    
    func scanForPeripherals() {
        coreBluetoothManager.scanForPeripherals(withServices: [CBUUID(string: Constants.Bluetooth.serviceUUID.rawValue)], options: nil)
        state = .scanning
        DispatchQueue.main.asyncAfter(deadline: .now()+3) { [weak self] in
            if self?.state == .scanning {
                self?.coreBluetoothManager.stopScan()
                self?.state = .on
                self?.delegate?.didTimeoutOccured()
            }
        }
    }
}

extension Bluetooth: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            state = .on
            delegate?.didBluetoothPoweredOn()
        } else {
            state = .offOrUnknown
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        state = .peripheralDiscovered
        coreBluetoothManager.stopScan()
        if RSSI.int32Value < -90 {
            delegate?.didPeripheralUnreached()
            return
        }
        coreBluetoothManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let _ = peripheral.name else {
            coreBluetoothManager.cancelPeripheralConnection(peripheral)
            return
        }
        state = .peripheralConnected
    }
}
