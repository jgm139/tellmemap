//
//  Model.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 02/08/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CloudKit

class CloudKitManager {
    
    static let sharedCKManager = CloudKitManager()
    
    // MARK: - iCloud properties
    public let container: CKContainer
    public let publicDB: CKDatabase
    
    // MARK: - Properties
    static public var places = [PlaceItem]()
    
    private init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
    }
    
    func getPlaces(_ completion: @escaping (_ finish: Bool) -> Void) {
        let query = CKQuery(recordType: "Place", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let group = DispatchGroup()
        
        self.publicDB.perform(query, inZoneWith: nil, completionHandler: {
            (results, error) in
            if error == nil {
                CloudKitManager.places = [PlaceItem]()
                
                for result in results! {
                    if let itemPlace = PlaceItem(record: result) {
                        CloudKitManager.places.append(itemPlace)
                    }
                }
                
                CloudKitManager.self.places.forEach { (place) in
                    group.enter()
                    place.getPlace { (succes) in
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(true)
                }
            } else {
                completion(true)
            }
        })
    }
    
    func addPlace(name: String, message: String, category: Int, date: Date, coordinates: CLLocationCoordinate2D, image: UIImage?, identifier: String) {
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "icloud_id == %@", argumentArray: [UserSessionSingleton.session.userItem.icloud_id!]))
        
        self.publicDB.perform(query, inZoneWith: nil, completionHandler: {
            (results, error) in
            if error == nil {
                for result in results! {
                    let user: CKRecord! = result as CKRecord
                    let reference = CKRecord.Reference(recordID: user.recordID, action: .none)
                    
                    let place = CKRecord(recordType: "Place")
                    
                    place["name"] = name
                    place["message"] = message
                    place["category"] = category
                    place["location"] = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    place["date"] = date
                    place["user"] = reference
                    place["likes"] = 0
                    place["identifier"] = identifier
                    
                    let comments: [CKRecord.Reference] = []
                    place["comments"] = comments
                    
                    if let image = image {
                        let asset = self.createAsset(from: image)
                        
                        place["image"] = asset
                    }
                    
                    self.publicDB.save(place, completionHandler: {
                        (recordID, error) in
                        if let e = error {
                            print("Error: \(e)")
                        } else {
                            CloudKitManager.places.filter { $0.identifier == identifier }.first?.record = place
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
    
    func addUser(nickname: String, name: String?, surnames: String?, icloud_id: String, typeUser: Int) {
        let user = CKRecord(recordType: "User")
        user["nickname"] = nickname
        user["name"] = name
        user["surnames"] = surnames
        user["icloud_id"] = icloud_id
        user["typeUser"] = typeUser
        
        self.publicDB.save(user, completionHandler: {
            (recordID, error) in
            if let e = error {
                print("Error: \(e)")
            } else {
                UserSessionSingleton.session.userItem.record = user
            }
        })
    }
    
    func updateUser(newNickname: String?, newImage: UIImage?, _ completion: @escaping (_ finish: Bool) -> Void) {
        var changes = false
        
        if let nickname = newNickname, nickname != UserSessionSingleton.session.userItem.nickname {
            UserSessionSingleton.session.userItem.record!["nickname"] = nickname
            
            UserSessionSingleton.session.userItem.nickname = nickname
            
            changes = true
        }
        
        if let image = newImage, !image.isEqual(UserSessionSingleton.session.userItem.image) {
            
            let asset = self.createAsset(from: image)
            
            UserSessionSingleton.session.userItem.record!["image"] = asset
            
            UserSessionSingleton.session.userItem.image = image
            
            changes = true
        }
        
        if changes {
            
            CoreDataManager.sharedCDManager.updateUser(nickname: newNickname, image: newImage)
            
            self.publicDB.save(UserSessionSingleton.session.userItem.record!, completionHandler: {
                (recordID, error) in
                if let e = error {
                    print("Error: \(e)")
                } else {
                    completion(true)
                }
            })
        }
        
    }
    
    func addComment(text: String, placeRecord: CKRecord, _ completion: @escaping (_ finish: Bool) -> Void) {
        let comment = CKRecord(recordType: "Comment")
        let userReference = CKRecord.Reference(recordID: UserSessionSingleton.session.userItem.id!, action: .none)
        comment["textComment"] = text
        comment["user"] = userReference
        
        self.publicDB.save(comment, completionHandler: {
            (recordID, error) in
            if let e = error {
                print("Error: \(e)")
            } else {
                let commentReference = CKRecord.Reference(recordID: comment.recordID, action: .deleteSelf)
                
                if var ls = placeRecord["comments"] as? [CKRecord.Reference] {
                    ls.append(commentReference)
                    placeRecord["comments"] = ls
                } else {
                    var newComments: [CKRecord.Reference] = []
                    newComments.append(commentReference)
                    placeRecord["comments"] = newComments
                }
                
                self.publicDB.save(placeRecord) {
                    (recordID, error) in
                    if let e = error {
                        print("Error: \(e)")
                    } else {
                        completion(true)
                    }
                }
            }
        })
    }
    
    func createAsset(from image: UIImage) -> CKAsset {
        let imageFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("lastImage")
        
        do {
            try image.pngData()?.write(to: imageFilePath!, options: .atomicWrite)
        } catch {
            print("Error: \(error)")
        }
        
        return CKAsset(fileURL: imageFilePath!)
    }
}