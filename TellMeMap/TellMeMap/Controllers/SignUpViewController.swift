//
//  SignUpViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 26/07/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CloudKit

class SignUpViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var nicknameTextField: UITextField!
    var userInformation: [String: String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userInformation = [String: String]()
    }
    
    func getUserInformation(withCompletionHandler completion: @escaping (_ success: Bool) -> Void) {
        CKContainer.default().requestApplicationPermission(.userDiscoverability) {
            (status, error) in
            CKContainer.default().fetchUserRecordID {
                (record, error) in
                self.userInformation?["icloud_id"] = record?.recordName
                CKContainer.default().discoverUserIdentity(withUserRecordID: record!, completionHandler: {
                    (userID, error) in
                    self.userInformation?["name"] = userID?.nameComponents?.givenName
                    self.userInformation?["surnames"] = userID?.nameComponents?.familyName
                    
                    completion(true)
                })
            }
        }
    }
    
    // MARK: Actions
    @IBAction func signUpAction(_ sender: UIButton) {
        if let nickname = nicknameTextField.text {
            guard let myDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let myContext = myDelegate.persistentContainer.viewContext
            
            getUserInformation(withCompletionHandler: {
                (success) in
                
                if success {
                    let newUser = User(context: myContext)
                    newUser.nickname = nickname
                    newUser.name = self.userInformation?["name"]
                    newUser.surnames = self.userInformation?["surnames"]
                    newUser.icloud_id = self.userInformation?["icloud_id"]
                    
                    do {
                        try myContext.save()

                        DispatchQueue.main.async( execute: {
                            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlacesListVC") as? TableViewController
                            {
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
                        })
                    } catch {
                        print("ERROR: \(error)")
                    }
                } else {
                    print("ERROR: no se pudo obtener la información del usuario")
                }
                
            })
        }
    }
    
}