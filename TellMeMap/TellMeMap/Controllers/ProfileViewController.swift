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
    let imagePicker = UIImagePickerController()
    var ckManager = CloudKitManager()
    
    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - View Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapView)
        
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setData()
    }
    
    func setData() {
        self.nicknameTextField.text = UserSessionSingleton.session.user.nickname
        
        if let photo = UserSessionSingleton.session.user.image {
            self.photoImageView.image = photo
            self.photoImageView.contentMode = .scaleAspectFill
        }
    }
    
    @objc func dismissKeyboard() {
       view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func exportImage(_ sender: UITapGestureRecognizer) {
        
        self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        self.activityIndicator.startAnimating()
        
        ckManager.updateUser(newNickname: self.nicknameTextField.text, newImage: self.photoImageView.image) {
            (finish) in
            if finish {
                DispatchQueue.main.async( execute: {
                    self.activityIndicator.stopAnimating()
                    let alert = UIAlertController(title: "Gestión de perfil", message: "Cambios guardados correctamente.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    
    // MARK: - Picker Controller Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        self.photoImageView.image = image.fixOrientation()
        self.photoImageView.contentMode = .scaleAspectFill
            
        self.dismiss(animated: true, completion: nil)
    }

}
