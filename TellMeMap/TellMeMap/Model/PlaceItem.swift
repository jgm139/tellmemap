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

class PlaceItem {
    private var id: CKRecord.ID?
    private var record: CKRecord?
    
    var name: String?
    var message: String?
    var date: Date?
    var user: UserItem?
    var location: CLLocationCoordinate2D?
    var category: Category?
    
    init(name: String, message: String, category: Int, date: Date, user: UserItem, location: CLLocationCoordinate2D) {
        self.name = name
        self.message = message
        self.category = Category(id: category)
        self.date = date
        self.user = user
        self.location = location
    }
    
    init?(record: CKRecord) {
        self.record = record
        self.id = record.recordID
    }
    
    func getPlace(_ completion: @escaping (_ success: Bool) -> Void) {
        let name = record!.object(forKey: "name") as? String
        let message = record!.object(forKey: "message") as? String
        let category = record!.object(forKey: "category") as? Int
        let date = record!.object(forKey: "date") as? Date
        let location = record!.object(forKey: "location") as? CLLocation
        
        if let userRecordReference = record!.object(forKey: "user") as? CKRecord.Reference {
            getSiteUser(recordReference: userRecordReference) {
                (userItem) in
                if let user = userItem {
                    self.name = name
                    self.message = message
                    
                    if let c = category{
                        self.category = Category(id: c)
                    }
                    
                    self.date = date
                    self.user = user
                    self.location = location?.coordinate
                    
                    completion(true)
                }
            }
        }
    }
    
    func getSiteUser(recordReference: CKRecord.Reference, _ completion: @escaping (UserItem?) -> Void) {
        let privateDB: CKDatabase = CKContainer.default().privateCloudDatabase
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

        privateDB.add(operation)
    }
    
    static func fetchPlaces(for references: [CKRecord.Reference], _ completion: @escaping ([PlaceItem]) -> Void) {
        let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
        let recordIDs = references.map { $0.recordID }
        let operation = CKFetchRecordsOperation(recordIDs: recordIDs)
        operation.qualityOfService = .utility

        operation.fetchRecordsCompletionBlock = {
            records, error in
            
            var places = [PlaceItem]()
            
            for record in records! {
                if let place = PlaceItem(record: record.value) {
                    places.append(place)
                }
            }
            
            DispatchQueue.main.async {
                completion(places)
            }
        }

        publicDB.add(operation)
    }
}
