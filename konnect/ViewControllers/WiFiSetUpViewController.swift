//
//  ViewController.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

class WiFiSetUpViewController: UIViewController, AlertDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customiseUserInterface()
    }
    
    private func customiseUserInterface() {
        navigationController?.navigationBar.isHidden = true
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
    func didBluetoothPoweredOn() {
        performSegue(withIdentifier: Constants.Storyboard.peripheralViewController.rawValue, sender: nil)
    }
    
    func didBluetoothOffOrUnknown() {
        Bluetooth.shared.delegate = nil
        showAlert(message: Constants.UserInterface.bluetoothOffOrUnknown.rawValue, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { () -> (Void) in
        }
    }
}

