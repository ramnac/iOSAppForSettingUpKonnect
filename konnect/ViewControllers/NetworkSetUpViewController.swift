//
//  NetworkSetUpViewController.swift
//  konnect
//
//  Created by Ram on 2/08/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

class NetworkSetUpViewController: UIViewController {

    @IBOutlet weak var networkSetUpLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customiseUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func customiseUserInterface() {
        navigationItem.title = Constants.UserInterface.NavigationTitle.networkSetUp.rawValue
        networkSetUpLabel.text = Constants.UserInterface.Label.networkSetUp.rawValue
        startButton.setTitle(Constants.UserInterface.Button.start.rawValue, for: .normal)
    }

}
