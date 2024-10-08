//
//  NotificationsManager.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/1/24.
//

import SwiftUI
import Foundation
import UserNotifications
import Firebase
import FirebaseMessaging

class NotificationManager: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate, ObservableObject {
    
    @Published var notificationsEnabled: Bool = false
    
    @Published var fcmToken: String?
    
    // Custom initializer to inject SupabaseManager
    override init() {
        super.init()
        // Configure Firebase and FCM
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        requestNotificationPermissions()
    }
    
    // Request permission to turn notifications on in app Settings for Bopito
    func requestNotificationPermissions() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
            if granted {
                print("Notification permission granted: \(granted)")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            self.checkNotificationSettings()
        }
    }
    
    // Check if allowed in app Settings for Bopito
    func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { [weak self] in
                self?.notificationsEnabled = (settings.authorizationStatus == .authorized)
                
                if settings.authorizationStatus == .authorized {
                    print("Notifications already enabled, no need to open settings")
                } else {
                    print("Notifications not enabled, trying to open settings")
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        Task {
                            await UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
    }
    
   
    
    // Handle Firebase Messaging token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase token: \(String(describing: fcmToken))")
        // Send this token to your server to associate it with the user
        if let token = fcmToken {
            self.fcmToken = token
        }
        
    }
    
    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification responses
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification response: \(userInfo)")
        completionHandler()
    }
}
