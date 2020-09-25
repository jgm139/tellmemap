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
    
    static let sharedCDManager = CoreDataManager()
    
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
        localStoreDescription.configuration = "Default"

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
            let sessions = try persistentContainer.viewContext.fetch(request)
            
            if sessions.count > 0, let userSession = sessions[0].user {
                if let n = nickname {
                    userSession.nickname = n
                }
                
                if let i = image {
                    userSession.image = i.pngData()
                }
            }
            
            try persistentContainer.viewContext.save()
            
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
    func savePlace(_ placeItem: PlaceItem) {
        persistentContainer.performBackgroundTask {
            (contextBG) in
            let newPlace = Place(context: contextBG)
            newPlace.name = placeItem.name
            newPlace.message = placeItem.message
            newPlace.date = placeItem.date
            
            if let category = placeItem.category {
                newPlace.category = Int64(Category.getIntFromCategory(category))
            }
            
            if let l2d = placeItem.location {
                newPlace.latitude = l2d.latitude
                newPlace.longitude = l2d.longitude
            }
            
            newPlace.id_city = placeItem.id_city
            newPlace.identifier = placeItem.identifier
            newPlace.image = placeItem.image?.pngData()
            
            if let likes = placeItem.likes {
                newPlace.likes = Int64(likes)
            }
            
            if let user = placeItem.user {
                newPlace.userNickname = user.nickname
            }
            
            placeItem.comments.forEach {
                (commentItem) in
                let newComment = Comment(context: contextBG)
                newComment.place = newPlace
                newComment.textComment = commentItem.textComment
                
                if let user = commentItem.user {
                    newComment.userNickname = user.nickname
                    if let image = user.image {
                        newComment.userImage = image.pngData()
                    }
                }
            }
            
            do {
                try contextBG.save()
            } catch {
               print("Error al guardar el contexto: \(error)")
            }
        }
    }
    
    func savePlaces() {
        SessionManager.places.forEach {
            (placeItem) in
            self.savePlace(placeItem)
        }
    }
    
    func getPlaces() {
        persistentContainer.performBackgroundTask {
            (contextBG) in
            let request: NSFetchRequest<Place> = NSFetchRequest(entityName: "Place")
            
            do {
                let placesCoreData = try contextBG.fetch(request)
                
                placesCoreData.forEach {
                    (placeCoreData) in
                    SessionManager.places.append(PlaceItem(placeCoreData: placeCoreData))
                }
                
                NotificationCenter.default.post(name: NSNotification.Name("finished"), object: nil)
                
            } catch {
               print("Error al obtener lugares de CoreData: \(error)")
            }
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
