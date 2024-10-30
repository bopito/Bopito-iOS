//
//  BoostView.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/18/24.
//

import SwiftUI

struct BoostView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var boost: Boost?
    @State var user: User?
    
    @State var timeRemaining: TimeInterval = 1
    @State var timer: Timer?
    
    var body: some View {
        //if let user = user {
        HStack (spacing: 0){
            if let user = user {
                ProfilePictureView(profilePictureURL: user.profile_picture)
                    .frame(width: 25, height: 25)
                    .padding(.trailing, 10)
                Text("**@\(user.username)**")
                
            } else {
//                Circle()
//                    .frame(width: 25, height: 25)
//                    .padding(.trailing, 10)
                //Text("**@username**")
            }
            
            Spacer()
            
            if let boost = boost {
                Text(timeString(from: timeRemaining))
                    .padding(.trailing, 20)
                    .foregroundColor(boost.power > 0 ? .blue : .red)
                    
            } else {
                Text(timeString(from: 0))
                    .padding(.trailing, 20)
                    .foregroundColor(timeRemaining > 0 ? .primary : .secondary)
                    
            }
            
            
            if let boost = boost {
                Text("\(boost.icon)")
            }
            else {
                Text("🤙")
            }
            
            
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(timeRemaining > 0 ? Color(.systemBackground) : .secondary.opacity(0.5))
        .task {
            await load()
        }
        
        Divider()
    }
    
    func load() async {
        guard let boost else {
            return
        }
        user = await supabaseManager.getUserByID(id: boost.user_id)
        
        startCountdown()
    }
    
    func startCountdown() {
        updateRemainingTime()
        
        // Schedule a repeating timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateRemainingTime()
            
            if timeRemaining <= 0 {
                timer?.invalidate()
                timeRemaining = 0 // Ensure timeRemaining doesn’t show negative values
            }
        }
    }
    
    func updateRemainingTime() {
        guard let boost else { return }

           // Convert the ISO 8601 date string to a Date object
           guard let createdDate = DateTimeTool.shared.getSwiftDate(supabaseTimestamp: boost.created_at) else {
               return
           }

           // Add the boost time interval (assuming it's in seconds)
           let expirationDate = createdDate.addingTimeInterval(TimeInterval(boost.time) * 60)
           
           // Calculate the time remaining
           timeRemaining = max(expirationDate.timeIntervalSinceNow, 0)
    }
    
    func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    BoostView()
}
