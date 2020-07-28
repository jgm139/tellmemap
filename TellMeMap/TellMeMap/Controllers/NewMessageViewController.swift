//
//  ViewController.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreLocation

class NewMessageViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {
    
    //MARK: Properties
    let locationManager = CLLocationManager()
    var lastCurrentLocation = CLLocationCoordinate2D()
    var newPlace: Place?
    @IBOutlet weak var newPlaceDescription: UITextView!
    @IBOutlet weak var newPlaceTitle: UILabel!
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.okButton.isEnabled = false
        
        self.newPlaceDescription.text = "Description"
        self.newPlaceDescription.textColor = UIColor.lightGray
        
        //self.okButton.isEnabled = false
        self.newPlaceDescription.delegate = self
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.newPlaceDescription.text = "Description"
        self.newPlaceDescription.textColor = UIColor.lightGray
    }
    
    // MARK: - LocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        self.lastCurrentLocation.latitude = locValue.latitude
        self.lastCurrentLocation.longitude = locValue.longitude
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "saveMessageAndLeave") {
            if let title = newPlaceTitle.text {
                if let description = newPlaceDescription.text {
                    
                    guard let myDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    
                    let myContext = myDelegate.persistentContainer.viewContext
                    
                    self.newPlace = Place(context: myContext)
                    self.newPlace!.name = title
                    self.newPlace!.date = Date()
                    self.newPlace!.latitude = lastCurrentLocation.latitude
                    self.newPlace!.longitude = lastCurrentLocation.longitude
                    self.newPlace!.message = description
                    
                    do {
                        try myContext.save()
                    } catch {
                        print("ERROR: \(error)")
                    }
                }
            }
        }
    }
    
    //MARK: - UITextViewDelegate functions
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.split(separator: "\n").count > 0 {
            let firstLine = String(textView.text.split(separator: "\n")[0])
            self.newPlaceTitle.text = firstLine
            self.okButton.isEnabled = true
        } else {
            self.newPlaceTitle.text = ""
            self.okButton.isEnabled = false
        }
    }

}
