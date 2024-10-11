//
//  VotersView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/25/24.
//

import SwiftUI

struct VotersView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var submissionID: String?
    
    @State var votes: [Vote]?
    
    var body: some View {
        
        VStack{
            Capsule()
                    .fill(Color.secondary)
                    .opacity(0.5)
                    .frame(width: 50, height: 5)
                    .padding(.top, 20)
            
            Text("Votes")
                .font(.title2)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    if let votes = votes {
                        ForEach(votes) { vote in
                            VoteView(vote: vote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                        }
                    }
                }
                .padding(.bottom, 100) // Adding some space at the bottom
            }
            .task {
                await load()
            }
        }
    }
    
    func load() async {
        if let submissionID = submissionID {
            votes = await supabaseManager.getSubmissionVotes(parentID: submissionID)
        }
    }
    
}

#Preview {
    VotersView()
        .environmentObject(SupabaseManager())
}
