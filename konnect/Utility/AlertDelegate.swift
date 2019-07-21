//
//  Alertable.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import Foundation
import UIKit

protocol AlertDelegate: class {
    func showAlert(message: String, primaryActionTitle: String, okActionHandler:(()->(Swift.Void))?)
}

extension AlertDelegate where Self: UIViewController {
    func showAlert(message: String, primaryActionTitle: String, okActionHandler:(()->(Swift.Void))?) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: primaryActionTitle, style: .default) { (UIAlertAction) -> Void in
            if let handler = okActionHandler {
                handler()
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
