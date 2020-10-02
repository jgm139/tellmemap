//
//  MapViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 07/08/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    var userCurrentLocation = CLLocationCoordinate2D()
    let ud = UserDefaults.standard
    let radius: Double = 100
    
    var annotations = [ArtworkPin]()
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
            locationManager.startMonitoringSignificantLocationChanges()
        }
    
        self.filterAnnotations()
        self.setupAnnotations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setupAnnotations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //locationManager.stopUpdatingLocation()
        
        // **TESTING**
        /*self.annotations.forEach {
            (annotation) in
            //self.removeRadiusOverlay(forPin: annotation)
            self.stopMonitoring(pin: annotation)
        }*/
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
        SessionManager.sortData()
        
        if sender.identifier == "applyFilterAndLeave" {
            filterAnnotations()
        }
        
        setupAnnotations()
    }
    
    // MARK: - Methods
    func centerMapOnLocation(mapView: MKMapView, loc: CLLocation) {
        let regionRadius: CLLocationDistance = 250
        let coordinateRegion =
            MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: regionRadius * 4.0, longitudinalMeters: regionRadius * 4.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
        
        for (_, places) in SessionManager.placesSortedByCategory {
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
                    SessionManager.placesSortedByCategory.updateValue([], forKey: key)
                }
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

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                if status == .authorizedAlways {
                    locationManager.allowsBackgroundLocationUpdates = true
                } else {
                    locationManager.allowsBackgroundLocationUpdates = false
                }
                locationManager.startMonitoringSignificantLocationChanges()
            default:
                locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = locations.last?.coordinate else { return }
        
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
    
    func monitorRegionAtLocation(pin: ArtworkPin) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
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
}
