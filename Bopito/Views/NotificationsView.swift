//
//  NotificationsView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        Text("0 Notifications")
    }
}

#Preview {
    NotificationsView()
        .environmentObject(SupabaseManager())
}
