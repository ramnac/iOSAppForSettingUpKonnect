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
        case bluetoothOffOrUnknown = "Bluetooth is Off. Enable it to proceed further"
        case okActionTitle = "Ok"
        case peripheralTooFar = "Device is too far!! Move closer and retry"
        case timeoutOccured = "Coundn't find any Argon device, please retry"
        case scanning = "Scanning..."
        case connecting = "Connecting..."
        case connected = "Connected..."
        case invalidPeripheralConnected = "Looks like not an Argin device, some issue!"
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
