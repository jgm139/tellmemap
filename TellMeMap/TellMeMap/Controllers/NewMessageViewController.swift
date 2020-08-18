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
    
    
    // MARK: - Properties
    var placeLocation = CLLocationCoordinate2D()
    var ckManager = CloudKitManager()
    
    
    // MARK: - View Controller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapView)
        
        self.okButton.isEnabled = false
        
        self.newPlaceDescription.text = "Message description..."
        self.newPlaceDescription.textColor = UIColor.lightGray
        
        self.newPlaceDescription.delegate = self
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.newPlaceDescription.text = "Message description..."
        self.newPlaceDescription.textColor = UIColor.lightGray
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
                    
                    newPlace(name: title, message: description, coordinates: placeLocation, category: pickerView.selectedRow(inComponent: 0))
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
    func newPlace(name: String, message: String, coordinates: CLLocationCoordinate2D, category: Int, isPublic: Bool = true) {
        if isPublic {
            let itemPlace = PlaceItem(name: name, message: message, category: category, date: Date(), user: UserSessionSingleton.session.user, location: coordinates)
            
            CloudKitManager.places.append(itemPlace)
            
            ckManager.addPlace(name: name, message: message, category: category, coordinates: coordinates)
        }
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
