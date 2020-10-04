//
//  AppDelegate.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 22/07/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Properties
    var window: UIWindow?
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // MARK: Location Manager
        self.locationManager.delegate = self
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        
        // MARK: Notifications
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) {
            success, error in
            if let error = error {
              print("Error: \(error)")
            }
        }
        
        application.registerForRemoteNotifications()
        
        
        // MARK: UI
        // Definición de los colores de los elementos de la app
        AppButton.appearance().tintColor = UIColor.init(named: "vButton_color")
        AppButton.appearance().setTitleColor(UIColor.init(named: "vButton_color"), for: .normal)
        AppButton.appearance().setTitleColor(UIColor.init(named: "vButton_color"), for: .selected)
        
        UIImageView.appearance().tintColor = UIColor.init(named: "vImageview_color")
        
        UITabBar.appearance().tintColor = UIColor.init(named: "Charcoal")
        UITabBar.appearance().barTintColor = UIColor.init(named: "Middle_Blue_Green")
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        
        UINavigationBar.appearance().barTintColor = UIColor.init(named: "Middle_Blue_Green")
        UINavigationBar.appearance().tintColor = UIColor.init(named: "Charcoal")
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = "Device Token: "
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print(token)
        
        setupCloudKitSubscription()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("didReceiveRemoteNotification")
        
        let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        
        if notification!.notificationType == .query {
            let queryNotification = notification!
            if queryNotification.queryNotificationReason  == .recordCreated {
                if let recordID = queryNotification.recordID {
                    print("queryNotification.recordID \(recordID)")
                    CloudKitManager.sharedCKManager.getPlaceByID(recordID)
                }
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
        
    func setupCloudKitSubscription () {
        let ud = UserDefaults.standard
        let publicDB = CKContainer.default().publicCloudDatabase
        
        if !ud.bool(forKey: "subscribed") {
            let predicate = NSPredicate(value: true)
            let subscription = CKQuerySubscription(recordType: "Place", predicate: predicate, options: .firesOnRecordCreation)
            
            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            notificationInfo.desiredKeys = ["identifier"]
            
            subscription.notificationInfo = notificationInfo
            
            publicDB.save(subscription) {
                (subscription, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    ud.set(true, forKey: "subscribed")
                    ud.synchronize()
                }
            }
        }
    }
        
    func deleteCloudkitSubscriptions() {
        let publicDB = CKContainer.default().publicCloudDatabase
        
        publicDB.fetchAllSubscriptions {
            (subscriptions, error) in
            subscriptions?.forEach({
                (subscription) in
                publicDB.delete(withSubscriptionID: subscription.subscriptionID) {
                    (id, error) in
                    print("Subscription with id \(String(describing: id)) was removed : \(subscription.description)")
                }
            })
        }
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
        
        CoreDataManager.sharedCDManager.saveContext()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }

}

