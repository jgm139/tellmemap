//
//  Pin+CoreDataProperties.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 11/12/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var category: String?
    @NSManaged public var colour: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var sign: Sign?
    
    var categorySetting: Category {
        get {
            return Category(rawValue: self.category!)!
        }
        
        set {
            self.category = newValue.rawValue
        }
    }

}
