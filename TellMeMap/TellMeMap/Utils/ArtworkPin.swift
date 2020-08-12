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
    var category: Category?
    var colour: UIColor?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String, category: Category, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.category = category
        
        switch self.category {
            case .academy:
                self.colour = UIColor.blue
            case .bar:
                self.colour = UIColor.green
            case .beauty_salon:
                self.colour = UIColor.magenta
            case .cafe:
                self.colour = UIColor.orange
            case .events_room:
                self.colour = UIColor.purple
            case .garage:
                self.colour = UIColor.darkGray
            case .laundry:
                self.colour = UIColor.cyan
            case .library:
                self.colour = UIColor.red
            case .nightclub:
                self.colour = UIColor.black
            case .outlet:
                self.colour = UIColor.yellow
            case .restaurant:
                self.colour = UIColor.brown
            case .shop:
                self.colour = UIColor.white
            case .none:
                self.colour = UIColor.red
        }
        
        super.init()
    }
}
