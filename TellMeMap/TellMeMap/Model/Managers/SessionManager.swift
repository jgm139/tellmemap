//
//  SessionManager.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 17/09/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

class SessionManager {
    
    // MARK: - Properties
    static public var places = [PlaceItem]()
    static public var placesSortedByCategory = [Category: [PlaceItem]]()
    static public var sessionStarted = false
    
    static func isSessionStarted() -> Bool{
        let request: NSFetchRequest<UserSession> = NSFetchRequest(entityName:"UserSession")
        
        do {
            let sessions = try CoreDataManager.sharedCDManager.persistentContainer.viewContext.fetch(request)
            return sessions.count > 0
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
        
        return false
    }
    
    static func initSession(){
        let request: NSFetchRequest<UserSession> = NSFetchRequest(entityName: "UserSession")
        
        do {
            let sessions = try CoreDataManager.sharedCDManager.persistentContainer.viewContext.fetch(request)
            
            if sessions.count > 0 {
                UserSessionSingleton.session.userItem = UserItem(userCoreData: sessions[0].user!)
                
                CoreDataManager.sharedCDManager.getPlaces()
                sessionStarted = true
                
                UserSessionSingleton.session.userItem.getRecordUser {
                    (sucess) in
                    if sucess {
                        UserSessionSingleton.session.userItem.getLikedPlaces()
                    }
                }
                print("Loading User Session \(UserSessionSingleton.session.userItem.nickname ?? "null")")
            } else {
                print("New User Session \(UserSessionSingleton.session.userItem.nickname ?? "null")")
                
                let newSession = UserSession(context: CoreDataManager.sharedCDManager.persistentContainer.viewContext)
                newSession.user = CoreDataManager.sharedCDManager.createUser( UserSessionSingleton.session.userItem)
                
                CloudKitManager.sharedCKManager.getPlaces {
                    (sucess) in
                    if sucess {
                        sortData()
                        NotificationCenter.default.post(name: NSNotification.Name("finished"), object: nil)
                        CoreDataManager.sharedCDManager.savePlaces()
                    }
                }
            }
            
            try CoreDataManager.sharedCDManager.persistentContainer.viewContext.save()
            
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
    static func sortData() {
        Category.allCases.forEach {
            category in
            placesSortedByCategory[category] = SessionManager.places.filter({ $0.category == category })
        }
    }
    
}
