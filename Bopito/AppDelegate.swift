//
//  AppDelegate.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/8/24.
//

import UIKit
import Firebase
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.registerForRemoteNotifications() // Register for remote notifications
        
        GADMobileAds.sharedInstance().start(completionHandler: nil) // Connect to Google Ads
       
        return true
    }

    // This is called when the app successfully registers with APNs and receives a device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Received APNs device token: \(deviceToken)")
        
        // Pass the APNs token to Firebase
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

