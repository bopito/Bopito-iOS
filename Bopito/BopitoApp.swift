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

    @StateObject private var supabaseManager = SupabaseManager()
    @StateObject private var notificationManager = NotificationManager()

    init() {
            
        InAppPurchaseManager.shared.startObserving()
        
    }

    var body: some Scene {
        WindowGroup {
            
                ContentView()
                    .environmentObject(supabaseManager)
                    .environmentObject(notificationManager)
                   
            
        }
    }
}


