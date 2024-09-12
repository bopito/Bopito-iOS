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
    
    var type: String?
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 50, height: 50)
            
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
                    //isShowingReplies = true
                }
//                .sheet(isPresented: $isShowingReplies) {
//                    PostRepliesView(post: post)
//                }
        .onAppear() {
            Task{
               await load()
            }
        }
    }
    
    func load() async {
        if let follow = follow {
            print(type)
            if type == "follower" {
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
