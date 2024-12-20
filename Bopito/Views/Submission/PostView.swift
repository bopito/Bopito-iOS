//
//  PostView.swift
//  Bopito
//
//  Created by Hans Heidmann on 12/17/24.
//

import SwiftUI

struct PostView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var submissionId: String?
    @State var submission: Submission?
    
    var body: some View {
        VStack {
            Capsule()
                    .fill(Color.secondary)
                    .opacity(0.5)
                    .frame(width: 50, height: 5)
                    .padding(.top, 20)
            
            Text("My Post")
                .font(.title2)
            Divider()
            
            if let submission = submission {
                SubmissionView(submission: submission, onDelete: { deletedPostID in
                    //
                })
            }
            Spacer()
        }
        .task {
            await load()
        }
    }
    
    func load() async {
        if let submissionId = submissionId {
            submission = await supabaseManager.getSubmission(submissionID: submissionId)
        }
    }
}

#Preview {
    PostView()
}
