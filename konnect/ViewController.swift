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
        if Bluetooth.shared.state == .offOrUnknown {
            bluetoothOffOrUnknown()
        } else {
            bluetoothOn()
        }
    }
    
    func bluetoothOffOrUnknown() {
        self.showAlert(message: Constants.UserInterface.bluetoothOffOrUnknown.rawValue, primaryActionTitle: Constants.UserInterface.okActionTitle.rawValue) { () -> (Void) in
        }
    }
    
    func bluetoothOn() {
        self.performSegue(withIdentifier: Constants.Storyboard.peripheralListView.rawValue, sender: nil)
    }
}

