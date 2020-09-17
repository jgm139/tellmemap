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
import CoreData

class UserItem {
    
    var id: CKRecord.ID?
    var record: CKRecord?
    
    private let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
    
    var icloud_id: String?
    var image: UIImage?
    var nickname: String?
    var name: String?
    var surnames: String?
    var typeUser: UserType?
    private var likedPlaces: [PlaceItem] = []
    
    init(nickname: String, name: String?, surnames: String?, icloud_id: String?, typeUser: Int) {
        self.icloud_id = icloud_id
        self.nickname = nickname
        self.name = name
        self.surnames = surnames
        self.typeUser = UserType(id: typeUser)
    }
    
    init(userCoreData: UserSession) {
        self.icloud_id = userCoreData.icloud_id
        self.nickname = userCoreData.nickname
        self.name = userCoreData.name
        self.surnames = userCoreData.surnames
        
        if let image = userCoreData.image {
            self.image = UIImage(data: image)
        }
        
        self.typeUser = UserType(id: Int(userCoreData.typeUser))
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
        
        if let t = record["typeUser"] as? Int {
            self.typeUser = UserType(id: t)
        }
        
        if let file = record["image"] as? CKAsset {
            do {
                let data = try Data(contentsOf: file.fileURL!)
                self.image = UIImage(data: data as Data)
            } catch {
                print("Error: \(error)")
            }
        }
        
        getLikedPlaces()
    }
    
    func getRecordUser(completion: @escaping (_ success: Bool) -> Void) {
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "icloud_id == %@", argumentArray: [icloud_id!]))
        
        self.publicDB.perform(query, inZoneWith: nil, completionHandler: {
            (users, error) in
            if error == nil {
                if users!.isEmpty {
                    completion(false)
                } else {
                    self.record = users![0]
                    self.id = self.record?.recordID
                    
                    completion(true)
                }
            }
        })
    }
    
    func getLikedPlaces() {
        if let likedPlacesRecords = record!["likedPlaces"] as? [CKRecord.Reference] {
            PlaceItem.fetchPlaces(for: likedPlacesRecords) {
                (places) in
                self.likedPlaces = places
            }
        }
    }
    
    func addLikedPlace(_ item: PlaceItem) {
        if !isLikedPlace(item) {
            
            item.record!["likes"] = item.likes
            
            self.publicDB.save(item.record!, completionHandler: {
                (recordID, error) in
                if let e = error {
                    print("Error saving likes: \(e)")
                }
            })
            
            self.likedPlaces.append(item)
            
            let reference = CKRecord.Reference(recordID: item.record!.recordID, action: .none)
            
            if var ls = record!["likedPlaces"] as? [CKRecord.Reference] {
                ls.append(reference)
                record!["likedPlaces"] = ls
            } else {
                var newLikedPlaces: [CKRecord.Reference] = []
                newLikedPlaces.append(reference)
                record!["likedPlaces"] = newLikedPlaces
            }
            
            self.publicDB.save(record!, completionHandler: {
                (recordID, error) in
                if let e = error {
                    print("Error: \(e)")
                }
            })
        }
    }
    
    func isLikedPlace(_ item: PlaceItem) -> Bool {
        return self.likedPlaces.contains(item)
    }
}
