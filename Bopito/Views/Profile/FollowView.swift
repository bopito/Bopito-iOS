//
//  FollowView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/12/24.
//

import SwiftUI

struct FollowView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
     
    @State var follow: Follow?
    @State var user: User?
    @State var currentUser: User?
    @State var type: String?
    
    @State var isShowingProfile = false
    
    var body: some View {
        HStack {
            if let user = user {
                ProfilePictureView(profilePictureURL: user.profile_picture)
                    .frame(width: 50, height: 50)
                    
            } else {
                ProgressView()
                    .frame(width: 50, height: 50)
            }
            
            VStack {
                if let user = user {
                    Text("\(user.username)")
                    if let name = user.name {
                        Text("\(name)")
                    }
                    
                } else {
                    Text("@placeholder")
                    Text("Place Holder")
                }
            }
            .padding(.leading, 10)
            
            Spacer()
            
            Button(action: {
                
            }) {
                Text("follow")
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 8)
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(10)
            
        }
        .padding(10)
        //.background()
        
        .contentShape(Rectangle()) // Ensures the entire area responds to taps
        .onTapGesture {
            isShowingProfile = true
        }
        .sheet(isPresented: $isShowingProfile) {
            ProfileView(user: user)
        }
        .onAppear() {
            Task{
               await load()
            }
        }
    }
    
    func load() async {
        if let follow = follow {
            if type == "followers" {
                user = await supabaseManager.getUserByID(id: follow.follower_id)
            } else if type == "following" {
                user = await supabaseManager.getUserByID(id: follow.user_id)
            }
            
            
        }
        
    }
}

#Preview {
    FollowView()
}
