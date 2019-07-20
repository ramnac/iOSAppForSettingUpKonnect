//
//  ViewController.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, Alertable {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customiseUserInterface()
    }
    
    private func customiseUserInterface() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func scanBluetoothButtonTapped(_ sender: Any) {
        let bluetooth = Bluetooth.shared
        bluetooth.delegate = self
        if let bluetoothState = bluetooth.state {
            if bluetoothState == .offOrUnknown {
                handleBluetoothOffState()
            } else {
                bluetoothPoweredOn()
            }
        }
    }
    
    func handleBluetoothOffState() {
        self.showAlert(message: Constants.UserInterface.bluetoothOffOrUnknown.rawValue, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { () -> (Void) in
        }
    }
}

extension ViewController: BluetoothDelegate {
    func bluetoothPoweredOn() {
        self.performSegue(withIdentifier: Constants.Storyboard.peripheralListView.rawValue, sender: nil)
    }
}

