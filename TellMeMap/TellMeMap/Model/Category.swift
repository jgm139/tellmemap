//
//  Category.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit

enum Category: String, CaseIterable {
    case bar = "Bar"
    case restaurant = "Restaurant"
    case cafe = "Cafe"
    case shop = "Shop"
    case library = "Library"
    case academy = "Academy"
    case nightclub = "Night Club"
    case laundry = "Laundry/Launderette"
    case outlet = "Outlet"
    case events_room = "Events Room"
    case beauty_salon = "Beauty salon"
    case garage = "Garage"
    
    init?(id: Int) {
        switch id {
            case 1: self = .bar
            case 2: self = .restaurant
            case 3: self = .cafe
            case 4: self = .shop
            case 5: self = .library
            case 6: self = .academy
            case 7: self = .nightclub
            case 8: self = .laundry
            case 9: self = .outlet
            case 10: self = .events_room
            case 11: self = .beauty_salon
            case 12: self = .garage
            default: return nil
        }
    }
}
