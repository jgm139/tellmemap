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
    var placesSorted = [Category: [PlaceItem]]()
    var heightSection: CGFloat = 30
    
    
    // MARK: - Table View Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(refreshPlaces), for: .valueChanged)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        activityIndicator()
        indicator.startAnimating()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        ckManager.getPlaces {
            (finish) in
            if finish {
                DispatchQueue.main.async( execute: {
                    self.sortData()
                    self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                    self.indicator.hidesWhenStopped = true
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.sortData()
        self.tableView.reloadData()
    }
    
    func sortData() {
        Category.allCases.forEach {
            category in
            placesSorted[category] = CloudKitManager.places.filter({ $0.category == category })
        }
    }
    
    @objc func refreshPlaces() {
        ckManager.getPlaces {
            (finish) in
            if finish {
                DispatchQueue.main.async( execute: {
                    self.sortData()
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                })
            }
        }
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
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
                vc.item = self.placesSorted[Category(id: self.tv.indexPathForSelectedRow!.section)!]![self.tv.indexPathForSelectedRow!.row]
            }
        }
    }
    
    // MARK: - Table View Controller
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Category.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableSection = Category(id: section), let placeData = placesSorted[tableSection] {
            return placeData.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let tableSection = Category(id: section), let placeData = placesSorted[tableSection] {
            if placeData.count > 0 {
                return Category.allCases[section].rawValue
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let tableSection = Category(id: section), let placeData = placesSorted[tableSection] {
            if placeData.count > 0 {
                return heightSection
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let tableSection = Category(id: section), let placeData = placesSorted[tableSection] {
            if placeData.count > 0 {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: heightSection))
                view.backgroundColor = UIColor(red: 250/255, green: 240/255, blue: 219/255, alpha: 1.0)
                
                let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: heightSection))
                label.font = UIFont.boldSystemFont(ofSize: 18)
                label.textColor = UIColor.black
                label.text = Category(id: section)?.rawValue
                
                view.addSubview(label)
                
                return view
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableSection = Category(id: indexPath.section)!
        let item = placesSorted[tableSection]![indexPath.row]
        
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
                let tableSection = Category(id: indexPath.section)!
                let placeToDelete = placesSorted[tableSection]![indexPath.row]
                
                ckManager.deletePlace(withName: placeToDelete.name!)
                self.placesSorted[tableSection]?.remove(at: indexPath.row)
                
                DispatchQueue.main.async( execute: {
                    self.tableView.deleteRows(at: [indexPath], with: .right)
                })
            default: break
        }
    }
}
