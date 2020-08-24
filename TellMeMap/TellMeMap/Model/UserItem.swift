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
    var id: CKRecord.ID?
    var record: CKRecord?
    
    var icloud_id: String?
    var image: UIImage?
    var nickname: String?
    var name: String?
    var surnames: String?
    //private(set) var places: [PlaceItem]? = nil
    
    init(nickname: String, name: String?, surnames: String?, icloud_id: String?) {
        self.icloud_id = icloud_id
        self.nickname = nickname
        self.name = name
        self.surnames = surnames
    }
    
    init?(record: CKRecord) {
        self.record = record
        self.id = record.recordID
        
        guard
            let nickname = record["nickname"] as? String
        else { return }
        
        self.icloud_id = record["icloud_id"] as? String
        self.nickname = nickname
        self.name = record["name"] as? String
        self.surnames = record["surnames"] as? String
        
        if let file = record["image"] as? CKAsset {
            do {
                let data = try Data(contentsOf: file.fileURL!)
                self.image = UIImage(data: data as Data)
            } catch {
                print("Error: \(error)")
            }
        }
        
        /*if let placeRecords = record!["places"] as? [CKRecord.Reference] {
            PlaceItem.fetchPlaces(for: placeRecords) { (places) in
                self.places = places
            }
        }*/
    }
}
