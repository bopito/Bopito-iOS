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
    @State var notificationType: String?
    @State var time_since: String?
    
    @State private var activeSheet: SheetItem? = nil
    
    var body: some View {
        HStack (spacing: 0){
            if let user = user {
                
                
                ProfilePictureView(profilePictureURL: user.profile_picture)
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        //activeSheet = .profile
                        activeSheet = .profile
                    }
                
            } else {
                ProgressView()
                    .frame(width: 50, height: 50)
            }

            Group {
                if let notification = notification, let user = user {
                    Text("**@\(user.username)**")
                    +
                    Text(" \(notification.message)")
                } else {
                    Text("**@randomperson**")
                    +
                    Text(" replied to your comment!")
                       
                }
            }
            .font(.subheadline)
            .padding(.leading, 10)
            
            
            Spacer()
            
            VStack {
                if let time_since = time_since {
                    Text(time_since)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 10)
            
            
        }
        .padding(10)
        //.background()
        .contentShape(Rectangle()) // Ensures the entire area responds to taps
        .onTapGesture {
            //activeSheet = .profile
            activeSheet = .submission
        }
        .sheet(item: $activeSheet, onDismiss: {
            //
        }) { sheet in
            switch sheet {
                case .profile:
                    ProfileView(user: user, openedFromProfileTab: false)
//                case .follower:
//                    ProfileView(user: user, openedFromProfileTab: false)
                case .submission:
                    if let notification = notification {
                        if let submission_id = notification.submission_id {
                            PostView(submissionId: submission_id)
                        }
                    }
            }
        }
        .onAppear() {
            Task{
                await load()
            }
            
        }
    }
    
    func load() async {
        if let notification = notification {
            notificationType = notification.type
            
            user = await supabaseManager.getUserByID(id: notification.sender_id)
            currentUser =  await supabaseManager.getCurrentUser()
            
            if let created_at = notification.created_at {
                if let datetime = DateTimeTool.shared.getSwiftDate(supabaseTimestamp: created_at) {
                    time_since = DateTimeTool.shared.timeAgo(from: datetime)
                }
            }
        }
    }
    
    enum SheetItem: Identifiable {
        case submission
        case profile
        
        var id: Int {
            switch self {
            case .submission: return 1
            case .profile: return 2
            }
        }
    }
    
}

#Preview {
    NotificationView()
}
