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
                    if !self.userIsSignUp(recordUser: recordName) {
                        DispatchQueue.main.async(execute: {
                            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpViewController
                            {
                                vc.modalPresentationStyle = .popover
                                self.present(vc, animated: true, completion: nil)
                            }
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabNav") as? UITabBarController
                            {
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
                        })
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
    
    func userIsSignUp(recordUser: String) -> Bool {
        let request = NSFetchRequest<User>(entityName: "User")
        let pred = NSPredicate(format: "icloud_id LIKE %@", argumentArray: [recordUser])
        request.predicate = pred
        
        do {
            let users = try viewContext.fetch(request)
            
            if users.isEmpty {
                return false
            } else {
                UserSessionSingleton.session.user = users[0]

                initSession()
                
                return true
            }
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    func initSession(){
        let request: NSFetchRequest<Session> = NSFetchRequest(entityName:"Session")
        let session = try? viewContext.fetch(request)
        
        if session!.count > 0 {
            session![0].nickname = UserSessionSingleton.session.user.nickname
        } else {
            let session = Session(context: viewContext)
            session.nickname = UserSessionSingleton.session.user.nickname
        }
        do {
            try viewContext.save()
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }

}
