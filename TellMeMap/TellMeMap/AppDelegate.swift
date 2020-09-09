//
//  AppDelegate.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 22/07/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    // MARK: - Properties
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // MARK: - Location Manager
        self.locationManager.delegate = self
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        
        // MARK: - UI
        // Definición de los colores de los elementos de la app
        AppButton.appearance().tintColor = UIColor.MyPalette.charcoal
        AppButton.appearance().setTitleColor(UIColor.MyPalette.charcoal, for: .normal)
        
        UIImageView.appearance().tintColor = UIColor.MyPalette.sandy_brown
        
        UITabBar.appearance().tintColor = UIColor.MyPalette.charcoal
        UITabBar.appearance().barTintColor = UIColor.MyPalette.middle_blue_green
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        
        UINavigationBar.appearance().barTintColor = UIColor.MyPalette.middle_blue_green
        UINavigationBar.appearance().tintColor = UIColor.MyPalette.charcoal
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("Application will terminate")
        
        Category.allCases.forEach {
            (category) in
            UserDefaults.standard.set(true, forKey: category.rawValue)
        }
        
        UserDefaults.standard.set(false, forKey: "filter")
    }

    // MARK: - Core Data stack

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
        
        /* Create a store description for a CloudKit-backed local store
        let cloudURL = defaultDirectoryURL.appendingPathComponent("tellMeMap.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudURL)
        cloudStoreDescription.configuration = "Cloud"

        // Set the container options on the cloud store
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.es.ua.mastermoviles.TellMeMap")*/
        
        // Update the container's list of store descriptions
        container.persistentStoreDescriptions = [
            /*cloudStoreDescription,*/
            localStoreDescription
        ]
        
        // Load both stores
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Could not load persistent stores. \(error!)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        do {
            // Uncomment to do a dry run and print the CK records it'll make
            //try container.initializeCloudKitSchema(options: [.dryRun, .printSchema])
            // Uncomment to initialize your schema
            //try container.initializeCloudKitSchema()
        } catch {
            print("Unable to initialize CloudKit schema: \(error.localizedDescription)")
        }
        
        return container
    }()

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

