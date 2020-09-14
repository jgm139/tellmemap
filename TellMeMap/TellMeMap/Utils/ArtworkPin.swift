//
//  Category.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit
import MapKit

class ArtworkPin: NSObject, MKAnnotation {
    
    //MARK: Properties
    var placeItem: PlaceItem?
    
    var colour: UIColor?
    var thumbImage: UIImage?
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var identifier: String?
    
    
    init(place: PlaceItem) {
        self.placeItem = place
        self.title = place.name
        self.subtitle = place.category?.rawValue
        self.identifier = place.identifier
        self.thumbImage = place.image
        self.coordinate = CLLocationCoordinate2D(latitude: place.location!.latitude, longitude: place.location!.longitude)
        
        switch self.placeItem?.category {
            case .academy://#00BFFF
                self.colour = UIColor(red: 0.00, green: 0.75, blue: 1.00, alpha: 1.00)
            case .bar://#3CB371
                self.colour = UIColor(red: 0.24, green: 0.70, blue: 0.44, alpha: 1.00)
            case .beauty_salon://#800080
                self.colour = UIColor(red: 0.50, green: 0.00, blue: 0.50, alpha: 1.00)
            case .cafe://#FF8C00
                self.colour = UIColor(red: 1.00, green: 0.55, blue: 0.00, alpha: 1.00)
            case .events_room://#DB7093
                self.colour = UIColor(red: 0.86, green: 0.44, blue: 0.58, alpha: 1.00)
            case .garage://#B0C4DE
                self.colour = UIColor(red: 0.69, green: 0.77, blue: 0.87, alpha: 1.00)
            case .laundry://#FFD700
                self.colour = UIColor(red: 1.00, green: 0.84, blue: 0.00, alpha: 1.00)
            case .library://#FF7F50
                self.colour = UIColor(red: 1.00, green: 0.50, blue: 0.31, alpha: 1.00)
            case .nightclub:
                self.colour = UIColor.black
            case .outlet://#FFB6C1
                self.colour = UIColor(red: 1.00, green: 0.71, blue: 0.76, alpha: 1.00)
            case .restaurant://#32CD32
                self.colour = UIColor(red: 0.20, green: 0.80, blue: 0.20, alpha: 1.00)
            case .shop://#00CED1
                self.colour = UIColor(red: 0.00, green: 0.81, blue: 0.82, alpha: 1.00)
            case .none:
                self.colour = UIColor.red
        }
        
        super.init()
    }
}
