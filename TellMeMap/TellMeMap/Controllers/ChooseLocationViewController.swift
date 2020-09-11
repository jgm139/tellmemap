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

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - LocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        self.locationManager.stopUpdatingLocation()
        
        self.userCurrentLocation.latitude = locValue.latitude
        self.userCurrentLocation.longitude = locValue.longitude
        
        centerMapOnLocation(mapView: mapView, loc: CLLocation(latitude: userCurrentLocation.latitude, longitude: userCurrentLocation.longitude))
    }
    
    func centerMapOnLocation(mapView: MKMapView, loc: CLLocation) {
        let regionRadius: CLLocationDistance = 250
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
