//
//  DSTable.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 06/11/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import Foundation
import UIKit

class DSTable: NSObject, UITableViewDataSource {
    var signs = [Sign]()
    
    override init() {
        signs.append(Sign(name: "Item 1", location: "", description: "Description 1"))
        signs.append(Sign(name: "Item 2", location: "", description: "Description 2"))
        signs.append(Sign(name: "Item 3", location: "", description: "Description 3"))
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
    
}