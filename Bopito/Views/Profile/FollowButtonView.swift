//
//  FollowButtonView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/25/24.
//

import SwiftUI

struct FollowButtonView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var user: User?
    @State var currentUser: User?
    
    @State var isCurrentUser: Bool = false
    
    @State var isFollowing: Bool = false
    
    var body: some View {
        if !isCurrentUser {
            Button(action: {
                Task {
                    await followPressed()
                }
            }) {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(isFollowing ? Color.secondary : Color.blue)
                    .foregroundColor(isFollowing ? .primary : .white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 10)
            .task {
                await load()
            }
        }
    }
    
    
    func load() async {
        
        print(user?.id ?? nil, "   ", currentUser?.id ?? nil)
        if let user = user, let currentUser = currentUser {
            if user.id == currentUser.id {
                isCurrentUser = true
            }
            
            isFollowing = await supabaseManager.isFollowing(
                userID: user.id,
                followerID: currentUser.id)
        }
        
    }
    
    func followPressed() async {
        // get current user
        if let userToFollow = user {
            if let currentUser = await supabaseManager.getCurrentUser() {
                // update @State for isLiked
                isFollowing = await supabaseManager.isFollowing(userID: userToFollow.id, followerID: currentUser.id)
                // check if liked
                if !isFollowing {
                    // follow
                    await supabaseManager.followUser(userID: userToFollow.id)
                    // Create Notification in DB
       
                    let message = "started following you!"
                    let type = "follow"
                    await supabaseManager.createNotification(
                        recipitentID: userToFollow.id,
                        senderID: currentUser.id,
                        type: type,
                        submissionID: nil,
                        message: message
                    )
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
}
