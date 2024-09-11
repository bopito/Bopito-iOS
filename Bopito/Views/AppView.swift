//
//  AppView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/5/24.
//

import SwiftUI

struct AppView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State private var selectedTab: TabSelection = .home
    
    var body: some View {
        
        TabView (selection: $selectedTab) {
            
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(TabSelection.home)
            
            NotificationsView()
                .tabItem {
                    Label("Ding", systemImage: "bell.fill")
                }
                .tag(TabSelection.notifications)
            
            
            ProfileView()
                .tabItem {
                    Label("Me", systemImage: "person.fill")
                }
                .tag(TabSelection.profile)
        }
        
    }
}

enum TabSelection {
    case home
    case notifications
    case profile
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .environmentObject(SupabaseManager())
    }
}
