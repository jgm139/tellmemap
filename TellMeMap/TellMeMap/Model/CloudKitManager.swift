//
//  Model.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 02/08/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import Foundation
import CloudKit
import MapKit

class CloudKitManager {
    // MARK: - iCloud properties
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    // MARK: - Properties
    public var places = [PlaceItem]()
    
    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    func getPlaces(_ completion: @escaping (_ finish: Bool) -> Void) {
        places = [PlaceItem]()
        
        let query = CKQuery(recordType: "Place", predicate: NSPredicate(value:true))
        let group = DispatchGroup()
        
        self.publicDB.perform(query, inZoneWith: nil, completionHandler: {
            (results, error) in
            if error == nil {
                for result in results! {
                    if let itemPlace = PlaceItem(record: result) {
                        self.places.append(itemPlace)
                    }
                }
                
                self.places.forEach { (place) in
                    group.enter()
                    place.getPlace { (succes) in
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(true)
                }
            } else {
                print("ERROR: \(String(describing: error))")
            }
        })
    }
    
    func addPlace(name: String, message: String, coordinates: CLLocationCoordinate2D) {
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "icloud_id == %@", argumentArray: [UserSessionSingleton.session.user.icloud_id]))
        
        self.privateDB.perform(query, inZoneWith: nil, completionHandler: {
            (results, error) in
            if error == nil {
                for result in results! {
                    let user: CKRecord! = result as CKRecord
                    let reference = CKRecord.Reference(recordID: user.recordID, action: .deleteSelf)
                    
                    let place = CKRecord(recordType: "Place")
                    
                    place["name"] = name
                    place["message"] = message
                    place["location"] = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    place["date"] = Date()
                    place["user"] = reference
                    
                    let itemPlace = PlaceItem(name: name, message: message, date: Date(), user: UserSessionSingleton.session.user, location: coordinates)
                    
                    self.places.append(itemPlace)
                    
                    self.publicDB.save(place, completionHandler: {
                        (recordID, error) in
                        if let e = error {
                            print("Error: \(e)")
                        }
                    })
                }
            }
        })
    }
    
    func deletePlace(withName name: String) {
        let query = CKQuery(recordType: "Place", predicate: NSPredicate(format: "name == %@", argumentArray: [name]))
        
        self.publicDB.perform(query, inZoneWith: nil, completionHandler: {
            (results, error) in
            if error == nil {
                for result in results! {
                    let record: CKRecord! = result as CKRecord
                    self.publicDB.delete(withRecordID: record.recordID, completionHandler: {
                        (recordID, error) in
                        if let e = error {
                            print("Error: \(e)")
                        }
                    })
                }
            }
        })
    }
    
    func addUser(nickname: String, name: String?, surnames: String?, icloud_id: String) {
        let user = CKRecord(recordType: "User")
        user["nickname"] = nickname
        user["name"] = name
        user["surnames"] = surnames
        user["icloud_id"] = icloud_id
        
        self.privateDB.save(user, completionHandler: {
            (recordID, error) in
            if let e = error {
                print("Error: \(e)")
            }
        })
    }
    
    func updateUser(newNickname: String?, newImage: Data?) {
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "icloud_id == %@", argumentArray: [UserSessionSingleton.session.user.icloud_id]))
        
        self.privateDB.perform(query, inZoneWith: nil, completionHandler: {
            (users, error) in
            if error == nil {
                let user = users![0]
                if user["icloud_id"] == UserSessionSingleton.session.user.icloud_id {
                    if let nickname = newNickname {
                        user["nickname"] = nickname
                    }
                    
                    if let image = newImage {
                        user["image"] = image
                    }
                    
                    self.privateDB.save(user, completionHandler: {
                        (recordID, error) in print("Error: \(String(describing: error))")
                    })
                    
                    UserSessionSingleton.session.user = UserItem(record: user)
                }
            }
        })
    }
}
