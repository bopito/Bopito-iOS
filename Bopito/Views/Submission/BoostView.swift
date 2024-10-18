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
    
    var body: some View {
        //if let user = user {
            HStack (spacing: 0){
                if let user = user {
                    ProfilePictureView(profilePictureURL: user.profile_picture)
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 10)
                    Text("**@\(user.username)**")
                        
                } else {
                    Circle()
                        .frame(width: 25, height: 25)
                    Text("**@username**")
                }
                
                Spacer()
                
                if let boost = boost {
                    Text("\(boost.icon)")
                }
            }
            .padding(10)
            .task {
                await load()
            }
            Divider()
       // }
    }
    
    func load() async {
        guard let boost else {
            return
        }
        user = await supabaseManager.getUserByID(id: boost.user_id)
    }
}

#Preview {
    BoostView()
}
