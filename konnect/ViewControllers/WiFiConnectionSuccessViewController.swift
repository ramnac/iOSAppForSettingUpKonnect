//
//  WiFiSetUpSuccessViewController.swift
//  konnect
//
//  Created by Ram on 28/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

class WiFiConnectionSuccessViewController: UIViewController {

    @IBOutlet weak var wifiSetUpSuccessLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customiseUserInterface()
    }
    
    private func customiseUserInterface() {
        navigationItem.title = Constants.UserInterface.NavigationTitle.wifiConnectionSuccess.rawValue
        wifiSetUpSuccessLabel.text = Constants.UserInterface.wifiSetUpSuccess.rawValue
        navigationItem.hidesBackButton = true
    }

}
