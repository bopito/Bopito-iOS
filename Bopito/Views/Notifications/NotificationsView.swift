//
//  NotificationsView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var currentUser: User?
    @State var notifications: [Notification]?
    
    var body: some View {
            ScrollView {
                Text("Notifications")
                    .font(.title2)
                
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
    
    func load() async {
        notifications = await supabaseManager.getNotifications()
    }
}

#Preview {
    NotificationsView()
        .environmentObject(SupabaseManager())
}
