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
    
    // MARK: - Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkingiCloudCredentials()
    }
    
    func checkAccountStatus(withCompletionHandler completion: @escaping (_ accountAvailable: Bool) -> Void) {
        CKContainer.default().accountStatus {
            (accountStat, error) in
            if (accountStat == .available) {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getCloudID(withCompletionHandler completion: @escaping (_ success: Bool, _ cloudID: String) -> Void) {
        CKContainer.default().requestApplicationPermission(.userDiscoverability) {
            (status, error) in
            CKContainer.default().fetchUserRecordID {
                (record, error) in
                if let cloudID = record?.recordName {
                    completion(true, cloudID)
                }
            }
        }
    }
    
    func checkingiCloudCredentials() {
        self.activityIndicator.startAnimating()
        
        checkAccountStatus {
            (statusAvailable) in
            if statusAvailable {
                if SessionManager.isSessionStarted() {
                    self.launchHomeView()
                } else {
                    self.getCloudID(withCompletionHandler: {
                        (success, cloudID) in
                        if success {
                            self.userIsSignUp(cloudID: cloudID) {
                                (isSigned) in
                                if isSigned {
                                    self.launchHomeView()
                                } else {
                                    self.launchSignUpView()
                                }
                            }
                        }
                    })
                }
            } else {
                self.alertToSignInICloud()
            }
        }
    }
    
    func alertToSignInICloud() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
            
            let alert = UIAlertController(title: "Sign in to iCloud", message: "Sign in to your iCloud account to use TellMeMap. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func launchHomeView() {
        SessionManager.initSession()
        
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
            
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabNav") as? UITabBarController {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        })
    }
    
    func launchSignUpView() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
            
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpViewController {
               vc.modalPresentationStyle = .popover
               self.present(vc, animated: true, completion: nil)
            }
        })
    }
    
    func userIsSignUp(cloudID: String, completion: @escaping (_ isSigned: Bool) -> Void) {
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "icloud_id == %@", argumentArray: [cloudID]))
        
        CloudKitManager.sharedCKManager.publicDB.perform(query, inZoneWith: nil, completionHandler: {
            (users, error) in
            if error == nil {
                if users!.isEmpty {
                    completion(false)
                } else {
                    UserSessionSingleton.session.userItem = UserItem(record: users![0])
                    
                    completion(true)
                }
            }
        })
    }

}
