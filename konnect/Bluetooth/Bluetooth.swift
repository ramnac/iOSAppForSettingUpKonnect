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
    func didBluetoothPoweredOn()
    func didPeripheralUnreached()
    func didTimeoutOccured()
    func didPeripheralDiscovered()
    func didPeripheralConnected()
    func didConnectedToInvalidPeripheral()
    func didBluetoothOffOrUnknown()
    func didFailedToConnectPeripheral()
}

extension BluetoothDelegate {
    func didBluetoothPoweredOn() {}
    func didPeripheralUnreached() {}
    func didTimeoutOccured() {}
    func didPeripheralDiscovered() {}
    func didPeripheralConnected() {}
    func didConnectedToInvalidPeripheral() {}
    func didBluetoothOffOrUnknown() {}
    func didFailedToConnectPeripheral() {}
}

class Bluetooth: NSObject {
    
    static let shared = Bluetooth()
    
    private(set) var state: BluetoothState?
    
    weak var delegate: BluetoothDelegate?
    
    private var coreBluetoothManager: CBCentralManager!
    
    private var timeoutWorkItemReference: DispatchWorkItem?
    
    private var timeoutWorkItem: DispatchWorkItem {
        get {
            return DispatchWorkItem() {
                [weak self] in
                self?.coreBluetoothManager.stopScan()
                self?.delegate?.didTimeoutOccured()
            }
        }
    }
    
    private override init() {
        super.init()
        coreBluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForPeripherals() {
        restartTimeoutWorkItem()
        coreBluetoothManager.scanForPeripherals(withServices: [CBUUID(string: Constants.Bluetooth.serviceUUID.rawValue)], options: nil)
    }
    
    func stopScan() {
        cancelTimeoutWorkItem()
        coreBluetoothManager.stopScan()
    }
    
    private func cancelTimeoutWorkItem() {
        if let workItem = timeoutWorkItemReference {
            workItem.cancel()
            timeoutWorkItemReference = nil
        }
    }
    
    private func restartTimeoutWorkItem() {
        cancelTimeoutWorkItem()
        timeoutWorkItemReference = timeoutWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(Constants.Bluetooth.Numbers.scanTimeoutSeconds.rawValue), execute: timeoutWorkItemReference!)
    }
}

extension Bluetooth: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            state = .on
            delegate?.didBluetoothPoweredOn()
        } else {
            state = .offOrUnknown
            delegate?.didBluetoothOffOrUnknown()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        coreBluetoothManager.stopScan()
        if RSSI.int32Value < Int32(Constants.Bluetooth.Numbers.rssiMinimumStrength.rawValue) {
            cancelTimeoutWorkItem()
            delegate?.didPeripheralUnreached()
            return
        }
        restartTimeoutWorkItem()
        delegate?.didPeripheralDiscovered()
        coreBluetoothManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let _ = peripheral.name else {
            coreBluetoothManager.cancelPeripheralConnection(peripheral)
            cancelTimeoutWorkItem()
            delegate?.didConnectedToInvalidPeripheral()
            return
        }
        delegate?.didPeripheralConnected()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        cancelTimeoutWorkItem()
        delegate?.didFailedToConnectPeripheral()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //Handle this only if you have an user interface interaction with this use case
    }
}
