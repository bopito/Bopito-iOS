//
//  FollowButtonView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/25/24.
//

import SwiftUI

struct FollowButtonView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var voterID: String?
    
    @State var user: User?
    @State var currentUser: User?
    
    @State var isCurrentUser: Bool = true
    
    @State var isFollowing: Bool = false
    
    var body: some View {
        
        Button(action: {
            Task {
                await followPressed()
            }
        }) {
            if !isCurrentUser {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(isFollowing ? Color.secondary : Color.blue)
                    .foregroundColor(isFollowing ? .white : .white)
                    .cornerRadius(10)
            }
        }
        .task {
            await load()
        }
    }
    
    
    
    func load() async {
        currentUser = await supabaseManager.getCurrentUser()
        
        if let userRef = user, let currentUserRef = currentUser {
            
            if userRef.id == currentUserRef.id {
                isCurrentUser = true
            } else {
                isCurrentUser = false
            }
            
            isFollowing = await supabaseManager.isFollowing(
                userID: userRef.id,
                followerID: currentUserRef.id)
        }
        
    }
    
    func followPressed() async {
        if let userToFollow = user {
            if let currentUser = await supabaseManager.getCurrentUser() {
                isFollowing = await supabaseManager.isFollowing(userID: userToFollow.id, followerID: currentUser.id)
                if !isFollowing {
                    // follow
                    await supabaseManager.followUser(userID: userToFollow.id)
                    
                    print("need to do notifications for follows in edge")
                    
                } else {
                    // otherwise unfollow
                    await supabaseManager.unfollowUser(userID: userToFollow.id)
                }
                // update @State for isLiked
                isFollowing = await supabaseManager.isFollowing(userID: userToFollow.id, followerID: currentUser.id)
                
                user = await supabaseManager.getUserByID(id: userToFollow.id)
            }
        }
        
    }
}

#Preview {
    FollowButtonView()
        .environmentObject(SupabaseManager())
}
