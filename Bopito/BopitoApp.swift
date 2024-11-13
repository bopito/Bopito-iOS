//
//  BopitoApp.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/5/24.
//
//
//  BopitoApp.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/5/24.
//
import SwiftUI
import SwiftData

@main
struct BopitoApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var supabaseManager = SupabaseManager()
    @StateObject private var inAppPurchaseManager = InAppPurchaseManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var admobManager = AdmobManager()
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
                ContentView()
                    .environmentObject(inAppPurchaseManager)
                    .environmentObject(supabaseManager)
                    .environmentObject(notificationManager)
                    .environmentObject(admobManager)
                    .environmentObject(networkMonitor)
        }
    }
}


