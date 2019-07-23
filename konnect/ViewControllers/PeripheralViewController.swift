//
//  PeripheralViewController.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

//ToDo: Need to handle the temporary interruption in this view + if you put the app into background and launch it.
//basically willresignactive and didenterbackground

class PeripheralViewController: UIViewController, LoadingIndicatorDelegate, AlertDelegate {
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startPeripheralScan()
        addObserver(forNotification: UIApplication.didEnterBackgroundNotification)
    }
    
    private func startPeripheralScan() {
        let bluetooth = Bluetooth.shared
        bluetooth.delegate = self
        if let bluetoothState = bluetooth.state {
            if bluetoothState == .on {
                statusLabel.text = Constants.UserInterface.scanning.rawValue
                showLoadingIndicator(withNetworkActivityIndicatorVisible: false)
                Bluetooth.shared.scanForPeripherals()
            }
        }
    }
    
    private func addObserver(forNotification notificationName: NSNotification.Name) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetBluetoothAndUserInterfaceState), name: notificationName, object: nil)
    }
    
    @objc private func resetBluetoothAndUserInterfaceState() {
        Bluetooth.shared.stopScan()
        doResetStatusLabelAndHideLoadingIndicator()
        clearBluetoothDelegateAndPopToRootViewController()
    }
    
    private func doResetStatusLabelAndHideLoadingIndicator() {
        statusLabel.text = ""
        hideLoadingIndicator()
    }
    
    private func clearBluetoothDelegateAndPopToRootViewController() {
        Bluetooth.shared.delegate = nil
        self.navigationController?.popToRootViewController(animated: true)
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

extension PeripheralViewController: BluetoothDelegate {
    func didPeripheralUnreached() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.peripheralTooFar.rawValue)
    }
    
    func didTimeoutOccured() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.timeoutOccured.rawValue)
    }
    
    func didPeripheralDiscovered() {
        statusLabel.text = Constants.UserInterface.connecting.rawValue
    }
    
    func didPeripheralConnected() {
        statusLabel.text = Constants.UserInterface.connected.rawValue
        hideLoadingIndicator()
    }
    
    func didConnectedToInvalidPeripheral() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.invalidPeripheralConnected.rawValue)
    }
    
    func didFailedToConnectPeripheral() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.failToConnectPeripheral.rawValue)
    }
    
    private func handleExceptionWithAnAlertMessage(message: String) {
        doResetStatusLabelAndHideLoadingIndicator()
        showAlert(message: message, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { [weak self] in
            self?.clearBluetoothDelegateAndPopToRootViewController()
        }
    }
}
