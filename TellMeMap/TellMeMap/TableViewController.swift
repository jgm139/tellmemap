//
//  TableViewController.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 05/11/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    //MARK: Properties
    @IBOutlet var myTableView: UITableView!
    var myDataSource: DSTable!
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.myDataSource = DSTable()
        self.myTableView.dataSource = myDataSource
    }

}
