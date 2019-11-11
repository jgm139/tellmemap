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
        
        let plusButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 100, y: self.view.frame.height - 100), size: CGSize(width: 60, height: 60)))
        
        let icon = UIImage(systemName: "plus.circle.fill")
        plusButton.setImage(icon, for: .normal)
        
        plusButton.contentVerticalAlignment = .fill
        plusButton.contentHorizontalAlignment = .fill
        plusButton.imageEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        
        plusButton.addTarget(self, action: #selector(actionAddSign), for: .touchUpInside)
        
        self.navigationController?.view.addSubview(plusButton)
    }
    
    @objc func actionAddSign() {
        // Safe Present
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewSignVC") as? ViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            present(vc, animated: true, completion: nil)
        }
    }

}
