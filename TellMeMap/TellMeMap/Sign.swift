//
//  Sign.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit

class Sign {
    
    //MARK: Properties
    var name: String
    //var pin: Pin
    var location: String
    var description: String
    var likes: Int = 0
    var reports: Int = 0
    var date: String?
    
    //MARK: Initialization
    init(name: String, location: String, description: String) {
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
}
