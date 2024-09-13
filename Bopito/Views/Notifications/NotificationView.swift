//
//  NotificationView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/13/24.
//

import SwiftUI

struct NotificationView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var notification: Notification?
    @State var user: User?
    @State var currentUser: User?
    
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
                if let notification = notification, let user = user {
                    Text("\(user.username)\(notification.message)")
                } else {
                    Text("Error")
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
        print("loading")
        if let notification = notification {
            user = await supabaseManager.getUserByID(id: notification.sender_id)
            currentUser =  await supabaseManager.getCurrentUser()
            
            
        }
        
        
        
    }
}

#Preview {
    NotificationView()
}
