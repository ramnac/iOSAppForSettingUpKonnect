//
//  WiFiSetUpSuccessViewController.swift
//  konnect
//
//  Created by Ram on 28/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

class WiFiConnectionSuccessViewController: UIViewController {

    @IBOutlet weak var successTitleLabel: UILabel!
    @IBOutlet weak var successDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customiseUserInterface()
    }
    
    private func customiseUserInterface() {
        navigationItem.title = Constants.UserInterface.NavigationTitle.wifiConnectionSuccess.rawValue
        successTitleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        successTitleLabel.text = Constants.UserInterface.Label.wifiConnectionSuccessTitle.rawValue
        successDescriptionLabel.text = Constants.UserInterface.Label.wifiConnectionSuccessDescription.rawValue
        navigationItem.hidesBackButton = true
    }

}
