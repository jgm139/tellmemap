//
//  UserType.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 09/09/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

enum UserType: String, CaseIterable {
    case entrepreneur = "Entrepreneur 💡"
    case neighbour = "Neighbour 🏡"
    
    init?(id: Int) {
        switch id {
            case 0: self = .entrepreneur
            case 1: self = .neighbour
            default: return nil
        }
    }
    
    static func getIntFromUserType(_ typeUser: UserType) -> Int {
        var index: Int
        
        switch typeUser {
            case .entrepreneur: index = 0
            case .neighbour: index = 1
        }
        
        return index
    }
}
