//
//  UserSessionSingleton.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 28/07/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class UserSessionSingleton {
    var userItem: UserItem!
    
    private init() {}
    
    static var session = UserSessionSingleton()
}
