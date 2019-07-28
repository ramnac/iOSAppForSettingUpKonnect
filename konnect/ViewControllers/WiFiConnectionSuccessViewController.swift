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

        // Do any additional setup after loading the view.
        wifiSetUpSuccessLabel.text = Constants.UserInterface.wifiSetUpSuccess.rawValue
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
