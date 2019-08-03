//
//  BluetoothManager.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import Foundation
import CoreBluetooth

import UIKit

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
    
    //Required method
    func didTimeoutOccured()
    func didBluetoothOffOrUnknown()
    
    func didPeripheralDiscovered()
    func didPeripheralConnected(deviceName: String)
    func didConnectedToInvalidPeripheral()
    func didFailedToConnectPeripheral(error: Error?)
    func didFailToDiscoverPeripheralServices(error: Error?)
    func didFailToDiscoverCharacteristics(error: Error?)
    func didFailToUpdateNotificationState(error: Error?)
    func didFailToUpdateValueForCharacteristic(error: Error?)
    func didUpdateValueForWiFiNetworks(with wifiNetworksArray:[String])
    func didUpdateValueForWiFiPassword(with jsonResponse:[String: Any])
    func didFailedToFindConnectedPeripheral()
}

extension BluetoothDelegate {
    func didBluetoothPoweredOn() {}
    func didPeripheralUnreached() {}
    func didPeripheralDiscovered() {}
    func didPeripheralConnected(deviceName: String) {}
    func didConnectedToInvalidPeripheral() {}
    func didFailedToConnectPeripheral(error: Error?) {}
    func didFailToDiscoverPeripheralServices(error: Error?) {}
    func didFailToDiscoverCharacteristics(error: Error?) {}
    func didFailToUpdateNotificationState(error: Error?) {}
    func didFailToUpdateValueForCharacteristic(error: Error?) {}
    func didUpdateValueForWiFiNetworks(with wifiNetworksArray:[String]) {}
    func didUpdateValueForWiFiPassword(with jsonResponse:[String: Any]) {}
    func didFailedToFindConnectedPeripheral() {}
}

class Bluetooth: NSObject {
    
    static let shared = Bluetooth()
    
    private(set) var state: BluetoothState?
    
    private(set) var operation: BluetoothOperation?
    
    weak var delegate: BluetoothDelegate?
    
    private let argonServiceUUID = CBUUID(string: Constants.Bluetooth.serviceUUID.rawValue)
    private let rxCharacteristicUUID = CBUUID(string: Constants.Bluetooth.rxCharacterisiticUUID.rawValue)
    private let txCharacteristicUUID = CBUUID(string: Constants.Bluetooth.txCharacterisiticUUID.rawValue)
    private let includedServiceUUID = CBUUID(string: Constants.Bluetooth.includedServiceUUID.rawValue)
    
    private var peripheralToConnect: CBPeripheral?
    
    private var coreBluetoothManager: CBCentralManager!
    
    private var timeoutWorkItemReference: DispatchWorkItem?
    
    private var ssidName: String?
    private var wifiPassword: String?
    
    private var timeoutWorkItem: DispatchWorkItem {
        get {
            return DispatchWorkItem() {
                [weak self] in
                self?.delegate?.didTimeoutOccured()
                self?.resetBluetooth()
            }
        }
    }
    
    private override init() {
        super.init()
        coreBluetoothManager = CBCentralManager(delegate: self, queue: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetBluetooth), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func scanForPeripherals() {
        restartTimeoutWorkItem()
        coreBluetoothManager.scanForPeripherals(withServices: [argonServiceUUID], options: nil)
    }
    
    @objc private func resetBluetooth() {
        if let peripheral = peripheralToConnect {
            coreBluetoothManager.cancelPeripheralConnection(peripheral)
            peripheral.delegate = nil
            peripheralToConnect = nil
        }
        if state == .on {
            coreBluetoothManager.stopScan()
        }
        delegate = nil
        operation = nil
        ssidName = nil
        wifiPassword = nil
        cancelTimeoutWorkItem()
    }
    
    func performOperation(bluetoothOperation:BluetoothOperation) {
        guard let peripheralToConnect = peripheralToConnect else {
            delegate?.didFailedToFindConnectedPeripheral()
            resetBluetooth()
            return
        }
        restartTimeoutWorkItem()
        operation = bluetoothOperation
        peripheralToConnect.delegate = self
        peripheralToConnect.discoverServices([includedServiceUUID])
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
            resetBluetooth()
        } else {
            state = .offOrUnknown
            delegate?.didBluetoothOffOrUnknown()
            resetBluetooth()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        coreBluetoothManager.stopScan()
        if RSSI.int32Value < Int32(Constants.Bluetooth.Numbers.rssiMinimumStrength.rawValue) {
            delegate?.didPeripheralUnreached()
            resetBluetooth()
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
            delegate?.didConnectedToInvalidPeripheral()
            resetBluetooth()
            return
        }
        cancelTimeoutWorkItem()
        delegate?.didPeripheralConnected(deviceName: peripheralName)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.didFailedToConnectPeripheral(error: error)
        resetBluetooth()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //Handle this only if you have an user interface interaction with this use case
    }
}

extension Bluetooth: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let _ = error {
            delegate?.didFailToDiscoverPeripheralServices(error: error)
            resetBluetooth()
            return
        }
        if let peripheralServices = peripheral.services {
            for service in peripheralServices {
                if service.uuid.isEqual(includedServiceUUID) {
                    restartTimeoutWorkItem()
                    peripheral.discoverCharacteristics([rxCharacteristicUUID,txCharacteristicUUID], for: service)
                    return
                }
            }
        }
        delegate?.didFailToDiscoverPeripheralServices(error: error)
        resetBluetooth()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let _ = error {
            delegate?.didFailToDiscoverCharacteristics(error: error)
            resetBluetooth()
            return
        }
        var txCharacteristic: CBCharacteristic?
        var rxCharacteristic: CBCharacteristic?
        if service.uuid.isEqual(includedServiceUUID) {
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
            delegate?.didFailToDiscoverCharacteristics(error: error)
            resetBluetooth()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil || !characteristic.isNotifying {
            delegate?.didFailToUpdateNotificationState(error: error)
            resetBluetooth()
            return
        }
        restartTimeoutWorkItem()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let _ = error {
            delegate?.didFailToUpdateValueForCharacteristic(error: error)
            resetBluetooth()
            return
        }
        
        if let characteristicValue = characteristic.value {
            if operation == .searchWiFi {
                if let wifiNetworksArray = try? JSONSerialization.jsonObject(with: characteristicValue, options: []) as? [String] {
                    cancelTimeoutWorkItem()
                    delegate?.didUpdateValueForWiFiNetworks(with: wifiNetworksArray)
                    return
                }
            } else if operation == .validateWiFiPassword {
                if let wifiPasswordUpdateResponse = try? JSONSerialization.jsonObject(with: characteristicValue, options: []) as? [String: Any] {
                    delegate?.didUpdateValueForWiFiPassword(with: wifiPasswordUpdateResponse)
                    resetBluetooth()
                    return
                }
            } else {
                //No need to handle this as this will never happen
            }
        }
        delegate?.didFailToUpdateValueForCharacteristic(error: error)
        resetBluetooth()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //ToDo
    }
    
}
