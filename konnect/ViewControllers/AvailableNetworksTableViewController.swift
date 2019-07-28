//
//  AvailableNetworksTableViewController.swift
//  konnect
//
//  Created by Ram on 28/07/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import UIKit

class AvailableNetworksTableViewController: UITableViewController {
    
    var wifiNetworkSSIDs: [String]!
    var selectedSSIDName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        customiseUserInterface()
    }
    
    private func customiseUserInterface() {
        navigationItem.title = Constants.UserInterface.NavigationTitle.availableNetwork.rawValue
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return wifiNetworkSSIDs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.availableNetworksTableViewCell.rawValue, for: indexPath)
        cell.textLabel?.text = wifiNetworkSSIDs[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedSSIDName = wifiNetworkSSIDs[indexPath.row]
        performSegue(withIdentifier: Constants.Storyboard.connectNetworkViewController.rawValue, sender: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.connectNetworkViewController.rawValue {
            if let connectNetworkViewController = segue.destination as? ConnectNetworkViewController {
                connectNetworkViewController.ssidName = selectedSSIDName
            }
        }
    }

}
