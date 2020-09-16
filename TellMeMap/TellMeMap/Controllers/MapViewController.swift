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
    let radius: Double = 100
    
    var annotations = [ArtworkPin]()
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
        
        ckManager.getPlaces {
            (finish) in
            if finish {
                self.sortData()
                
                self.filterAnnotations()
                
                self.setupAnnotations()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.sortData()
        self.setupAnnotations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
        
        // **TESTING**
        self.annotations.forEach {
            (annotation) in
            //self.removeRadiusOverlay(forPin: annotation)
            self.stopMonitoring(pin: annotation)
        }
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
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            locationManager.stopMonitoring(for: region)
            if let pin = self.annotations.filter({ $0.identifier == identifier }).first {
                handleEvent(item: pin.placeItem!)
            }
        }
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
        if !self.annotations.isEmpty {
            self.annotations.forEach {
                (annotation) in
                //self.removeRadiusOverlay(forPin: annotation)
                self.stopMonitoring(pin: annotation)
            }
            self.mapView.removeAnnotations(self.annotations)
        }
        
        for (_, places) in placesSorted {
            places.forEach({
                (item) in
                
                if let _ = item.location, let _ = item.category {
                    
                    let artPin = ArtworkPin(place: item)
                    monitorRegionAtLocation(pin: artPin)
                
                    self.annotations.append(artPin)
                
                    DispatchQueue.main.async(execute: {
                        self.mapView.addAnnotation(artPin)
                        //let overlay = MKCircle(center: artPin.coordinate, radius: self.radius)
                        //self.mapView.addOverlay(overlay)
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
    
    func monitorRegionAtLocation(pin: ArtworkPin) {
        // Make sure the devices supports region monitoring.
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            // Register the region.
            let region = CLCircularRegion(center: pin.coordinate, radius: radius, identifier: pin.identifier!)
            region.notifyOnEntry = true
            region.notifyOnExit = false
       
            locationManager.startMonitoring(for: region)
        }
    }
    
    func stopMonitoring(pin: ArtworkPin) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == pin.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    func removeRadiusOverlay(forPin pin: ArtworkPin) {
        guard let overlays = mapView?.overlays else { return }
        
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == pin.coordinate.latitude && coord.longitude == pin.coordinate.longitude {
                mapView?.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    func handleEvent(item: PlaceItem) {
        let content = UNMutableNotificationContent()
        content.title = "¡Lugar propuesto ✨!"
        content.subtitle = "Accede a la app y apoya la idea"
        content.body = item.name!
        content.userInfo = ["id" : item.identifier!]
        content.sound = UNNotificationSound.default
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "enterPlace", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {
            error in
            if let error = error {
                print ("Error al lanzar la notificación: \(String(describing: error))")
            } else {
                print("Notificación lanzada correctamente.")
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}
