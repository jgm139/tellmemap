//
//  SignInViewController.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 22/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

class SignInViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loginAction() -> Bool {
        
        var logged = false
        
        if let nEmail = emailTextField.text {
            if let nPass = passwordTextField.text {
                guard let myDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return false
                }
                
                let myContext = myDelegate.persistentContainer.viewContext
                
                let request : NSFetchRequest<User> = NSFetchRequest(entityName: "User")
                
                if let users = try? myContext.fetch(request) {
                    for user in users {
                        if user.email == nEmail && user.password == nPass {
                            logged = true
                        }
                    }
                    
                    if !logged {
                        let alert = UIAlertController(title: "Credenciales incorrectas", message: "El email o la contraseña son incorrectas", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                        self.present(alert, animated: true)
                    }
                    
                    if users.isEmpty {
                        let alert = UIAlertController(title: "No estás registrado", message: "El email introducido no está registrado", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                        self.present(alert, animated: true)
                    }
                }
            }
        }
        
        return logged
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "signInSegue" {
            if loginAction() {
                return true
            }
        } else if identifier == "signUpSegue" {
            return true
        }
        
        return false
    }
}
