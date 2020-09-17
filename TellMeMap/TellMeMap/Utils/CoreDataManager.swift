//
//  CoreDataManager.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 17/09/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    
    static let sharedManager = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
        The persistent container for the application. This implementation
        creates and returns a container, having loaded the store for the
        application to it. This property is optional since there are legitimate
        error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "tellMeMap")

        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()

        // Create a store description for a local store
        let localURL = defaultDirectoryURL.appendingPathComponent("local.sqlite")
        let localStoreDescription = NSPersistentStoreDescription(url: localURL)
        localStoreDescription.configuration = "Local"

        // Update the container's list of store descriptions
        container.persistentStoreDescriptions = [
           localStoreDescription
        ]

        // Load both stores
        container.loadPersistentStores { storeDescription, error in
           guard error == nil else {
               fatalError("Could not load persistent stores. \(error!)")
           }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()
    
    private init() {}
    
    func updateUser(nickname: String?, image: UIImage?) {
        let request: NSFetchRequest<UserSession> = NSFetchRequest(entityName: "UserSession")
        
        do {
            let sessions = try CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(request)
            
            if sessions.count > 0 {
                if let n = nickname {
                    sessions[0].nickname = n
                }
                
                if let i = image {
                    sessions[0].image = i.pngData()
                }
            }
            
            try CoreDataManager.sharedManager.persistentContainer.viewContext.save()
            
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}