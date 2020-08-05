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
    
    // MARK: - Properties
    var ckManager = CloudKitManager()
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkingiCloudCredentials()
    }
    
    func getCloudID(withCompletionHandler completion: @escaping (_ success: Bool, _ recordName: String, _ accountAvailable: Bool) -> Void) {
        CKContainer.default().accountStatus {
            (accountStat, error) in
            if (accountStat == .available) {
                CKContainer.default().requestApplicationPermission(.userDiscoverability) {
                (status, error) in
                    CKContainer.default().fetchUserRecordID {
                        (record, error) in
                        
                        if let recordName = record?.recordName {
                            completion(true, recordName, true)
                        }
                    }
                }
            } else {
                completion(false, "", false)
            }
        }
    }
    
    func checkingiCloudCredentials() {
        getCloudID(withCompletionHandler: {
            (success, recordName, accountAvailable) in
                if success {
                    self.userIsSignUp(recordUser: recordName) {
                        (isSigned) in
                        if isSigned {
                            
                            self.initSession()
                            
                            DispatchQueue.main.async(execute: {
                                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabNav") as? UITabBarController
                                {
                                    vc.modalPresentationStyle = .fullScreen
                                    self.present(vc, animated: true, completion: nil)
                                }
                            })
                        } else {
                            DispatchQueue.main.async(execute: {
                                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpViewController
                                {
                                    vc.modalPresentationStyle = .popover
                                    self.present(vc, animated: true, completion: nil)
                                }
                            })
                        }
                    }
                } else if !accountAvailable {
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "Sign in to iCloud", message: "Sign in to your iCloud account to use TellMeMap. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                }
        })
    }
    
    func userIsSignUp(recordUser: String, completion: @escaping (_ isSigned: Bool) -> Void) {
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "icloud_id == %@", argumentArray: [recordUser]))
        
        ckManager.privateDB.perform(query, inZoneWith: nil, completionHandler: {
            (users, error) in
            if error == nil {
                if users!.isEmpty {
                    completion(false)
                } else {
                    UserSessionSingleton.session.user = UserItem(record: users![0])
                    
                    completion(true)
                }
            }
        })
    }
    
    func initSession(){
        let request: NSFetchRequest<Session> = NSFetchRequest(entityName:"Session")
        let sessions = try? viewContext.fetch(request)
        
        if sessions!.count > 0 {
            print("Loading User Session \(UserSessionSingleton.session.user.nickname)")
            sessions![0].nickname = UserSessionSingleton.session.user.nickname
        } else {
            print("New User Session \(UserSessionSingleton.session.user.nickname)")
            let newSession = Session(context: viewContext)
            newSession.nickname = UserSessionSingleton.session.user.nickname
        }
        
        do {
            try viewContext.save()
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }

}
