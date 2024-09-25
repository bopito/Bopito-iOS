//
//  PostFullView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/18/24.
//

import SwiftUI
import Charts

enum ActiveSheet: Identifiable {
    case shares, replies, boosts, voters, profile

    var id: Int {
        hashValue
    }
}

struct SubmissionView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State private var activeSheet: ActiveSheet?
    
    @State var user: User?
    @State var currentUser: User?
    
    @State var submission: Submission
    @State var time_since: String?
    
    @State var voteValue: Int = 0
    
    @State var likesCount: Int = 0
    @State var dislikesCount: Int = 0
    @State var boostsCount: Int = 0
    @State var commentsCount: Int = 0
    @State var sharesCount: Int = 0
    
    @State var isReported: Bool = false
    
    @State var score: Int = 0
    
    
    var body: some View {
        
        VStack (alignment:.leading, spacing:0){
            
            // Profile picture, username, etc
            HStack (spacing: 0) {
                if let user = user {
                    ProfilePictureView(profilePictureURL: user.profile_picture)
                        .frame(width: 35, height: 35)
                        .padding(.top, 5)
                        .onTapGesture {
                            activeSheet = .profile
                        }
                } else {
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .symbolRenderingMode(.palette) // Allows foreground and background color customization
                        .foregroundStyle(.background, .secondary) // First color for the icon, second for the background
                        .frame(width: 35, height: 35)
                }
                VStack {
                    HStack {
                        if let user = user {
                            Text("@\(user.username)")
                                .onTapGesture {
                                    activeSheet = .profile
                                }
                            if user.verified == true {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                            }
                            
                        } else {
                            Text("@username")
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                        }
                        
                        if let time_since = time_since {
                            Text("\(time_since)")
                                .font(.subheadline)
                        } else {
                            Text("?h")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        Image(systemName: "ellipsis")
                    }
                }
                .padding(.leading, 10)
                
            }.padding(10)
            
            // Submission Text
            HStack {
                Text(submission.text)
                    .font(.body)
                
            }.padding(.horizontal, 10)
            
            // Image
            //                Image("SampleImage")
            //                    .resizable()
            //                    .aspectRatio(contentMode: .fit)
            //                    .background(.background)
            //                    .cornerRadius(10)
            //                    .padding(10)
            
            
            HStack {
                // Share Submission
                HStack {
                    Button(action: {
                        activeSheet = .shares
                    }) {
                        Image("share")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 17, height: 17)
                        //.foregroundColor(.primary)
                            .foregroundColor(.gray)
                        Text("\(sharesCount)")
                            .foregroundColor(.primary)
                    }
                }.padding(.leading, 0)
                
                
                Spacer()
                
                // Comment on Submission
                HStack {
                    Button(action: {
                        activeSheet = .replies
                    }) {
                        Image("comment")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(commentsCount > 0 ? .gray : .secondary)
                        Text("\(commentsCount)")
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Boost on Submission
                HStack {
                    Button(action: {
                        activeSheet = .boosts
                    }) {
                        Image("boost")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 19, height: 19)
                            .foregroundColor(boostsCount > 0 ? .gray : .secondary)
                        Text("\(boostsCount)")
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                //
                // Thumbs Down
                //
                Button(action: {
                    // No action here, using gestures instead
                }) {
                    Image("thumb")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 19, height: 19)
                        .foregroundColor(voteValue < 0 ? .red : .secondary)
                        .scaleEffect(x: -1, y: -1) // Flips the image vertically
                    Text("\(dislikesCount)")
                        .foregroundColor(.primary)
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            // Short press (tap) action for voting
                            Task {
                                if (voteValue >= 0) {
                                    await votePressed(value: -1)
                                } else {
                                    await votePressed(value: 0)
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.2) // Adjust duration as needed
                        .onEnded { _ in
                            // Long press action to open the sheet
                            activeSheet = .voters
                        }
                )
                
                Spacer()
                
                //
                // Thumbs Up
                //
                Button(action: {
                    // No action here, using gestures instead
                }) {
                    HStack {
                        Image("thumb")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 19, height: 19)
                            .foregroundColor(voteValue > 0 ? .blue : .secondary)
                        Text("\(likesCount)")
                            .foregroundColor(.primary)
                    }
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            // Short press (tap) action for voting
                            Task {
                                if (voteValue <= 0) {
                                    await votePressed(value: 1)
                                } else {
                                    await votePressed(value: 0)
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.2) // Adjust duration as needed
                        .onEnded { _ in
                            // Long press action to open the sheet
                            activeSheet = .voters
                        }
                )
                
                
            }
            .padding(10)
            
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
                case .shares:
                    Text("Shares") // Replace with your Account ViewTe
                case .replies:
                    RepliesView(submission: submission)
                case .boosts:
                    Text("Boosts") // Replace with your Delete Alert
                case .voters:
                    VotersView(submissionID: submission.id)
                case .profile:
                    ProfileView(user: user)
            }
        }
        .task {
            await load()
        }
        
        
        
        
        
    }
    
    
    
    func load() async {
        if user == nil || currentUser == nil {
      
            // load user who made the post
            user = await supabaseManager.getUserByID(id: submission.author_id)
            
            // get current user to see if they've liked it
            currentUser = await supabaseManager.getCurrentUser()
        }
        
        
        
        if let currentUser = currentUser {
            // Update local value for thumb color
            voteValue = await supabaseManager.getUserVote(
                submissionID: submission.id,
                userID: currentUser.id)
            
        }
        
        // Get Likes and Dislikes Counts
        likesCount = await supabaseManager.getSubmissionVotesCount(
            submissionID: submission.id,
            value: 1
        )
        dislikesCount = await supabaseManager.getSubmissionVotesCount(
            submissionID: submission.id,
            value: -1
        )
        
        // Get Comments Count
        commentsCount = await supabaseManager.getCommentsCount(
            parentID: submission.id
        )
        
        
        // set time_since based on post created_at timestamp
        if let created_at = submission.created_at {
            if let datetime = DateTimeTool.shared.getSwiftDate(supabaseTimestamp: created_at) {
                time_since = DateTimeTool.shared.timeAgo(from: datetime)
            } else {
                
            }
        }
    }
    
    func reloadSubmission() async {
        if let updatedPost = await supabaseManager.getSubmission(submissionID: submission.id) {
            submission = updatedPost
        }
        
    }
    
    func votePressed(value: Int) async {
        print("voting: \(value)")
        // get current user
        if let currentUser = currentUser {
            // cast vote
            await supabaseManager.castVote(
                submissionID: submission.id,
                likerID: currentUser.id,
                receiverID: submission.author_id,
                value: value)
            // Update local value for thumb color
            voteValue = await supabaseManager.getUserVote(
                submissionID: submission.id,
                userID: currentUser.id)
            // Update Likes/Dislikes counts
            likesCount = await supabaseManager.getSubmissionVotesCount(
                submissionID: submission.id,
                value: 1
            )
            dislikesCount = await supabaseManager.getSubmissionVotesCount(
                submissionID: submission.id,
                value: -1
            )
            
            // Create Notification in DB
            let isPost = submission.parent_id == nil
            let message = "liked your \(isPost ? "post" : "comment")!"
            let type = "like"
            await supabaseManager.createNotification(
                recipitentID: submission.author_id,
                senderID: currentUser.id,
                type: type,
                submissionID: submission.id,
                message: message
            )
            
            await reloadSubmission()
        }
    }
    
    func deleteSubmission() async {
        print("deleted!")
        await supabaseManager.deleteSubmission(submissionID: submission.id)
    }
    
    func reportSubmission() async {
        print("reported!")
    }
}

struct PostView2_Previews: PreviewProvider {
    static var previews: some View {
        SubmissionView(
            submission:
                Submission(id: "preview_fake_id",
                           author_id: "preview_fake_id",
                           parent_id: nil,
                           image: "none",
                           text: "Hello, World!",
                           created_at: Date().formatted(),
                           edited_at: Date().formatted()
                          )
        )
        .environmentObject(SupabaseManager())
    }
}
