//
//  ViewController.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreLocation

class NewMessageViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var newPlaceDescription: UITextView!
    @IBOutlet var newPlaceTitle: UITextField!
    @IBOutlet weak var okButton: UIBarButtonItem!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet var photoImageView: UIImageView!
    
    
    // MARK: - Properties
    var placeLocation = CLLocationCoordinate2D()
    var imagePicker = UIImagePickerController()
    var ckManager = CloudKitManager()
    
    
    // MARK: - View Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapView)
        
        self.okButton.isEnabled = false
        
        self.newPlaceDescription.text = "Message description..."
        self.newPlaceDescription.textColor = UIColor.lightGray
        
        self.newPlaceDescription.delegate = self
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }
    
    @objc func dismissKeyboard() {
       view.endEditing(true)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "saveMessageAndLeave") {
            if let title = newPlaceTitle.text {
                if let text = newPlaceDescription.text {
                    let lines = text.split(separator: "\n").map(String.init)
                    let description: String
                    
                    if lines.count > 1 {
                        description = lines[1...lines.count-1].joined(separator: "\n")
                    } else {
                        description = text
                    }
                    
                    newPlace(name: title, message: description, coordinates: placeLocation, category: pickerView.selectedRow(inComponent: 0), image: photoImageView.image)
                }
            }
        }
    }
    
    @IBAction func unwindToNewMessageView(sender: UIStoryboardSegue) {
        if (sender.identifier == "chooseLocationAndLeave") {
            if let sourceViewController = sender.source as? ChooseLocationViewController {
                if let location = sourceViewController.lastLocation {
                    placeLocation = location
                } else {
                    placeLocation = sourceViewController.userCurrentLocation
                }
            }
        }
    }
    
    // MARK: - Methods
    func newPlace(name: String, message: String, coordinates: CLLocationCoordinate2D, category: Int, image: UIImage?, isPublic: Bool = true) {
        if isPublic {
            let itemPlace = PlaceItem(name: name, message: message, category: category, date: Date(), user: UserSessionSingleton.session.user, location: coordinates, image: image)
            
            CloudKitManager.places.insert(itemPlace, at: 0)
            
            ckManager.addPlace(name: name, message: message, category: category, coordinates: coordinates, image: image)
        }
    }
    
    
    // MARK: - Actions
    @IBAction func addImage(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Add photo of the place", message: "", preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "Take photo", style: .default) {
            (_) in
            self.takePhoto()
        }
        
        let action2 = UIAlertAction(title: "Choose from photo library", style: .default) {
            (_) in
            self.choosePhotoLibrary()
        }
        
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) {
            (_) in
            print("Cancel")
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        
        self.present(alert, animated: true, completion: nil)
    }
    

}


extension NewMessageViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Message description..."
            textView.textColor = UIColor.lightGray
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            self.okButton.isEnabled = true
        } else {
            self.okButton.isEnabled = false
        }
    }
}


extension NewMessageViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Category.allCases[row].rawValue
    }
    
}


extension NewMessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhoto() {
        imagePicker.sourceType = .camera

        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoLibrary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        self.photoImageView.image = image.fixOrientation()
            
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
