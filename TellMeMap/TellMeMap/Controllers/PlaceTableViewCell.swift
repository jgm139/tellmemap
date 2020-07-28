//
//  PlaceTableViewCell.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 05/11/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit
import MapKit

class PlaceTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var userName: UILabel?
    @IBOutlet weak var userPhoto: UIImageView?
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var placeDescription: UITextView!
    @IBOutlet weak var placeDate: UILabel!
    @IBOutlet weak var mapViewLocation: MKMapView!
    
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(item: Place) {
        self.userName!.text = item.user?.nickname
        //self.userPhoto.image
        self.placeTitle.text = item.name
        self.placeDescription.text = item.message
        self.placeDate.text = getDateFormat(date: item.date!)
        
        centerMapOnLocation(mapView: self.mapViewLocation, loc: CLLocation(latitude: item.latitude, longitude: item.longitude))
        
        let artPin = ArtworkPin(title: item.name!, subtitle: item.description, coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude))
        
        self.mapViewLocation.addAnnotation(artPin)
        
    }
    
    func centerMapOnLocation(mapView: MKMapView, loc: CLLocation) {
        let regionRadius: CLLocationDistance = 100
        let coordinateRegion =
            MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: regionRadius * 4.0, longitudinalMeters: regionRadius * 4.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getDateFormat(date: Date) -> String {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "hh:mm"
        
        return dataFormatter.string(from: date)
    }


}
