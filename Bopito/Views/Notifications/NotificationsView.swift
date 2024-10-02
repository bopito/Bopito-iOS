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
    
    @State var notificationsEnabled: Bool = false
    
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
        notificationManager.checkNotificationSettings()
        notificationsEnabled = notificationManager.notificationsEnabled
        if !notificationsEnabled {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                //await UIApplication.shared.open(url)
            }
        } else {
            notifications = await supabaseManager.getNotifications()
        }
    }
}

#Preview {
    NotificationsView()
        .environmentObject(SupabaseManager())
        .environmentObject(NotificationManager())
}
