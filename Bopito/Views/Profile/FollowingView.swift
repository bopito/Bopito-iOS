//
//  FollowingView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/12/24.
//

import SwiftUI

struct FollowingView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var currentUser: User?
    @State var follows: [Follow]?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let follows = follows {
                    ForEach(follows) { follow in
                        FollowView(follow: follow, type: "following")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                    }
                }
            }
            .padding(.bottom, 100) // Adding some space at the bottom
        }
    }
    
    func load() async {
    }
}

#Preview {
    FollowersView(follows:
                    [
                    Follow(id: "String", user_id: "", follower_id: ""),
                    Follow(id: "String", user_id: "", follower_id: "")
                    ]
    )
    .environmentObject(SupabaseManager())
}
