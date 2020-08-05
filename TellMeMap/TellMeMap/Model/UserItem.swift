//
//  UserItem.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 03/08/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import MapKit
import CloudKit

class UserItem {
    private var id: CKRecord.ID?

    var icloud_id: String
    var image: Data?
    var nickname: String
    var name: String?
    var surnames: String?
    private(set) var places: [PlaceItem]? = nil
    
    init(nickname: String, name: String?, surnames: String?, icloud_id: String) {
        self.icloud_id = icloud_id
        self.nickname = nickname
        self.name = name
        self.surnames = surnames
    }
    
    convenience init?(record: CKRecord) {
        guard
            let icloud_id = record["icloud_id"] as? String,
            let nickname = record["nickname"] as? String,
            let name = record["name"] as? String,
            let surnames = record["surnames"] as? String
        else { return nil }
        
        self.init(nickname: nickname, name: name, surnames: surnames, icloud_id: icloud_id)
        //self.image = image
        self.id = record.recordID
        
        if let placeRecords = record["places"] as? [CKRecord.Reference] {
            PlaceItem.fetchPlaces(for: placeRecords) { (places) in
                self.places = places
            }
        }
    }
}
