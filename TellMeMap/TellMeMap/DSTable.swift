//
//  DSTable.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 06/11/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class DSTable: NSObject, UITableViewDataSource {
    var signs = [Sign]()
    
    override init() {
        let newLocation = CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417)
        signs.append(Sign(name: "Item 1", location: newLocation, description: "Description 1"))
        signs.append(Sign(name: "Item 2", location: newLocation, description: "Description 2"))
        signs.append(Sign(name: "Item 3", location: newLocation, description: "Description 3"))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.signs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = signs[indexPath.row]
        
        guard let newCell = tableView.dequeueReusableCell(withIdentifier: "signTableViewCell", for: indexPath) as? SignTableViewCell else {
            fatalError("The dequeued cell is not an instance of SignTableViewCell.")
        }
        
        newCell.setContent(item: item)
        
        return newCell
    }
    
    func insertCell(_ tableView: UITableView, inRow: Int, withSign: Sign) {
        self.signs.insert(withSign, at: inRow)
        let indexPath = IndexPath(row: inRow, section: 0)
        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.fade)
    }
    
}
