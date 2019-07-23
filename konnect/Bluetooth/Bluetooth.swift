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
    func didFailToDiscoverPeripheralServices()
    func didFailToDiscoverCharacteristics()
    func didFailToUpdateNotificationState()
    func didFailToUpdateValueForCharacteristic()
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
    func didFailToDiscoverPeripheralServices() {}
    func didFailToDiscoverCharacteristics() {}
    func didFailToUpdateNotificationState() {}
    func didFailToUpdateValueForCharacteristic() {}
}

class Bluetooth: NSObject {
    
    static let shared = Bluetooth()
    
    private(set) var state: BluetoothState?
    
    weak var delegate: BluetoothDelegate?
    
    private let argonServiceUUID = CBUUID(string: Constants.Bluetooth.serviceUUID.rawValue)
    private let rxCharacteristicUUID = CBUUID(string: Constants.Bluetooth.rxCharacterisiticUUID.rawValue)
    private let txCharacteristicUUID = CBUUID(string: Constants.Bluetooth.txCharacterisiticUUID.rawValue)
    
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
        coreBluetoothManager.scanForPeripherals(withServices: [argonServiceUUID], options: nil)
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
        guard let peripheralName = peripheral.name, peripheralName.hasPrefix(Constants.Bluetooth.deviceNamePrefix.rawValue) else {
            coreBluetoothManager.cancelPeripheralConnection(peripheral)
            cancelTimeoutWorkItem()
            delegate?.didConnectedToInvalidPeripheral()
            return
        }
        restartTimeoutWorkItem()
        delegate?.didPeripheralConnected()
        peripheral.discoverServices([argonServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        cancelTimeoutWorkItem()
        delegate?.didFailedToConnectPeripheral()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //Handle this only if you have an user interface interaction with this use case
    }
}

extension Bluetooth: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let _ = error {
            cancelTimeoutWorkItem()
            delegate?.didFailToDiscoverPeripheralServices()
            return
        }
        if let peripheralServices = peripheral.services {
            for service in peripheralServices {
                if service.uuid.isEqual(Constants.Bluetooth.serviceUUID.rawValue) {
                    restartTimeoutWorkItem()
                    peripheral.discoverCharacteristics([rxCharacteristicUUID,txCharacteristicUUID], for: service)
                    return
                }
            }
        }
        cancelTimeoutWorkItem()
        delegate?.didFailToDiscoverPeripheralServices()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let _ = error {
            cancelTimeoutWorkItem()
            delegate?.didFailToDiscoverCharacteristics()
            return
        }
        if service.uuid.isEqual(Constants.Bluetooth.serviceUUID.rawValue) {
            if let serviceCharacteristics = service.characteristics {
                for characteristic in serviceCharacteristics {
                    if characteristic.uuid.isEqual(Constants.Bluetooth.txCharacterisiticUUID.rawValue) {
                        restartTimeoutWorkItem()
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        }
        cancelTimeoutWorkItem()
        delegate?.didFailToDiscoverCharacteristics()
        return
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil || !characteristic.isNotifying {
            cancelTimeoutWorkItem()
            delegate?.didFailToUpdateNotificationState()
            return
        }
        cancelTimeoutWorkItem()
        restartTimeoutWorkItem()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let _ = error {
            cancelTimeoutWorkItem()
            delegate?.didFailToUpdateValueForCharacteristic()
            return
        }
        //ToDo
    }
    
}
