//
//  PlaceItem.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 02/08/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import MapKit
import CloudKit

class PlaceItem: Equatable {
    
    var id: CKRecord.ID?
    var record: CKRecord?
    
    private let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
    
    var identifier: String?
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
    
    init?(record: CKRecord) {
        self.record = record
        self.id = record.recordID
    }
    
    static func == (lhs: PlaceItem, rhs: PlaceItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func getPlace(_ completion: @escaping (_ success: Bool) -> Void) {
        let identifier = record!.object(forKey: "identifier") as? String
        let name = record!.object(forKey: "name") as? String
        let message = record!.object(forKey: "message") as? String
        let category = record!.object(forKey: "category") as? Int
        let date = record!.object(forKey: "date") as? Date
        let location = record!.object(forKey: "location") as? CLLocation
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
                    self.likes = likes
                    
                    if let asset = self.record?.object(forKey: "image") as? CKAsset {
                        do {
                            let data = try Data(contentsOf: asset.fileURL!)
                            self.image = UIImage(data: data as Data)
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                    
                    if let commentsRecords = self.record!["comments"] as? [CKRecord.Reference] {
                        PlaceItem.fetchComments(for: commentsRecords) {
                            (comments) in
                            self.comments = comments
                        }
                    }
                    
                    completion(true)
                }
            }
        }
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
                print("ERROR: \(String(describing: error))")
            }
        }

        publicDB.add(operation)
    }
    
    static func fetchPlaces(for references: [CKRecord.Reference], _ completion: @escaping ([PlaceItem]) -> Void) {
        let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
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

        publicDB.add(operation)
    }
    
    static func fetchComments(for references: [CKRecord.Reference], _ completion: @escaping ([CommentItem]) -> Void) {
        let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
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

        publicDB.add(operation)
    }
}
