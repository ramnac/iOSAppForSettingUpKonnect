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
    @IBOutlet weak var scanForWifiNetworksButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startPeripheralScan()
        addObserver(forNotification: UIApplication.didEnterBackgroundNotification)
        hideScanForWifiNetworksButton()
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
    
    private func hideScanForWifiNetworksButton() {
        scanForWifiNetworksButton.isHidden = true
    }
    
    private func showScanForWifiNetworksButton() {
        scanForWifiNetworksButton.isHidden = false
        scanForWifiNetworksButton.setTitle(Constants.UserInterface.Button.scanForWifiNetworks.rawValue, for: .normal)
    }
    
    @IBAction func scanForWiFiNetworksButtonTapped(_ sender: Any) {
        let bluetooth = Bluetooth.shared
        bluetooth.delegate = self
        if let bluetoothState = bluetooth.state {
            if bluetoothState == .on {
                statusLabel.text = Constants.UserInterface.searchingWiFi.rawValue
                showLoadingIndicator(withNetworkActivityIndicatorVisible: false)
                Bluetooth.shared.scanWiFiNetworks()
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
        Bluetooth.shared.delegate = nil
        showScanForWifiNetworksButton()
    }
    
    func didConnectedToInvalidPeripheral() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.invalidPeripheralConnected.rawValue)
    }
    
    func didFailedToConnectPeripheral() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.failToConnectPeripheral.rawValue)
    }
    
    func didFailToDiscoverPeripheralServices() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.failToDiscoverPeripheralServices.rawValue)
    }
    
    func didFailToDiscoverCharacteristics() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.failToDiscoverCharacteristics.rawValue)
    }
    
    func didFailToUpdateNotificationState() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.failToUpdateNotificationState.rawValue)
    }
    
    func didFailToUpdateValueForCharacteristic() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.failToUpdateValueForCharacteristic.rawValue)
    }
    
    private func handleExceptionWithAnAlertMessage(message: String) {
        doResetStatusLabelAndHideLoadingIndicator()
        showAlert(message: message, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { [weak self] in
            self?.clearBluetoothDelegateAndPopToRootViewController()
        }
    }
}
