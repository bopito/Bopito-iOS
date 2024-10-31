//
//  FollowersFollowingTabView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/12/24.
//

import SwiftUI

struct FollowsTabView: View {
    
    @State var selectedTab: Int = 1
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var currentUser: User?
    @State var user: User?
    @State var followers: [Follow]?
    @State var following: [Follow]?
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.secondary)
                .opacity(0.5)
                .frame(width: 50, height: 5)
                .padding(.top, 20)
            if selectedTab == 0 {
                Text("Followers")
                    .font(.title2)
                    .padding(10)
            } else {
                Text("Following")
                    .font(.title2)
                    .padding(10)
            }
            Divider()
            
            TabView(selection: $selectedTab) {
                if let currentUser = currentUser,
                   let user = user,
                   let followers = followers,
                   let following = following
                {
                    FollowsView(user: user, 
                                currentUser: currentUser,
                                follows: followers,
                                type: "followers"
                    ) // First subview
                        .tag(0) // Assign a tag for each subview
                        .tabItem {
                            Label("Followers", systemImage: "1.circle")
                        }
                    
                    FollowsView(user: user, 
                                currentUser: currentUser,
                                follows: following,
                                type: "following"
                    ) // Second subview
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
        if let user = user {
            followers = await supabaseManager.getFollowers(userID: user.id)
            following = await supabaseManager.getFollowing(userID: user.id)
        }
    }
}

#Preview {
    FollowsTabView()
        .environmentObject(SupabaseManager())
}
