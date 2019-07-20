//
//  PeripheralViewController.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

class PeripheralViewController: UIViewController, LoadingIndicatorDelegate, AlertDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        startPeripheralScan()
    }
    
    private func startPeripheralScan() {
        let bluetooth = Bluetooth.shared
        bluetooth.delegate = self
        if let bluetoothState = bluetooth.state {
            if bluetoothState == .on {
                self.showLoadingIndicator(withNetworkActivityIndicatorVisible: false)
                Bluetooth.shared.scanForPeripherals()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Bluetooth.shared.delegate = nil
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
        self.hideLoadingIndicator()
        self.showAlert(message: Constants.UserInterface.peripheralTooFar.rawValue, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { () -> (Void) in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func didTimeoutOccured() {
        self.hideLoadingIndicator()
        self.showAlert(message: Constants.UserInterface.timeoutOccured.rawValue, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { () -> (Void) in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
