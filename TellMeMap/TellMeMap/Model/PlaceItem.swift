//
//  PlaceItem.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 02/08/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CloudKit
import CoreLocation

class PlaceItem: Equatable {
    var id: CKRecord.ID?
    var record: CKRecord?
    
    var identifier: String?
    var id_city: String?
    var name: String?
    var message: String?
    var date: Date?
    var user: UserItem?
    var location: CLLocationCoordinate2D?
    var image: UIImage?
    var category: Category?
    var likes: Int?
    var comments: [CommentItem] = []
    
    init(name: String, message: String, category: Int, date: Date, user: UserItem, location: CLLocationCoordinate2D, image: UIImage?, identifier: String) {
        self.name = name
        self.message = message
        self.category = Category(id: category)
        self.date = date
        self.user = user
        self.location = location
        self.image = image
        self.identifier = identifier
        self.likes = 0
    }
    
    init(placeCoreData: Place) {
        self.name = placeCoreData.name
        self.message = placeCoreData.message
        self.category = Category(id: Int(placeCoreData.category))
        self.date = placeCoreData.date
        
        if let nickname = placeCoreData.userNickname {
            self.user = UserItem(nickname: nickname, name: "", surnames: "", icloud_id: "", typeUser: nil)
        }
        
        self.location = CLLocationCoordinate2D(latitude: placeCoreData.latitude, longitude: placeCoreData.longitude)
        self.id_city = placeCoreData.id_city
        
        if let image = placeCoreData.image {
            self.image = UIImage(data: image)
        }
        
        self.identifier = placeCoreData.identifier
        self.likes = Int(placeCoreData.likes)
        
        if let commentsCoreData = placeCoreData.comments?.allObjects as? [Comment] {
            commentsCoreData.forEach {
                (commentCoreData) in
                if let nickname = commentCoreData.userNickname {
                    let author = UserItem(nickname: nickname, name: nil, surnames: nil, icloud_id: nil, typeUser: nil)
                    self.comments.append(CommentItem(user: author, textComment: commentCoreData.textComment))
                }
            }
        }
    }
    
    init?(record: CKRecord) {
        self.record = record
        self.id = record.recordID
    }
    
    static func == (lhs: PlaceItem, rhs: PlaceItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func getCityFromLocation () {
        if let l2d = self.location {
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: l2d.latitude, longitude: l2d.longitude)

            geoCoder.reverseGeocodeLocation(location, completionHandler: {
                (placemarks, _) -> Void in
                placemarks?.forEach {
                    (placemark) in
                    if let city = placemark.locality {
                        self.id_city = city
                    }
                }
            })
        }
    }
    
    func getPlace(_ completion: @escaping (_ success: Bool) -> Void) {
        let identifier = record!.object(forKey: "identifier") as? String
        let name = record!.object(forKey: "name") as? String
        let message = record!.object(forKey: "message") as? String
        let category = record!.object(forKey: "category") as? Int
        let date = record!.object(forKey: "date") as? Date
        let location = record!.object(forKey: "location") as? CLLocation
        let id_city = record!.object(forKey: "id_city") as? String
        let likes = record!.object(forKey: "likes") as? Int
        
        if let userRecordReference = record!.object(forKey: "user") as? CKRecord.Reference {
            getPlaceUser(recordReference: userRecordReference) {
                (userItem) in
                if let user = userItem {
                    self.identifier = identifier
                    self.name = name
                    self.message = message
                    
                    if let c = category{
                        self.category = Category(id: c)
                    }
                    
                    self.date = date
                    self.user = user
                    self.location = location?.coordinate
                    self.id_city = id_city
                    self.likes = likes
                    
                    if let asset = self.record?.object(forKey: "image") as? CKAsset {
                        do {
                            let data = try Data(contentsOf: asset.fileURL!)
                            self.image = UIImage(data: data as Data)
                        } catch {
                            print("ERROR casting CKAsset to Data: \(error)")
                        }
                    }
                    
                    completion(true)
                }
            }
        }
    }
    
    func getPlaceComments(_ completion: @escaping (_ success: Bool) -> Void) {
        let predicate = NSPredicate(format: "identifier == %@", argumentArray: [self.identifier!])
        let query = CKQuery(recordType: "Place", predicate: predicate)
        
        CloudKitManager.sharedCKManager.publicDB.perform(query, inZoneWith: nil, completionHandler: {
            (results, error) in
            if let records = results {
                let record = records[0]
                if let commentsRecords = record["comments"] as? [CKRecord.Reference] {
                    PlaceItem.fetchComments(for: commentsRecords) {
                        (comments) in
                        self.comments = comments
                        completion(true)
                    }
                }
            }
        })
    }
    
    func getPlaceUser(recordReference: CKRecord.Reference, _ completion: @escaping (UserItem?) -> Void) {
        let operation = CKFetchRecordsOperation(recordIDs: [recordReference.recordID])
        
        operation.qualityOfService = .userInitiated
        operation.desiredKeys = ["nickname"]
        
        operation.perRecordCompletionBlock = {
            record, recordID, error in
            
            if let record = record {
                completion(UserItem(record: record))
            } else {
                print("ERROR getting USER from PLACE: \(String(describing: error))")
            }
        }

        CloudKitManager.sharedCKManager.publicDB.add(operation)
    }
    
    static func fetchPlaces(for references: [CKRecord.Reference], _ completion: @escaping ([PlaceItem]) -> Void) {
        let recordIDs = references.map { $0.recordID }
        let operation = CKFetchRecordsOperation(recordIDs: recordIDs)
        let group = DispatchGroup()
        
        operation.qualityOfService = .utility
        operation.desiredKeys = ["name", "user", "identifier"]

        operation.fetchRecordsCompletionBlock = {
            records, error in
            
            var places = [PlaceItem]()
            
            for record in records! {
                if let place = PlaceItem(record: record.value) {
                    places.append(place)
                }
            }
            
            places.forEach { (place) in
                group.enter()
                place.getPlace { (succes) in
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(places)
            }
        }

        CloudKitManager.sharedCKManager.publicDB.add(operation)
    }
    
    static func fetchComments(for references: [CKRecord.Reference], _ completion: @escaping ([CommentItem]) -> Void) {
        let recordIDs = references.map { $0.recordID }
        let operation = CKFetchRecordsOperation(recordIDs: recordIDs)
        let group = DispatchGroup()
        
        operation.qualityOfService = .utility

        operation.fetchRecordsCompletionBlock = {
            records, error in
            
            var comments = [CommentItem]()
            
            for record in records! {
                if let comment = CommentItem(record: record.value) {
                    comments.append(comment)
                }
            }
            
            comments.forEach { (comment) in
                group.enter()
                comment.getComment { (succes) in
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(comments)
            }
        }

        CloudKitManager.sharedCKManager.publicDB.add(operation)
    }
}
