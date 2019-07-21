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
    func didPeripheralDiscovered()
    func didPeripheralConnected()
    func didConnectToInvalidPeripheral()
    func didBluetoothOffOrUnknown()
}

extension BluetoothDelegate {
    func didBluetoothPoweredOn() {}
    func didPeripheralUnreached() {}
    func didTimeoutOccured() {}
    func didPeripheralDiscovered() {}
    func didPeripheralConnected() {}
    func didConnectToInvalidPeripheral() {}
    func didBluetoothOffOrUnknown() {}
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
                self?.state = .on
                self?.delegate?.didTimeoutOccured()
            }
        }
    }
    
    private override init() {
        super.init()
        coreBluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForPeripherals() {
        state = .scanning
        restartTimeoutWorkItem()
        coreBluetoothManager.scanForPeripherals(withServices: [CBUUID(string: Constants.Bluetooth.serviceUUID.rawValue)], options: nil)
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
        state = .peripheralDiscovered
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
        state = .peripheralConnected
        guard let _ = peripheral.name else {
            coreBluetoothManager.cancelPeripheralConnection(peripheral)
            state = .on
            cancelTimeoutWorkItem()
            delegate?.didConnectToInvalidPeripheral()
            return
        }
        delegate?.didPeripheralConnected()
    }
}
