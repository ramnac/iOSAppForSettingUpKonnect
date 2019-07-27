//
//  BluetoothManager.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BluetoothOperation {
    case searchWiFi
    case validateWiFiPassword
}

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
    func didUpdateValueForWiFiNetworks(with wifiNetworksArray:[String])
    func didUpdateValueForWiFiPassword(with jsonResponse:[String: Any])
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
    func didUpdateValueForWiFiNetworks(with wifiNetworksArray:[String]) {}
    func didUpdateValueForWiFiPassword(with jsonResponse:[String: Any]) {}
}

class Bluetooth: NSObject {
    
    static let shared = Bluetooth()
    
    private(set) var state: BluetoothState?
    
    private(set) var operation: BluetoothOperation?
    
    weak var delegate: BluetoothDelegate?
    
    private let argonServiceUUID = CBUUID(string: Constants.Bluetooth.serviceUUID.rawValue)
    private let rxCharacteristicUUID = CBUUID(string: Constants.Bluetooth.rxCharacterisiticUUID.rawValue)
    private let txCharacteristicUUID = CBUUID(string: Constants.Bluetooth.txCharacterisiticUUID.rawValue)
    
    private var peripheralToConnect: CBPeripheral?
    
    private var coreBluetoothManager: CBCentralManager!
    
    private var timeoutWorkItemReference: DispatchWorkItem?
    
    private var ssidName: String?
    private var wifiPassword: String?
    
    private var timeoutWorkItem: DispatchWorkItem {
        get {
            return DispatchWorkItem() {
                [weak self] in
                self?.peripheralToConnect = nil
                self?.coreBluetoothManager.stopScan()
                self?.delegate?.didTimeoutOccured()
                self?.operation = nil
                self?.ssidName = nil
                self?.wifiPassword = nil
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
        peripheralToConnect = nil
        coreBluetoothManager.stopScan()
        //ToDo : cleanup needs to be rechecked
        operation = nil
        ssidName = nil
        wifiPassword = nil
    }
    
    func performOperation(bluetoothOperation:BluetoothOperation) {
        guard let peripheralToConnect = peripheralToConnect else {
            //May be a delegate callback is needed here
            return
        }
        restartTimeoutWorkItem()
        operation = bluetoothOperation
        peripheralToConnect.delegate = self
        peripheralToConnect.discoverServices([argonServiceUUID])
    }
    
    func validateWiFiPassword(password: String, forSSID name: String) {
        ssidName = name
        wifiPassword = password
        performOperation(bluetoothOperation: .validateWiFiPassword)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(Constants.Bluetooth.Numbers.scanTimeoutInSeconds.rawValue), execute: timeoutWorkItemReference!)
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
        peripheralToConnect = peripheral
        coreBluetoothManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let peripheralName = peripheral.name, peripheralName.hasPrefix(Constants.Bluetooth.deviceNamePrefix.rawValue) else {
            coreBluetoothManager.cancelPeripheralConnection(peripheral)
            cancelTimeoutWorkItem()
            delegate?.didConnectedToInvalidPeripheral()
            return
        }
        cancelTimeoutWorkItem()
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

extension Bluetooth: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let _ = error {
            cancelTimeoutWorkItem()
            delegate?.didFailToDiscoverPeripheralServices()
            return
        }
        if let peripheralServices = peripheral.services {
            for service in peripheralServices {
                if service.uuid.isEqual(argonServiceUUID) {
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
        var txCharacteristic: CBCharacteristic?
        var rxCharacteristic: CBCharacteristic?
        if service.uuid.isEqual(argonServiceUUID) {
            if let serviceCharacteristics = service.characteristics {
                for characteristic in serviceCharacteristics {
                    if characteristic.uuid.isEqual(txCharacteristicUUID) {
                        txCharacteristic = characteristic
                    } else if characteristic.uuid.isEqual(rxCharacteristicUUID) {
                        rxCharacteristic = characteristic
                    }
                }
            }
        }
        
        if let txCharacteristic = txCharacteristic, let rxCharacteristic = rxCharacteristic  {
            restartTimeoutWorkItem()
            peripheral.setNotifyValue(true, for: txCharacteristic)
            if operation == .searchWiFi {
                if let searchWiFiRequestData = Constants.Bluetooth.searchWiFiRequest.rawValue.data(using: .utf8) {
                    peripheral.writeValue(searchWiFiRequestData, for: rxCharacteristic, type: .withoutResponse)
                } else {
                    //No need to handle this as this will never happen
                }
            } else if operation == .validateWiFiPassword {
                if let name = ssidName, let password = wifiPassword {
                    let request = String(format: Constants.Bluetooth.validateWiFiPasswordRequest.rawValue, name, password)
                    if let validateWiFiPasswordData = request.data(using: .utf8) {
                        peripheral.writeValue(validateWiFiPasswordData, for: rxCharacteristic, type: .withoutResponse)
                        ssidName = nil
                        wifiPassword = nil
                    } else {
                        //No need to handle this as this will never happen
                    }
                }
            } else {
                //No need to handle this as this will never happen
            }
        } else {
            cancelTimeoutWorkItem()
            delegate?.didFailToDiscoverCharacteristics()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil || !characteristic.isNotifying {
            cancelTimeoutWorkItem()
            delegate?.didFailToUpdateNotificationState()
            return
        }
        restartTimeoutWorkItem()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let _ = error {
            cancelTimeoutWorkItem()
            delegate?.didFailToUpdateValueForCharacteristic()
            return
        }
        
        if let characteristicValue = characteristic.value {
            if operation == .searchWiFi {
                if let wifiNetworksArray = try? JSONSerialization.jsonObject(with: characteristicValue, options: []) as? [String] {
                    print(wifiNetworksArray)
                    cancelTimeoutWorkItem()
                    delegate?.didUpdateValueForWiFiNetworks(with: wifiNetworksArray)
                    return
                }
            } else if operation == .validateWiFiPassword {
                if let wifiPasswordUpdateResponse = try? JSONSerialization.jsonObject(with: characteristicValue, options: []) as? [String: Any] {
                    print(wifiPasswordUpdateResponse)
                    cancelTimeoutWorkItem()
                    delegate?.didUpdateValueForWiFiPassword(with: wifiPasswordUpdateResponse)
                    return
                }
            } else {
                //No need to handle this as this will never happen
            }
        }
        cancelTimeoutWorkItem()
        delegate?.didFailToUpdateValueForCharacteristic()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //ToDo
    }
    
}
