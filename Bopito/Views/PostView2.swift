//
//  PostFullView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/18/24.
//

import SwiftUI
import Charts

struct PostView2: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var post: Submission
    
    @State var user: User?
    @State var currentUser: User?
    
    @State var time_since: String?
    
    @State var voteValue: Int = 0
    @State var likesCount: Int = 0
    @State var dislikesCount: Int = 0
    @State var boostsCount: Int = 0
    @State var commentsCount: Int = 0
    @State var sharesCount: Int = 0
    
    @State var score: Int = 0
    
    
    @State var isViewingAccount = false
    @State var isShowingReplies = false
    @State var isShowingDeleteAlert = false
    @State var isShowingReportAlert = false
    
    var body: some View {
        
        VStack (alignment:.leading, spacing:0){
            
            // Profile picture, username, etc
            HStack (spacing: 0) {
                if let user = user {
                    ProfilePictureView(profilePictureURL: user.profile_picture)
                        .frame(width: 35, height: 35)
                        .padding(.top, 5)
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
                Text(post.text)
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
                        //
                    }) {
                        Image("share")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 21, height: 21)
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
                        //
                    }) {
                        Image("comment")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.green)
                        Text("\(commentsCount)")
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Boost on Submission
                HStack {
                    Button(action: {
                        //
                    }) {
                        Image("boost")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 23, height: 23)
                            .foregroundColor(.yellow)
                        Text("\(boostsCount)")
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Fire / Water Buttons
                
                Button(action: {
                    Task {
                        if (voteValue >= 0) {
                            await votePressed(value: -1)
                        } else {
                            await votePressed(value: 0)
                        }
                    }
                    
                }) {
                    Image("thumb")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 23, height: 23)
                        .foregroundColor(voteValue < 0 ? .red : .gray)
                        .scaleEffect(x: -1, y: -1) // Flips the image vertically
                    Text("\(dislikesCount)")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        if (voteValue <= 0) {
                            await votePressed(value: 1)
                        } else {
                            await votePressed(value: 0)
                        }
                    }
                    
                }) {
                    Image("thumb")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 23, height: 23)
                        .foregroundColor(voteValue > 0 ? .blue : .gray)
                    Text("\(likesCount)")
                        .foregroundColor(.primary)
                    
                }.padding(.trailing, 0)
                
                
            }
            .padding(10)
            
        }
        .task {
            await load()
        }
        
        
        
        
    }
    
    
    
    func load() async {
        // load user who made the post
        user = await supabaseManager.getUserByID(id: post.author_id)
        
        // get current user to see if they've liked it
        currentUser = await supabaseManager.getCurrentUser()
        
        
        if let currentUser = currentUser {
            // Update local value for thumb color
            voteValue = await supabaseManager.getUserVote(
                submissionID: post.id,
                userID: currentUser.id)
            
        }
        
        // Get Likes and Dislikes Counts
        likesCount = await supabaseManager.getSubmissionVotesCount(
            submissionID: post.id,
            value: 1
        )
        dislikesCount = await supabaseManager.getSubmissionVotesCount(
            submissionID: post.id,
            value: -1
        )
        
        
        // set time_since based on post created_at timestamp
        if let created_at = post.created_at {
            if let datetime = DateTimeTool.shared.getSwiftDate(supabaseTimestamp: created_at) {
                time_since = DateTimeTool.shared.timeAgo(from: datetime)
            } else {
                
            }
        }
    }
    
    func reloadSubmission() async {
        if let updatedPost = await supabaseManager.getSubmission(submissionID: post.id) {
            post = updatedPost
        }
        
    }
    
    func votePressed(value: Int) async {
        print("voting: \(value)")
        // get current user
        if let currentUser = currentUser {
            // cast vote
            await supabaseManager.castVote(
                submissionID: post.id,
                likerID: currentUser.id,
                receiverID: post.author_id,
                value: value)
            // Update local value for thumb color
            voteValue = await supabaseManager.getUserVote(
                submissionID: post.id,
                userID: currentUser.id)
            // Update Likes/Dislikes counts
            likesCount = await supabaseManager.getSubmissionVotesCount(
                submissionID: post.id,
                value: 1
            )
            dislikesCount = await supabaseManager.getSubmissionVotesCount(
                submissionID: post.id,
                value: -1
            )
            
            // Create Notification in DB
            let isPost = post.parent_id == nil
            let message = "liked your \(isPost ? "post" : "comment")!"
            let type = "like"
            await supabaseManager.createNotification(
                recipitentID: post.author_id,
                senderID: currentUser.id,
                type: type,
                submissionID: post.id,
                message: message
            )
            
            await reloadSubmission()
        }
    }
    
    func deleteSubmission() async {
        print("deleted!")
        await supabaseManager.deleteSubmission(submissionID: post.id)
    }
    
    func reportSubmission() async {
        print("reported!")
    }
}

struct PostView2_Previews: PreviewProvider {
    static var previews: some View {
        PostView2(
            post:
                Submission(id: "preview_fake_id",
                           author_id: "preview_fake_id",
                           parent_id: nil,
                           replies_count: 1,
                           likes_count: 2,
                           image: "none",
                           text: "Hello, World!",
                           created_at: Date().formatted(),
                           edited_at: Date().formatted()
                          )
        )
        .environmentObject(SupabaseManager())
    }
}
