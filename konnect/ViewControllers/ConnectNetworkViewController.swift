//
//  PasswordEntryViewController.swift
//  konnect
//
//  Created by Ram on 28/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

class ConnectNetworkViewController: UIViewController, LoadingIndicatorDelegate, AlertDelegate {
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ssidName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        customiseUserInterface()
    }
    
    private func customiseUserInterface() {
        navigationItem.title = Constants.UserInterface.NavigationTitle.connectNetwork.rawValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        passwordTextField.resignFirstResponder()
    }
    
    private func clearBluetoothDelegate() {
        Bluetooth.shared.delegate = nil
    }
    
    @IBAction func doneButtonTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
        if let passwordText = sender.text {
            Bluetooth.shared.delegate = self
            showLoadingIndicator(withNetworkActivityIndicatorVisible: false)
            Bluetooth.shared.validateWiFiPassword(password: passwordText, forSSID: ssidName)
        }
    }

}

extension ConnectNetworkViewController: BluetoothDelegate {
    func didUpdateValueForWiFiPassword(with jsonResponse:[String: Any]) {
        clearBluetoothDelegate()
        hideLoadingIndicator()
        if let wifiSetUpResponse = jsonResponse[Constants.Bluetooth.wifiSetUpKeyName.rawValue] as? String {
            if wifiSetUpResponse == Constants.Bluetooth.wifiSetUpSuccess.rawValue {
                performSegue(withIdentifier: Constants.Storyboard.wifiConnectionSuccessViewController.rawValue, sender: nil)
            } else if wifiSetUpResponse == Constants.Bluetooth.wifiSetUpFailure.rawValue {
                showAlert(message: Constants.UserInterface.wifiSetUpFailed.rawValue, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { [weak self] in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    func didFailedToFindConnectedPeripheral() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.failToFindConnectedPeripheral.rawValue)
    }
    
    func didBluetoothOffOrUnknown() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.bluetoothOffOrUnknown.rawValue)
    }
    
    func didTimeoutOccured() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.timeoutOccured.rawValue)
    }
    
    private func handleExceptionWithAnAlertMessage(message: String) {
        clearBluetoothDelegate()
        hideLoadingIndicator()
        showAlert(message: message, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
