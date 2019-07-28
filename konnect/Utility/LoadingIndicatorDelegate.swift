//
//  LoadingIndicatorDelegate.swift
//  konnect
//
//  Created by Ram on 20/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import Foundation
import UIKit

protocol LoadingIndicatorDelegate: class {
    func showLoadingIndicator(withNetworkActivityIndicatorVisible: Bool)
    func hideLoadingIndicator()
}

extension LoadingIndicatorDelegate where Self:UIViewController {
    func showLoadingIndicator(withNetworkActivityIndicatorVisible: Bool) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        UIApplication.shared.isNetworkActivityIndicatorVisible = withNetworkActivityIndicatorVisible
        let spinnerView = UIView.init(frame: view.bounds)
        spinnerView.tag = 10000
        spinnerView.backgroundColor = UIColor.clear
        let activityIndicator = UIActivityIndicatorView.init()
        activityIndicator.color = UIColor.gray
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            self.view.addSubview(spinnerView)
        }
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            if UIApplication.shared.isIgnoringInteractionEvents {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.view.viewWithTag(10000)?.removeFromSuperview()
        }
    }
}
