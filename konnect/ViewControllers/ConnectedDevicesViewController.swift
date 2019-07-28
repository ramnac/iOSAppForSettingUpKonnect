//
//  ConnectedDevicesViewController.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

//ToDo: Need to handle the temporary interruption in this view + if you put the app into background and launch it.
//basically willresignactive and didenterbackground

class ConnectedDevicesViewController: UIViewController, LoadingIndicatorDelegate, AlertDelegate {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scanForWifiNetworksButton: UIButton!
    
    fileprivate var wifiNetworks: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customiseUserInterface()
        startPeripheralScan()
        addObserver(forNotification: UIApplication.didEnterBackgroundNotification)
        hideScanForWifiNetworksButton()
    }
    
    private func customiseUserInterface() {
        navigationItem.title = Constants.UserInterface.NavigationTitle.connectedDevices.rawValue
        navigationItem.hidesBackButton = true
    }
    
    private func startPeripheralScan() {
        Bluetooth.shared.delegate = self
        statusLabel.text = Constants.UserInterface.scanning.rawValue
        showLoadingIndicator(withNetworkActivityIndicatorVisible: false)
        Bluetooth.shared.scanForPeripherals()
    }
    
    private func addObserver(forNotification notificationName: NSNotification.Name) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetBluetoothAndUserInterfaceState), name: notificationName, object: nil)
    }
    
    @objc private func resetBluetoothAndUserInterfaceState() {
        doResetStatusLabelAndHideLoadingIndicator()
        clearBluetoothDelegate()
    }
    
    private func doResetStatusLabelAndHideLoadingIndicator() {
        statusLabel.text = ""
        hideLoadingIndicator()
    }
    
    private func clearBluetoothDelegateAndPopToRootViewController() {
        clearBluetoothDelegate()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func clearBluetoothDelegate() {
        Bluetooth.shared.delegate = nil
    }
    
    private func hideScanForWifiNetworksButton() {
        scanForWifiNetworksButton.isHidden = true
    }
    
    private func showScanForWifiNetworksButton() {
    scanForWifiNetworksButton.setTitle(Constants.UserInterface.Button.scanForWifiNetworks.rawValue, for: .normal)
        scanForWifiNetworksButton.isHidden = false
    }
    
    @IBAction func scanForWiFiNetworksButtonTapped(_ sender: Any) {
        Bluetooth.shared.delegate = self
        statusLabel.text = Constants.UserInterface.searchingWiFi.rawValue
        showLoadingIndicator(withNetworkActivityIndicatorVisible: false)
        Bluetooth.shared.performOperation(bluetoothOperation: .searchWiFi)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.availableNetworksTableViewController.rawValue {
            if let availableNetworksTableViewController = segue.destination as? AvailableNetworksTableViewController, let _ = wifiNetworks {
                availableNetworksTableViewController.wifiNetworkSSIDs = wifiNetworks
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

extension ConnectedDevicesViewController: BluetoothDelegate {
    
    func didBluetoothOffOrUnknown() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.bluetoothOffOrUnknown.rawValue)
    }
    
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
        clearBluetoothDelegate()
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
    
    func didFailedToFindConnectedPeripheral() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.failToFindConnectedPeripheral.rawValue)
    }
    
    func didUpdateValueForWiFiNetworks(with wifiNetworksArray: [String]) {
        var wifiNetworksArrayCopy = wifiNetworksArray
        wifiNetworksArrayCopy = wifiNetworksArrayCopy.filter({ $0 != ""})
        if wifiNetworksArrayCopy.count == 0 {
            handleExceptionWithAnAlertMessage(message: Constants.UserInterface.noWiFiNetworksFound.rawValue)
            return
        }
        doResetStatusLabelAndHideLoadingIndicator()
        clearBluetoothDelegate()
        wifiNetworks = wifiNetworksArrayCopy
        performSegue(withIdentifier: Constants.Storyboard.availableNetworksTableViewController.rawValue, sender: nil)
    }
    
    private func handleExceptionWithAnAlertMessage(message: String) {
        clearBluetoothDelegate()
        doResetStatusLabelAndHideLoadingIndicator()
        showAlert(message: message, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
