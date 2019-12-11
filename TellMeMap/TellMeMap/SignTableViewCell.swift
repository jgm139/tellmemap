//
//  SignTableViewCell.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 05/11/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit
import MapKit

class SignTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var userName: UILabel?
    @IBOutlet weak var userPhoto: UIImageView?
    @IBOutlet weak var signTitle: UILabel!
    @IBOutlet weak var signDescription: UITextView!
    @IBOutlet weak var signDate: UILabel!
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
    
    func setContent(item: Sign) {
        //self.userName.text
        //self.userPhoto.image
        self.signTitle.text = item.name
        self.signDescription.text = item.message
        self.signDate.text = getDateFormat(date: item.date!)
        
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
