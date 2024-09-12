//
//  BopitoApp.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/5/24.
//
import SwiftUI
import SwiftData
import Supabase

@main
struct BopitoApp: App {

    let supabaseManager = SupabaseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(supabaseManager)
        }
    }
}
