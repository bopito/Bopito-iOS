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
                    Image(systemName: "house")
                }
                .padding(5)
                .tag(TabSelection.home)
            
            SearchView()
                .tabItem {
                    Label("", systemImage: "magnifyingglass")
                }
                .tag(TabSelection.search)
                .badge(0) // Example badge
            
            NotificationsView()
                .tabItem {
                    Label("", systemImage: "bell.fill")
                }
                .tag(TabSelection.notifications)
            
            
            ProfileView(openedFromProfileTab: true)
                .tabItem {
                    Label("", systemImage: "person.fill")
                }
                .tag(TabSelection.profile)
             
        }
        .accentColor(.blue)
        
        
    }
}

enum TabSelection {
    case home
    case search
    case notifications
    case profile
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .environmentObject(SupabaseManager())
            .environmentObject(InAppPurchaseManager())
    }
}
