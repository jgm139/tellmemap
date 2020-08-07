//
//  TableViewController.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 05/11/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    // MARK: - Properties
    var ckManager = CloudKitManager()
    
    // MARK: - Table View Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(refreshPlaces), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ckManager.getPlaces {
            (finish) in
            if finish {
                DispatchQueue.main.async( execute: {
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    @objc func refreshPlaces() {
        ckManager.getPlaces {
            (finish) in
            if finish {
                DispatchQueue.main.async( execute: {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                })
            }
        }
    }
    
    
    // MARK: - Actions
    @IBAction func unwindToPlaceList(sender: UIStoryboardSegue) {}
    
    
    // MARK: - Table View Controller
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ckManager.places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = ckManager.places[indexPath.row]
        
        guard let newCell = tableView.dequeueReusableCell(withIdentifier: "placeTableViewCell", for: indexPath) as? PlaceTableViewCell else {
            fatalError("The dequeued cell is not an instance of PlaceTableViewCell.")
        }
        
        newCell.setContent(item: item)
        
        return newCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            case .delete:
                let placeToDelete = ckManager.places[indexPath.row]
                ckManager.deletePlace(withName: placeToDelete.name!)
            default: break
        }
    }
}
