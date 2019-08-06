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
        case okActionTitle = "Ok"
        
        case scanning = "Scanning for device"
        case connecting = "Connecting to device"
        case connected = "Connected to %@"
        
        case bluetoothOffOrUnknown = "Your device's bluetooth is not enabled. Please enable to continue"
        case peripheralTooFar = "Device is too far, please move closer and try again"
        case timeoutOccured = "Couldn't find any device, please try again"
        case invalidPeripheralConnected = "Device isn't recognised, please try again"
        
        case generalBluetoothError = "There was an issue connecting to your Andersen, please try again or contact support"
        
        //Yet to get the message
        case failToConnectPeripheral = "Fail to connect peripheral"
        case failToFindConnectedPeripheral = "Failed to find connected peripheral. Oops!"
        
        case noWiFiNetworksFound = "Unable to find WiFi, make sure your WiFi is on and in range"
        case wifiSetUpFailed = "Unable to connect to WiFi, make sure credentials are correct"
        
        enum NavigationTitle: String {
            case networkSetUp = "Network Setup"
            case wifiSetUp = "Enter WiFi Setup"
            case connectedDevices = "Connected Devices"
            case availableNetwork = "Available Network"
            case connectNetwork = "Connect Network"
            case wifiConnectionSuccess = "WiFi Connection Success"
        }
        
        enum Button: String {
            case start = "LET'S START"
            case wifiSetUp = "CONTINUE"
            case scanForWifiNetworks = "SCAN FOR WiFi NETWORKS"
        }
        
        enum Label: String {
            case networkSetUp = "Connect an Andersen chargepoint to the Konnect Cloud service"
            case wifiSetUpTitle = "Enter Setup Mode"
            case wifiSetUpDescription = "Press multi function setup button for 10 seconds until the front lights show solid amber"
            case wifiConnectionSuccessTitle = "Connection Success"
            case wifiConnectionSuccessDescription = "The Andersen chargepoint unit is now connected to the local WiFi network"
        }
    }
    
    enum Storyboard: String {
        case connectedDevicesViewController = "connectedDevicesViewController"
        case availableNetworksTableViewController = "availableNetworksTableViewController"
        case availableNetworksTableViewCell = "availableNetworksTableViewCell"
        case connectNetworkViewController = "connectNetworkViewController"
        case wifiConnectionSuccessViewController = "wifiConnectionSuccessViewController"
    }
    
    enum Bluetooth: String {
        case serviceUUID = "6FA90001-5C4E-48A8-94F4-8030546F36FC"
        case includedServiceUUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
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
            case scanTimeoutInSeconds = 60
        }
    }
}
