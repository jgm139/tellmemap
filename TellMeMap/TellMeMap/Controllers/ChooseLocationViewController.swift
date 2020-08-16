//
//  ChooseLocationViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 16/08/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ChooseLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    var userCurrentLocation = CLLocationCoordinate2D()
    var lastAnnotation: MKPointAnnotation?
    var lastLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        centerMapOnLocation(mapView: mapView, loc: CLLocation(latitude: userCurrentLocation.latitude, longitude: userCurrentLocation.longitude))
    }
    
    // MARK: - LocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        self.userCurrentLocation.latitude = locValue.latitude
        self.userCurrentLocation.longitude = locValue.longitude
        
        self.lastLocation = CLLocationCoordinate2D()
    }
    
    func centerMapOnLocation(mapView: MKMapView, loc: CLLocation) {
        let regionRadius: CLLocationDistance = 100
        let coordinateRegion =
            MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: regionRadius * 4.0, longitudinalMeters: regionRadius * 4.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    // MARK: - Actions
    @IBAction func chooseLocation(_ sender: UILongPressGestureRecognizer) {
        if let annotation = lastAnnotation {
            mapView.removeAnnotation(annotation)
        }
        
        let touchLocation = sender.location(in: mapView)
        lastLocation = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        // Show artwork on map
        lastAnnotation = MKPointAnnotation()
        lastAnnotation!.coordinate = lastLocation!
        lastAnnotation!.title = "New place location"
        
        mapView.addAnnotation(lastAnnotation!)
    }
    

}
