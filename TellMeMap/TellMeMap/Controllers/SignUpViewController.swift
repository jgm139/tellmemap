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
    
    
    // MARK: - Properties
    var userInformation: [String: String]?
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    // MARK: - View Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userInformation = [String: String]()
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
        let newUser = User(context: viewContext)
        
        newUser.nickname = nickname
        newUser.name = name
        newUser.surnames = surnames
        newUser.icloud_id = icloud_id
        
        do {
            try viewContext.save()
            
            UserSessionSingleton.session.user = newUser
            
            initSession()
        } catch {
            print("ERROR: \(error)")
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
