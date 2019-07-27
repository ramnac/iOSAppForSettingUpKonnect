//
//  PasswordEntryViewController.swift
//  konnect
//
//  Created by Ram on 28/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

class PasswordEntryViewController: UIViewController, LoadingIndicatorDelegate, AlertDelegate {
    
    var ssidName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func clearBluetoothDelegate() {
        Bluetooth.shared.delegate = nil
    }
    
    @IBAction func doneButtonTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
        
        //ToDo in the bluetooth class the state should be validated.. not here.. need to do that change every where
        if let passwordText = sender.text {
            let bluetooth = Bluetooth.shared
            bluetooth.delegate = self
            if let bluetoothState = bluetooth.state {
                if bluetoothState == .on {
                    showLoadingIndicator(withNetworkActivityIndicatorVisible: false)
                    Bluetooth.shared.validateWiFiPassword(password: passwordText, forSSID: ssidName)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PasswordEntryViewController: BluetoothDelegate {
    func didUpdateValueForWiFiPassword(with jsonResponse:[String: Any]) {
        clearBluetoothDelegate()
        hideLoadingIndicator()
        if let wifiSetUpResponse = jsonResponse[Constants.Bluetooth.wifiSetUpKeyName.rawValue] as? String {
            if wifiSetUpResponse == Constants.Bluetooth.wifiSetUpSuccess.rawValue {
                performSegue(withIdentifier: Constants.Storyboard.wifiSetUpSuccessViewController.rawValue, sender: nil)
            } else if wifiSetUpResponse == Constants.Bluetooth.wifiSetUpFailure.rawValue {
                showAlert(message: Constants.UserInterface.wifiSetUpFailed.rawValue, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) {
                }
            }
        }
    }
    
    func didFailToDiscoverPeripheralServices() {
        print("didFailToDiscoverPeripheralServices")
    }
    func didFailToDiscoverCharacteristics() {
        print("didFailToDiscoverCharacteristics")
    }
    func didFailToUpdateNotificationState() {
        print("didFailToUpdateNotificationState")
    }
    func didFailToUpdateValueForCharacteristic() {
        print("didFailToUpdateValueForCharacteristic")
    }
    
    func didTimeoutOccured() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.timeoutOccured.rawValue)
    }
    
    private func handleExceptionWithAnAlertMessage(message: String) {
        clearBluetoothDelegate()
        hideLoadingIndicator()
        showAlert(message: message, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { 
        }
    }
}
