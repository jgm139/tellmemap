//
//  ProfileViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 28/07/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nicknameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapView)
        
        setData()
    }
    
    func setData() {
        self.nicknameTextField.text = UserSessionSingleton.session.user.nickname
        
        if let photo = UserSessionSingleton.session.user.image {
            self.photoImageView.image = UIImage(data: photo)
            self.photoImageView.contentMode = .scaleAspectFill
        }
    }
    
    @objc func dismissKeyboard() {
       view.endEditing(true)
    }
    
    // MARK: Actions
    @IBAction func exportImage(_ sender: UITapGestureRecognizer) {
        let image = UIImagePickerController()
        
        image.delegate = self
        
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true) {}
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        guard let myDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let myContext = myDelegate.persistentContainer.viewContext
        
        let request : NSFetchRequest<User> = NSFetchRequest(entityName:"User")
        
        do {
            let users = try myContext.fetch(request)
            
            for user in users {
                if user == UserSessionSingleton.session.user {
                    if let nickname = self.nicknameTextField.text {
                        user.nickname = nickname
                    }
                    
                    if let photo = self.photoImageView.image?.pngData() {
                        user.image = photo
                    }
                    
                    UserSessionSingleton.session.user = user
                }
            }
        } catch {
            print("Error buscando usuarios")
        }
        
        do {
           try myContext.save()
            
            let alert = UIAlertController(title: "Gestión de perfil", message: "Cambios guardados correctamente.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
    
    
    // MARK: - Picker Controller Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        self.photoImageView.image = image
        self.photoImageView.contentMode = .scaleAspectFill
            
        self.dismiss(animated: true, completion: nil)
    }

}
