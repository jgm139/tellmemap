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
    
    // MARK: Actions
    @IBAction func unwindToSignList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewMessageViewController, let sign = sourceViewController.newSign {
            self.myDataSource.insertCell(self.myTableView, inRow: self.myTableView.numberOfRows(inSection: 0), withSign: sign)
        }
    }

}
