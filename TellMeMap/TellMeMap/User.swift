//
//  User.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit

class User {
    
    //MARK: Properties
    var name: String
    var surnames: String
    var email: String
    var password: String
    var photo: String?
    var date: Date?
    
    //MARK: Initialization
    init(name: String, surnames: String, email: String, password: String, photo: String?, date: Date?) {
        self.name = name
        self.surnames = surnames
        self.email = email
        self.password = password
        
        if let nPhoto = photo {
            self.photo = nPhoto
        }
        
        if let nDate = date {
            self.date = nDate
        }
    }
}
