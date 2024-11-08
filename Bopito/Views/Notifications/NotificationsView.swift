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
        VStack (spacing:0) {
            Text("Notifications")
                .font(.title2)
                .padding(10)
            
            Divider()
            
            /*
            if !notificationManager.notificationsEnabled {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                        .padding(10)
                    Text("Push Notifications are not enabled")
                        .foregroundStyle(.red)
                        .padding(.bottom, 10)
                    Button(action: {
                        notificationManager.openNotificationsSettings()
                    }, label: {
                        Text("Settings")
                            .padding(10)
                            .foregroundColor(.white)
                            .background(.red)
                            .cornerRadius(10)
                    })
                    .padding(.bottom, 10)
                }
                Divider()
            }
             */
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    if let notifications = notifications {
                        ForEach(notifications) { notification in
                            NotificationView(notification: notification)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                        }
                    } else {
                        // show something?
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
        
        notificationManager.requestNotificationPermissions()
        notificationManager.checkNotificationSettings()
        if !notificationManager.notificationsEnabled {
            
        }
    }
}

#Preview {
    NotificationsView()
        .environmentObject(SupabaseManager())
        .environmentObject(NotificationManager())
}
