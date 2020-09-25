//
//  CommentItem.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 10/09/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CloudKit

class CommentItem {
    var id: CKRecord.ID?
    var record: CKRecord?
    
    var user: UserItem?
    var textComment: String?
    
    init(user: UserItem?, textComment: String?) {
        self.user = user
        self.textComment = textComment
    }
    
    init?(record: CKRecord) {
        self.record = record
        self.id = record.recordID
    }
    
    func getComment(_ completion: @escaping (_ success: Bool) -> Void) {
        let text = record!.object(forKey: "textComment") as? String
        
        if let userRecordReference = record!.object(forKey: "user") as? CKRecord.Reference {
            getCommentUser(recordReference: userRecordReference) {
                (userItem) in
                if let user = userItem {
                    self.textComment = text
                    self.user = user
                    
                    completion(true)
                }
            }
        }
    }
    
    func getCommentUser(recordReference: CKRecord.Reference, _ completion: @escaping (UserItem?) -> Void) {
        let operation = CKFetchRecordsOperation(recordIDs: [recordReference.recordID])
        
        operation.qualityOfService = .userInitiated
        operation.desiredKeys = ["nickname", "image", "typeUser"]
        
        operation.perRecordCompletionBlock = {
            record, recordID, error in
            
            if let record = record {
                completion(UserItem(record: record))
            } else {
                print("ERROR getting USER from COMMENT: \(String(describing: error))")
            }
        }

        CloudKitManager.sharedCKManager.publicDB.add(operation)
    }
}
