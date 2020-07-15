//
//  SignUpViewController.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 04/01/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnamesTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    
    @IBAction func signUpAction(_ sender: Any) {
        
        if let nEmail = emailTextField.text {
            if let nName = nameTextField.text {
                if let nSurnames = surnamesTextField.text {
                    if let nPass = passwordTextField.text {
                        guard let myDelegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        
                        let myContext = myDelegate.persistentContainer.viewContext
                        
                        let newUser = User(context: myContext)
                        newUser.email = nEmail
                        newUser.name = nName
                        newUser.surnames = nSurnames
                        newUser.password = nPass
                        
                        do {
                            try myContext.save()
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "SignInVC")
                            self.present(controller, animated: true, completion: nil)

                            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInVC") as? SignInViewController
                            {
                                present(vc, animated: true, completion: nil)
                            }
                        } catch {
                            print("ERROR: \(error)")
                        }
                    }
                }
            }
        }
    }
    
}
