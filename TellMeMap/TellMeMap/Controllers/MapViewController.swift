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
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ckManager.getPlaces {
            (finish) in
            if finish {
                self.ckManager.places.forEach {
                    (item) in
                    let artPin = ArtworkPin(title: item.name!, subtitle: item.message!, coordinate: item.location!)
                    
                    self.mapView.addAnnotation(artPin)
                }
            }
        }
    }

}
