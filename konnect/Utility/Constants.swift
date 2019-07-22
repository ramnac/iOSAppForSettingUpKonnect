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
        case invalidPeripheralConnected = "Device isn't recognised, please try again"
    }
    
    enum Storyboard: String {
        case peripheralViewController = "peripheralViewController"
    }
    
    enum Bluetooth: String {
        case serviceUUID = "6FA90001-5C4E-48A8-94F4-8030546F36FC"
        case rxCharacterisiticUUID = "6FA90004-5C4E-48A8-94F4-8030546F36FC"
        case txCharacterisiticUUID = "6FA90003-5C4E-48A8-94F4-8030546F36FC"
        
        enum Numbers: Int {
            case rssiMinimumStrength = -90
            case scanTimeoutSeconds = 15
        }
    }
}
