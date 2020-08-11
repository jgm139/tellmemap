//
//  PlaceTableViewCell.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 05/11/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit
import MapKit
import CloudKit

class PlaceTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var userName: UILabel?
    @IBOutlet weak var userPhoto: UIImageView?
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var placeDescription: UITextView!
    @IBOutlet weak var placeDate: UILabel!
    @IBOutlet weak var mapViewLocation: MKMapView!
    
    
    // MARK: - Table View Cell Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mapViewLocation.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setContent(item: PlaceItem) {
        if let nickname = item.user?.nickname {
            self.userName!.text = nickname
        }
        
        if let photo = item.user?.image {
            self.userPhoto!.image = photo
        }
        
        self.placeTitle.text = item.name
        self.placeDescription.text = item.message
        
        if let date = getDateFormat(date: item.date) {
            self.placeDate.text = date
        }
        
        if let location = item.location {
            centerMapOnLocation(mapView: self.mapViewLocation, loc: CLLocation(latitude: location.latitude, longitude: location.longitude))
            
            if let category = item.category {
                let artPin = ArtworkPin(title: item.name!, subtitle: item.message!, category: category, coordinate: location)
                
                self.mapViewLocation.addAnnotation(artPin)
            }
        }
    }
    
    
    // MARK: - Methods
    func centerMapOnLocation(mapView: MKMapView, loc: CLLocation) {
        let regionRadius: CLLocationDistance = 100
        let coordinateRegion =
            MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: regionRadius * 4.0, longitudinalMeters: regionRadius * 4.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getDateFormat(date: Date?) -> String? {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "hh:mm"
        
        return (date != nil ? dataFormatter.string(from: date!) : nil)
    }

}

extension PlaceTableViewCell: MKMapViewDelegate {
    
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
