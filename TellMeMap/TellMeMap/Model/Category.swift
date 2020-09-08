//
//  Category.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit

enum Category: String, CaseIterable {
    case bar = "Bar 🍻"
    case restaurant = "Restaurant 🍽"
    case cafe = "Cafe ☕️"
    case shop = "Shop 🛍"
    case library = "Library 📚"
    case academy = "Academy 📖"
    case nightclub = "Night Club 🕺🏽"
    case laundry = "Laundry/Launderette 🧺"
    case outlet = "Outlet 💸"
    case events_room = "Events Room 🎉"
    case beauty_salon = "Beauty salon 💅🏼"
    case garage = "Garage 🛠"
    
    init?(id: Int) {
        switch id {
            case 0: self = .bar
            case 1: self = .restaurant
            case 2: self = .cafe
            case 3: self = .shop
            case 4: self = .library
            case 5: self = .academy
            case 6: self = .nightclub
            case 7: self = .laundry
            case 8: self = .outlet
            case 9: self = .events_room
            case 10: self = .beauty_salon
            case 11: self = .garage
            default: return nil
        }
    }
    
    static func getIntFromCategory(_ category: Category) -> Int {
        var indexCategory: Int
        
        switch category {
            case .bar: indexCategory = 0
            case .restaurant: indexCategory = 1
            case .cafe: indexCategory = 2
            case .shop: indexCategory = 3
            case .library: indexCategory = 4
            case .academy: indexCategory = 5
            case .nightclub: indexCategory = 6
            case .laundry: indexCategory = 7
            case .outlet: indexCategory = 8
            case .events_room: indexCategory = 9
            case .beauty_salon: indexCategory = 10
            case .garage: indexCategory = 11
        }
        
        return indexCategory
    }
}
