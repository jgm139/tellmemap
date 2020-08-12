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
    var ckManager = CloudKitManager()
    var annotations = [MKAnnotation]()
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.mapView.removeAnnotations(self.annotations)
        
        ckManager.getPlaces {
            (finish) in
            if finish {
                CloudKitManager.places.forEach {
                    (item) in
                    
                    if let location = item.location, let category = item.category {
                            let artPin = ArtworkPin(title: item.name!, subtitle: item.message!, category: category, coordinate: location)
                        
                            self.annotations.append(artPin)
                        
                            DispatchQueue.main.async(execute: {
                                self.mapView.addAnnotation(artPin)
                            })
                        }
                    }
                }
            }
        }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        if ((annotation as? ArtworkPin) != nil) {
            view.canShowCallout = true
            
            let pin = annotation as! ArtworkPin
            view.annotation = pin
            view.pinTintColor = pin.colour
        } else {
            return nil
        }
        
        view.displayPriority = .required
        
        return view
    }
}
