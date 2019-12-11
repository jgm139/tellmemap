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
    @IBOutlet weak var newSignDescription: UITextView!
    @IBOutlet weak var newSignTitle: UILabel!
    var newSign: Sign?
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newSignDescription.delegate = self
        
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
        self.newSignDescription.text = "Description"
        self.newSignDescription.textColor = UIColor.lightGray
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
            if let title = newSignTitle.text {
                if let description = newSignDescription.text {
                    
                    guard let myDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    
                    let myContext = myDelegate.persistentContainer.viewContext
                    
                    self.newSign = Sign(context: myContext)
                    self.newSign!.name = title
                    self.newSign!.date = Date()
                    self.newSign!.latitude = lastCurrentLocation.latitude
                    self.newSign!.longitude = lastCurrentLocation.longitude
                    self.newSign!.message = description
                    
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
    /*func textViewDidBeginEditing(_ textView: UITextView) {
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
    }*/
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.split(separator: "\n").count > 0 {
            let firstLine = String(textView.text.split(separator: "\n")[0])
            self.newSignTitle.text = firstLine
        } else {
            self.newSignTitle.text = ""
        }
    }

}

