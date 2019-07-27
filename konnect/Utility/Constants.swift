//
//  Constants.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import Foundation

enum Constants {
    
    enum UserInterface: String {
        case bluetoothOffOrUnknown = "Your device's bluetooth is not enabled. Please enable to continue"
        case okActionTitle = "Ok"
        case peripheralTooFar = "Device is too far, please move closer and try again"
        case timeoutOccured = "Couldn't find any device, please try again"
        case scanning = "Scanning for device"
        case connecting = "Connecting to device"
        case connected = "Connected to device"
        case searchingWiFi = "Searching WiFi Networks"
        case invalidPeripheralConnected = "Device isn't recognised, please try again"
        case failToConnectPeripheral = "Couldn't connect to peripheral - some weird issue"
        case failToDiscoverPeripheralServices = "failed to discover peripheral services"
        case failToDiscoverCharacteristics = "failed to discover characteristics"
        case failToUpdateNotificationState = "failed to update Notification state"
        case failToUpdateValueForCharacteristic = "failed to update value for characteristic"
        case noWiFiNetworksFound = "No wifi network available"
        case wifiSetUpSuccess = "The Andersen chargepoint unit is now connected to the local WiFi network"
        case wifiSetUpFailed = "Wifi set up is failed. Might be invalid password"
        
        enum Button: String {
            case scanForWifiNetworks = "SCAN FOR WiFi NETWORKS"
        }
    }
    
    enum Storyboard: String {
        case peripheralViewController = "peripheralViewController"
        case availableNetworksTableViewController = "availableNetworksTableViewController"
        case availableNetworksTableViewCell = "availableNetworksTableViewCell"
        case passwordEntryViewController = "passwordEntryViewController"
        case wifiSetUpSuccessViewController = "wifiSetUpSuccessViewController"
    }
    
    enum Bluetooth: String {
        case serviceUUID = "6FA90001-5C4E-48A8-94F4-8030546F36FC"
        case rxCharacterisiticUUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
        case txCharacterisiticUUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
        case deviceNamePrefix = "Argon-"
        case searchWiFiRequest = "{\"request\":\"wlanscan\"}"
        case validateWiFiPasswordRequest = "{\"request\":\"wifi\",\"ssid\":\"%@\",\"psk\":\"%@\"}"
        
        case wifiSetUpKeyName = "wifisetup"
        case wifiSetUpSuccess = "ok"
        case wifiSetUpFailure = "failed"
        
        enum Numbers: Int {
            case rssiMinimumStrength = -90
            case scanTimeoutInSeconds = 30
        }
    }
}
