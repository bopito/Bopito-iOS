//
//  FollowersFollowingTabView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/12/24.
//

import SwiftUI

struct FollowersFollowingTabView: View {
    
    @State private var selectedTab = 0 // Track selected tab index
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var currentUser: User?
    @State var followers: [Follow]?
    @State var following: [Follow]?
    
    var body: some View {
        VStack {
            Divider()
            TabView(selection: $selectedTab) {
                if let currentUser = currentUser, let followers = followers, let following = following {
                    FollowersView(currentUser: currentUser, follows: followers) // First subview
                        .tag(0) // Assign a tag for each subview
                        .tabItem {
                            Label("Followers", systemImage: "1.circle")
                        }
                    
                    FollowingView(currentUser: currentUser, follows: following) // Second subview
                        .tag(1)
                        .tabItem {
                            Label("Following", systemImage: "2.circle")
                        }
                }
                
            }
            .tabViewStyle(PageTabViewStyle()) // Enable swipe between subviews
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)) // Optional: Show dots indicator at the bottom
        }
        .onAppear() {
            Task {
                await load()
            }
            
        }
        
    }
    
    func load() async {
        
        currentUser = await supabaseManager.getCurrentUser()
        if let currentUser = currentUser {
            followers = await supabaseManager.getFollowers(userID: currentUser.id)
            following = await supabaseManager.getFollowing(userID: currentUser.id)
        }
    }
}

#Preview {
    FollowersFollowingTabView()
        .environmentObject(SupabaseManager())
}
