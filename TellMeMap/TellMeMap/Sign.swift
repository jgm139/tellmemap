//
//  Sign.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreLocation

class Sign {
    
    //MARK: Properties
    var name: String
    var pin: Pin?
    var location: CLLocationCoordinate2D
    var description: String
    var likes: Int = 0
    var reports: Int = 0
    var date: String?
    
    //MARK: Initialization
    init(name: String, location: CLLocationCoordinate2D, description: String) {
        self.name = name
        self.location = location
        self.description = description
        getDateFormat()
    }
    
    func getDateFormat() {
        let dataFormatter = DateFormatter()
        let d = Date()
        dataFormatter.dateFormat = "hh:mm"
        self.date = dataFormatter.string(from: d)
    }
    
    func setPin(pin: Pin) {
        self.pin = pin
    }
}
