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
    
    // MARK: - Outlets
    @IBOutlet var tv: UITableView!
    
    
    // MARK: - Properties
    var ckManager = CloudKitManager()
    var indicator = UIActivityIndicatorView()
    
    // MARK: - Table View Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(refreshPlaces), for: .valueChanged)
        
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .white
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        ckManager.getPlaces {
            (finish) in
            if finish {
                DispatchQueue.main.async( execute: {
                    self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                    self.indicator.hidesWhenStopped = true
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {}
    
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
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    
    // MARK: - Actions
    @IBAction func unwindToPlaceList(sender: UIStoryboardSegue) {
        if sender.identifier == "saveMessageAndLeave" {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "placeDetail" {
            if let vc = segue.destination as? PlaceDetailViewController {
                vc.item = CloudKitManager.places[self.tv.indexPathForSelectedRow!.row]
            }
        }
    }
    
    // MARK: - Table View Controller
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CloudKitManager.places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = CloudKitManager.places[indexPath.row]
        
        guard let newCell = tableView.dequeueReusableCell(withIdentifier: "placeTableViewCell", for: indexPath) as? PlaceTableViewCell else {
            fatalError("The dequeued cell is not an instance of PlaceTableViewCell.")
        }
        
        newCell.setContent(item: item)
        newCell.selectionStyle = .none
        
        return newCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            case .delete:
                let placeToDelete = CloudKitManager.places[indexPath.row]
                ckManager.deletePlace(withName: placeToDelete.name!)
                CloudKitManager.places.remove(at: indexPath.row)
                
                DispatchQueue.main.async( execute: {
                    self.tableView.deleteRows(at: [indexPath], with: .right)
                })
            default: break
        }
    }
}
