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
    
    static func isSessionStarted() -> Bool{
        let request: NSFetchRequest<UserSession> = NSFetchRequest(entityName:"UserSession")
        
        do {
            let sessions = try CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(request)
            return sessions.count > 0
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
        
        return false
    }
    
    static func initSession(){
        let request: NSFetchRequest<UserSession> = NSFetchRequest(entityName: "UserSession")
        
        do {
            let sessions = try CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(request)
            
            if sessions.count > 0 {
                UserSessionSingleton.session.userItem = UserItem(userCoreData: sessions[0])
                UserSessionSingleton.session.userItem.getRecordUser {
                    (sucess) in
                    if sucess {
                        UserSessionSingleton.session.userItem.getLikedPlaces()
                    }
                }
                print("Loading User Session \(UserSessionSingleton.session.userItem.nickname ?? "null")")
            } else {
                print("New User Session \(UserSessionSingleton.session.userItem.nickname ?? "null")")
                let newUser = UserSession(context: CoreDataManager.sharedManager.persistentContainer.viewContext)
                newUser.icloud_id = UserSessionSingleton.session.userItem.icloud_id
                newUser.image = UserSessionSingleton.session.userItem.image?.pngData()
                newUser.nickname = UserSessionSingleton.session.userItem.nickname
                newUser.name = UserSessionSingleton.session.userItem.name
                newUser.surnames = UserSessionSingleton.session.userItem.surnames
                newUser.typeUser = Int64(UserType.getIntFromUserType(UserSessionSingleton.session.userItem.typeUser!))
            }
            
            try CoreDataManager.sharedManager.persistentContainer.viewContext.save()
            
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
}
