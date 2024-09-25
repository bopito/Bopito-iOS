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
    
    @State var votes: [Like]?
    
    var body: some View {
      
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
    
    func load() async {
        if let submissionID = submissionID {
            votes = await supabaseManager.getSubmissionVotes(parentID: submissionID)
        }
    }
    
}

#Preview {
    VotersView()
}
