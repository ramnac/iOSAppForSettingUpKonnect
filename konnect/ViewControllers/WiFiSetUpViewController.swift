//
//  ViewController.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

class WiFiSetUpViewController: UIViewController, AlertDelegate {

    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        customiseUserInterface()
    }
    
    private func customiseUserInterface() {
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = Constants.UserInterface.NavigationTitle.wifiSetUp.rawValue
        continueButton.setTitle(Constants.UserInterface.Button.wifiSetUp.rawValue, for: .normal)
    }
    
    @IBAction func scanBluetoothButtonTapped(_ sender: Any) {
        let bluetooth = Bluetooth.shared
        bluetooth.delegate = self
        if let bluetoothState = bluetooth.state {
            if bluetoothState == .offOrUnknown {
                didBluetoothOffOrUnknown()
            } else {
                didBluetoothPoweredOn()
            }
        }
    }
}

extension WiFiSetUpViewController: BluetoothDelegate {
    func didTimeoutOccured() {
        //No need to handle anything in this
    }
    
    func didBluetoothPoweredOn() {
        Bluetooth.shared.delegate = nil
        performSegue(withIdentifier: Constants.Storyboard.connectedDevicesViewController.rawValue, sender: nil)
    }
    
    func didBluetoothOffOrUnknown() {
        Bluetooth.shared.delegate = nil
        showAlert(message: Constants.UserInterface.bluetoothOffOrUnknown.rawValue, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { () -> (Void) in
        }
    }
}

