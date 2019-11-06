//
//  Category.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit

struct Pin {
    
    //MARK: Properties
    var category: Category
    var colour: String
    
    init(category: Category) {
        switch category {
            case .academy:
                self.colour = "#2980B9"
            case .bar:
                self.colour = "#16A085"
            case .beauty_salon:
                self.colour = "#FF33BB"
            case .cafe:
                self.colour = "#F39C12"
            case .events_room:
                self.colour = "#F1C40F"
            case .garage:
                self.colour = "#34495E"
            case .laundry:
                self.colour = "#33FFFF"
            case .library:
                self.colour = "#73C6B6"
            case .nightclub:
                self.colour = "#9B59B6"
            case .outlet:
                self.colour = "FF0000"
            case .restaurant:
                self.colour = "025B0A"
            case .shop:
                self.colour = "#E74C3C"
        }
        self.category = category
    }
}
