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
        
        
        // MARK: Local Notifications
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) {
            success, error in
            if let error = error {
              print("Error: \(error)")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        
        // MARK: UI
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
        
        CoreDataManager.sharedCDManager.saveContext()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }

}

