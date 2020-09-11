//
//  SignUpViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 26/07/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class SignUpViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var enterprisingButton: UIButton!
    @IBOutlet weak var neighbourButton: UIButton!
    
    
    // MARK: - Properties
    var userInformation: [String: String]?
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var ckManager = CloudKitManager()
    var typeUser: UserType = .neighbour
    
    
    // MARK: - View Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userInformation = [String: String]()
        
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapView)
    }
    
    
    // MARK: - Actions
    @IBAction func signUpAction(_ sender: UIButton) {
        if let nickname = nicknameTextField.text {
            
            getUserInformation(withCompletionHandler: {
                (success) in
                
                if success {
                    if let icloud_id = self.userInformation?["icloud_id"] {
                        self.newUser(nickname: nickname, name: self.userInformation?["name"], surnames: self.userInformation?["surnames"], icloud_id: icloud_id)
                        
                        DispatchQueue.main.async(execute: {
                            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabNav") as? UITabBarController
                            {
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
                        })
                    }
                } else {
                    print("ERROR: no se pudo obtener la información del usuario")
                }
                
            })
        }
    }
    
    @IBAction func clickedEnterprisingButton(_ sender: UIButton) {
        self.enterprisingButton.isSelected = true
        self.neighbourButton.isSelected = false
        typeUser = .entrepreneur
    }
    
    @IBAction func clickedNeighbourButton(_ sender: UIButton) {
        self.enterprisingButton.isSelected = false
        self.neighbourButton.isSelected = true
        typeUser = .neighbour
    }
    
    @objc func dismissKeyboard() {
       view.endEditing(true)
    }
    
    
    // MARK: - Methods
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
    
    func newUser(nickname: String, name: String?, surnames: String?, icloud_id: String) {
        let intUser = UserType.getIntFromUserType(typeUser)
        
        let itemUser = UserItem(nickname: nickname, name: name, surnames: surnames, icloud_id: icloud_id, typeUser: intUser)
        
        ckManager.addUser(nickname: nickname, name: name, surnames: surnames, icloud_id: icloud_id, typeUser: intUser)
        
        UserSessionSingleton.session.user = itemUser
        
        self.initSession()
        
    }
    
    func initSession(){
        let request: NSFetchRequest<Session> = NSFetchRequest(entityName:"Session")
        let sessions = try? viewContext.fetch(request)
        
        if sessions!.count > 0 {
            sessions![0].nickname = UserSessionSingleton.session.user.nickname
        } else {
            print("New User Session \(String(describing: UserSessionSingleton.session.user.nickname))")
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
