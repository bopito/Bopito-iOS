//
//  FollowersView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/12/24.
//

import SwiftUI

struct FollowsView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var user: User?
    @State var currentUser: User?
    @State var follows: [Follow]?
    @State var type: String?
    
    var body: some View {
        
        ScrollView {
            LazyVStack(spacing: 0) {
                if let follows = follows {
                    ForEach(follows) { follow in
                        FollowView(follow: follow, type: type)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                    }
                }
            }
            .padding(.bottom, 100) // Adding some space at the bottom
        }
        
        
    }
    
}

#Preview {
    FollowsView(follows:
                    [
                        Follow(id: "String", user_id: "", follower_id: ""),
                        Follow(id: "String", user_id: "", follower_id: "")
                    ]
    )
    .environmentObject(SupabaseManager())
}
