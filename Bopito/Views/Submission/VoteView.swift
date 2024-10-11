//
//  VoteView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/25/24.
//

import SwiftUI

struct VoteView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var vote: Like?
    @State var user: User?
    @State var currentUser: User?
    
    @State var isShowingProfile: Bool = false
    
    var body: some View {
        HStack {
            
            if let user = user {
                ProfilePictureView(profilePictureURL: user.profile_picture)
                    .frame(width: 35, height: 35)
                    .padding(.leading, 10)
                    
            } else {
                ProgressView()
                    .frame(width: 35, height: 35)
                    .padding(.leading, 10)
            }
            
            VStack {
                if let user = user {
                    Text("\(user.username)")
                    
                } else {
                    Text("@placeholder")
                    Text("Place Holder")
                }
            }
            .padding(.leading, 10)
            
            Spacer()
            
            if let vote = vote {
                Image("thumb")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 19, height: 19)
                    .foregroundColor(vote.value > 0 ? .blue : .red)
                    .rotationEffect(vote.value < 0 ? .degrees(180) : .degrees(0))
            } else {
                // placeholder
                Image("thumb")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 19, height: 19)
                    .foregroundColor(.secondary)
            }
            
            if let user = user {
                FollowButtonView(user: user)
                    .padding(.leading, 10)
            }
            
        }
        .padding(10)
        //.background()
        
        .contentShape(Rectangle()) // Ensures the entire area responds to taps
        .onTapGesture {
            isShowingProfile = true
        }
        .sheet(isPresented: $isShowingProfile) {
            ProfileView(user: user, openedFromProfileTab: false)
        }
        .onAppear() {
            Task{
               await load()
            }
        }
    }
    
    
    func load() async {
        // if vote get user
        if let vote = vote {
            user = await supabaseManager.getUserByID(id: vote.liker_id)
            currentUser = await supabaseManager.getCurrentUser()
        }
    }
}

#Preview {
    VoteView()
        .environmentObject(SupabaseManager())
}
