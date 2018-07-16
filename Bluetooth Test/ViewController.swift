//
//  ViewController.swift
//  Bluetooth Test
//
//  Created by Max Langer on 11.07.18.
//  Copyright © 2018 Max Langer. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    let manager = BluetoothManager()
    
    var sightings = [BluetoothManager.Sighting]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager.peripheralCallback = { sightings in
            DispatchQueue.main.async {            
                self.sightings = sightings
                self.tableView.reloadData()
            }
        }
        
        self.manager.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sightings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        let sighting = self.sightings[indexPath.row]
        
        cell.textLabel?.text = sighting.name
        cell.detailTextLabel?.text = "\(sighting.rssi)"
        
        return cell
    }
    
    
}

