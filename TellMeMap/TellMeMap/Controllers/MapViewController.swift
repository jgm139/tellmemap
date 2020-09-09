//
//  MapViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 07/08/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    var ckManager = CloudKitManager()
    let locationManager = CLLocationManager()
    var userCurrentLocation = CLLocationCoordinate2D()
    let ud = UserDefaults.standard
    
    var annotations = [MKAnnotation]()
    var placesSorted = [Category: [PlaceItem]]()
    
    var arraySelectedCategories: [Category : Bool] = [:]
    
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        let userTrackingButton = MKUserTrackingBarButtonItem(mapView: mapView)
        self.navigationItem.rightBarButtonItem = userTrackingButton
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        self.mapView.removeAnnotations(self.annotations)
        
        ckManager.getPlaces {
            (finish) in
            if finish {
                self.sortData()
                
                self.filterAnnotations()
                
                self.setupAnnotations()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {}
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Actions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "placeDetail" {
            if let pin = (sender as? MKAnnotationView)?.annotation as? ArtworkPin {
                if let vc = segue.destination as? PlaceDetailViewController {
                    vc.item = pin.placeItem
                }
            }
        }
    }
    
    @IBAction func unwindToMapView(sender: UIStoryboardSegue) {
        self.sortData()
        
        if sender.identifier == "applyFilterAndLeave" {
            filterAnnotations()
        }
        
        setupAnnotations()
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
    
    
    // MARK: - Methods
    func sortData() {
        Category.allCases.forEach {
            category in
            placesSorted[category] = CloudKitManager.places.filter({ $0.category == category })
        }
    }
    
    func setupAnnotations() {
        self.mapView.removeAnnotations(self.annotations)
        
        for (_, places) in placesSorted {
            places.forEach({
                (item) in
                
                if let _ = item.location, let _ = item.category {
                    
                    let artPin = ArtworkPin(place: item)
                
                    self.annotations.append(artPin)
                
                    DispatchQueue.main.async(execute: {
                        self.mapView.addAnnotation(artPin)
                    })
                }
            })
        }
    }
    
    func filterAnnotations() {
        if UserDefaults.standard.bool(forKey: "filter") {
            
            Category.allCases.forEach {
                category in
                self.arraySelectedCategories[category] = UserDefaults.standard.bool(forKey: category.rawValue)
            }
            
            self.arraySelectedCategories.forEach {
                (key: Category, value: Bool) in
                
                if !value {
                    placesSorted.updateValue([], forKey: key)
                }
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "placeDetail", sender: view)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        if ((annotation as? ArtworkPin) != nil) {
            view.canShowCallout = true
            
            let pin = annotation as! ArtworkPin
            view.annotation = pin
            view.pinTintColor = pin.colour
            
            if let _ = pin.thumbImage {
                let thumbnailImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                thumbnailImageView.image = pin.thumbImage
                
                view.leftCalloutAccessoryView = thumbnailImageView
            }
            
            view.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
        } else {
            return nil
        }
        
        view.displayPriority = .required
        
        return view
    }
}
