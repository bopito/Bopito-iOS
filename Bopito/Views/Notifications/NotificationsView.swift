//
//  NotificationsView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State var currentUser: User?
    @State var notifications: [Notification]?
    
    @State var notificationsEnabled: Bool?
    
    var body: some View {
        VStack {
            Text("Notifications")
                .font(.title2)
                .padding(.top, 10)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    if let notifications = notifications {
                        ForEach(notifications) { notification in
                            NotificationView(notification: notification)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                        }
                    }
                }
                .padding(.bottom, 100) // Adding some space at the bottom
            }
            .task {
                print("loading")
                await load()
            }
        }
    }
    
    func load() async {
        // Get Supabase Notifications
        notifications = await supabaseManager.getNotifications()
        
        // Push Notifications Check
//        notificationManager.checkNotificationSettings()
//        
    }
}

#Preview {
    NotificationsView()
        .environmentObject(SupabaseManager())
        .environmentObject(NotificationManager())
}
