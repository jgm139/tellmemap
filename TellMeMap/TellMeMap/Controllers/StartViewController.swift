//
//  StartViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 23/07/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkingiCloudCredentials()
    }
    
    func checkingiCloudCredentials() {
        CKContainer.default().accountStatus {
            (accountStat, error) in
            
            if (accountStat == .available) {
                
                CKContainer.default().requestApplicationPermission(.userDiscoverability) {
                (status, error) in
                    CKContainer.default().fetchUserRecordID {
                        (record, error) in
                        
                        if let recordUser = record?.recordName {
                            DispatchQueue.main.async( execute: {
                                guard let myDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                    return
                                }
                                
                                let myContext = myDelegate.persistentContainer.viewContext
                                
                                let request = NSFetchRequest<User>(entityName: "User")
                                let pred = NSPredicate(format: "icloud_id LIKE %@", argumentArray: [recordUser])
                                request.predicate = pred
                                
                                do {
                                    let users = try myContext.fetch(request)
                                    
                                    if users.isEmpty {
                                            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpViewController
                                            {
                                                vc.modalPresentationStyle = .popover
                                                self.present(vc, animated: true, completion: nil)
                                            }
                                    } else {
                                            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NC") as? UINavigationController
                                            {
                                                vc.modalPresentationStyle = .fullScreen
                                                self.present(vc, animated: true, completion: nil)
                                            }
                                    }
                                } catch {
                                    fatalError("Failed to fetch entities: \(error)")
                                }
                            })
                        }
                    }
                }
                
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
