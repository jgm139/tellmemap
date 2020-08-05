//
//  ProfileViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 28/07/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var ckManager = CloudKitManager()
    
    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nicknameTextField: UITextField!

    
    // MARK: - View Controller Functions
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
    
    // MARK: - Actions
    @IBAction func exportImage(_ sender: UITapGestureRecognizer) {
        let image = UIImagePickerController()
        
        image.delegate = self
        
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true) {}
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        
        ckManager.updateUser(newNickname: self.nicknameTextField.text, newImage: self.photoImageView.image?.pngData())
            
        let alert = UIAlertController(title: "Gestión de perfil", message: "Cambios guardados correctamente.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Picker Controller Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        self.photoImageView.image = image
        self.photoImageView.contentMode = .scaleAspectFill
            
        self.dismiss(animated: true, completion: nil)
    }

}
