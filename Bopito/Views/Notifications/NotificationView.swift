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
    
    @State var time_since: String?
    
    @State var isShowingUser: Bool = false
    
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
                    Text("@\(user.username) \(notification.message)")
                        .font(.subheadline)
                } else {
                    Text("@hanshanshans replied to your comment!")
                    //.font(.callout)
                        .font(.subheadline)
                }
            }
            .padding(.leading, 10)
            
            Spacer()
            Divider()
            
            VStack {
                if let time_since = time_since {
                    Text(time_since)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 10)
            Divider()
            
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
        if let notification = notification {
            user = await supabaseManager.getUserByID(id: notification.sender_id)
            currentUser =  await supabaseManager.getCurrentUser()
            
            if let created_at = notification.created_at {
                if let datetime = DateTimeTool.shared.getSwiftDate(supabaseTimestamp: created_at) {
                    time_since = DateTimeTool.shared.timeAgo(from: datetime)
                }
            }
        }
        
        
        
    }
}

#Preview {
    NotificationView()
}
