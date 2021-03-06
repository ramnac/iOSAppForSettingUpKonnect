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
    
    @IBOutlet weak var countDownTimerLabel: UILabel!
    fileprivate var wifiNetworks: [String]?
    
    fileprivate var timer: Timer?
    private var timeLeft: Int = Constants.UserInterface.Numbers.countDownTimerTotalSecondsLeft.rawValue
    
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
        countDownTimerLabel.textColor = UIColor.red
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
    
    //Since this method hidesLoadingIndicator which will be called from any view controller which enters background
    @objc private func resetBluetoothAndUserInterfaceState() {
        doResetStatusLabelAndHideLoadingIndicator()
        clearBluetoothDelegate()
        invalidateTimerAndResetCountDownTimerLabel()
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
    
    @objc fileprivate func onTimerFires() {
        timeLeft -= 1
        if timeLeft > 1 {
            countDownTimerLabel.text = String(format: Constants.UserInterface.Label.countDownTimerPluralForm.rawValue, timeLeft)
        } else {
            countDownTimerLabel.text = String(format: Constants.UserInterface.Label.countDownTimerSingularForm.rawValue, timeLeft)
        }
        
        if timeLeft <= 0 {
            invalidateTimerAndResetCountDownTimerLabel()
            showScanForWifiNetworksButton()
        }
    }
    
    private func invalidateTimerAndResetCountDownTimerLabel() {
        timer?.invalidate()
        timer = nil
        countDownTimerLabel.text = ""
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
    
    func didPeripheralConnected(deviceName: String) {
        statusLabel.text = String(format: Constants.UserInterface.connected.rawValue, deviceName)
        hideLoadingIndicator()
        clearBluetoothDelegate()
        countDownTimerLabel.text = String(format: Constants.UserInterface.Label.countDownTimerPluralForm.rawValue, timeLeft)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
    func didConnectedToInvalidPeripheral() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.invalidPeripheralConnected.rawValue)
    }
    
    func didFailedToConnectPeripheral(error: Error?) {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.failToConnectPeripheral.rawValue, error: error)
    }
    
    func didFailToDiscoverPeripheralServices(error: Error?) {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.generalBluetoothError.rawValue, error: error)
    }
    
    func didFailToDiscoverCharacteristics(error: Error?) {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.generalBluetoothError.rawValue, error: error)
    }
    
    func didFailToUpdateNotificationState(error: Error?) {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.generalBluetoothError.rawValue, error: error)
    }
    
    func didFailToUpdateValueForCharacteristic(error: Error?) {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.generalBluetoothError.rawValue, error: error)
    }
    
    func didFailedToFindConnectedPeripheral() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.failToFindConnectedPeripheral.rawValue)
    }
    
    func didUpdateValueForWiFiNetworks(with wifiNetworksArray: [String]) {
        hideLoadingIndicator()
        clearBluetoothDelegate()
        wifiNetworks = wifiNetworksArray
        performSegue(withIdentifier: Constants.Storyboard.availableNetworksTableViewController.rawValue, sender: nil)
    }
    
    func didFailToDiscoverWiFiNetworks() {
        handleExceptionWithAnAlertMessage(message: Constants.UserInterface.noWiFiNetworksFound.rawValue)
    }
    
    private func handleExceptionWithAnAlertMessage(message: String, error: Error? = nil) {
        clearBluetoothDelegate()
        doResetStatusLabelAndHideLoadingIndicator()
        hideScanForWifiNetworksButton()
        var errorMessage = message
        if let _ = error {
            errorMessage = errorMessage + " " + error!.localizedDescription
        }
        showAlert(message: errorMessage, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
