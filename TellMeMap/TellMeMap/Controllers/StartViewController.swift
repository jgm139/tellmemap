//
//  StartViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 23/07/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CloudKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkingiCloudCredentials()
    }
    
    func checkingiCloudCredentials() {
        
        CKContainer.default().accountStatus {
            (accountStat, error) in
            
            if (accountStat == .available) {
                DispatchQueue.main.async( execute: {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlacesListVC") as? TableViewController
                    {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            }
            else {
                DispatchQueue.main.async( execute: {
                    let alert = UIAlertController(title: "Sign in to iCloud", message: "Sign in to your iCloud account to use TellMeMap. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }

}
