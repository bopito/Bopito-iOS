//
//  PostFullView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/18/24.
//

import SwiftUI
import Charts

enum ActiveSheet: Identifiable {
    case shares, replies, boosts, boosters, voters, profile
    var id: Int {
        hashValue
    }
}
enum ActiveAlert: Identifiable {
    case delete, report
    var id: Int {
        hashValue
    }
}

struct SubmissionView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager

    @State var user: User?
    @State var currentUser: User?
    
    @State var submission: Submission
    @State var time_since: String?
    
    @State var voteValue: Int = 0
    
    @State var likesCount: Int = 0
    @State var dislikesCount: Int = 0
    @State var repliesCount: Int = 0
    @State var sharesCount: Int = 0
    
    @State var flagged: Bool = false
    
    @State var score: Int?
    
    // Popup Views
    @State private var activeSheet: ActiveSheet?
    @State private var activeAlert: ActiveAlert?
    
    var onDelete: (String) -> Void // Callback for removing post in parent view when deleted
    
    
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
                HStack (spacing:0) {
                    if let user = user {
                        Text("@\(user.username)")
                            .onTapGesture {
                                activeSheet = .profile
                            }
                            .padding(.leading, 10)
                        if user.verified == true {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .padding(.leading, 7)
                        }
                        
                    } else {
                        //placeholder
                        /*
                        Text("@username")
                            .padding(.leading, 10)
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .padding(.leading, 7)
                         */
                    }
                    
                    if let time_since = time_since {
                        Text("\(time_since)")
                            .font(.subheadline)
                            .padding(.leading, 10)
                    } else {
                        //placeholder
                        //Text("?h")
                         //   .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    Menu {
                        if let user = user, let currentUser = currentUser {
                            if user.id == currentUser.id {
                                // Delete option
                                Button(action: {
                                    activeAlert = .delete
                                }) {
                                    Label("Delete Post", systemImage: "trash")
                                        .foregroundColor(.red)
                                }
                            } else {
                                // Report option
                                Button(action: {
                                    activeAlert = .report
                                }) {
                                    Label("Report Post", systemImage: "flag")
                                        .foregroundColor(.red)
                                }
                                
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .padding(.leading, 20)
                            .padding(.vertical, 10)
                            .background()
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle()) // Make the entire area tappable
                    
                }
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
                }
                
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
                            .foregroundColor(repliesCount > 0 ? .green : .secondary)
                        Text("\(repliesCount)")
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Boost on Submission
                
                Button(action: {
                    activeSheet = .boosts
                }) {
                    Image("boost")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 19, height: 19)
                        .foregroundColor(score != nil ? .yellow : .secondary)
                    Text("\(score ?? 0)")
                        .foregroundColor(.primary)
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            activeSheet = .boosts
                        }
                )
//                .simultaneousGesture(
//                    LongPressGesture(minimumDuration: 0.2) // Adjust duration as needed
//                        .onEnded { _ in
//                            // Long press action to open the sheet
//                            activeSheet = .boosters
//                        }
//                )
                
                
                Spacer()
                
                // Thumbs Down
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
                                    //dislikesCount += 1
                                    await votePressed(value: -1)
                                } else {
                                    //dislikesCount -= 1
                                    await votePressed(value: 0)
                                }
                            }
                        }
                )
//                .simultaneousGesture(
//                    LongPressGesture(minimumDuration: 0.2) // Adjust duration as needed
//                        .onEnded { _ in
//                            // Long press action to open the sheet
//                            activeSheet = .voters
//                        }
//                )
                
                Spacer()
                
                // Thumbs Up
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
                                    //likesCount += 1
                                    await votePressed(value: 1)
                                } else {
                                    //likesCount -= 1
                                    await votePressed(value: 0)
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.15) // Adjust duration as needed
                        .onEnded { _ in
                            // Long press action to open the sheet
                            activeSheet = .voters
                        }
                )
                
                
            }
            .padding(10)
            
            Divider()
            
            
        }
        .sheet(item: $activeSheet, onDismiss: {
            Task {
                await reloadSubmission()
            }
        }) { sheet in
            switch sheet {
            case .shares:
                SharesView()
            case .replies:
                RepliesView(submission: submission)
            case .boosts:
                BoostsView(submission: submission)
            case .boosters:
                BoostersView()
            case .voters:
                VotersView(submissionID: submission.id)
            case .profile:
                ProfileView(user: user, openedFromProfileTab: false)
            }
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .delete:
                return Alert(
                    title: Text("Delete Post"),
                    message: Text("Are you sure you want to delete this post? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete"), action: {
                        Task {
                            submission.text = "[Marked for Deletion]"
                            await deleteSubmission()
                        }
                    }),
                    secondaryButton: .cancel()
                )
                
            case .report:
                return Alert(
                    title: Text("Report Post"),
                    message: Text("Are you sure you want to report this post?"),
                    primaryButton: .destructive(Text("Report"), action: {
                        Task {
                            await reportSubmission()
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
            
        }
        .task {
            await load()
        }
        
    }
    
    
    
    func load() async {
        
        //await supabaseManager.updateRepliesCount(submissionID: submission.id)
        
        if user == nil || currentUser == nil {
            
            // load user who made the post
            user = await supabaseManager.getUserByID(id: submission.author_id)
            
            // get current user to see if they've liked it
            currentUser = await supabaseManager.getCurrentUser()
        }
        
        if let currentUser = currentUser {
            voteValue = await supabaseManager.getUserVote(
                submissionID: submission.id,
                userID: currentUser.id)
        }
        
        // Get Likes and Dislikes Counts
        likesCount = submission.likes_count
        dislikesCount = submission.dislikes_count
        
        // Get Comments Count
        repliesCount = submission.replies_count
        
        // Get Score
        if let submissionScore = submission.score {
            score = submissionScore
        }
        
        // set time_since based on post created_at timestamp
        if let created_at = submission.created_at {
            if let datetime = DateTimeTool.shared.getSwiftDate(supabaseTimestamp: created_at) {
                time_since = DateTimeTool.shared.timeAgo(from: datetime)
            } else {
                
            }
        }
    }
    
    func reloadSubmission() async {
        self.submission =  await supabaseManager.getSubmission(submissionID: submission.id)!
        // Likes and Dislikes
        likesCount = submission.likes_count
        dislikesCount = submission.dislikes_count
        // Replies Count
        await supabaseManager.updateRepliesCount(submissionID: submission.id)
        repliesCount = submission.replies_count
        // Score (Boosts/Smites)
        if let submissionScore = submission.score {
            score = submissionScore
        }
    }
    
    func votePressed(value: Int) async {
        print("voting: \(value)")
        // get current user
        if let currentUser = currentUser {
            // cast vote
            await supabaseManager.castVote(
                submissionID: submission.id,
                voterID: currentUser.id,
                receiverID: submission.author_id,
                value: value)
            // Update local value for thumb color
            voteValue = await supabaseManager.getUserVote(
                submissionID: submission.id,
                userID: currentUser.id)
            // Update Likes/Dislikes counts
            await supabaseManager.updateLikesCount(submissionID: submission.id)
            await supabaseManager.updateDislikesCount(submissionID: submission.id)
            
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
            likesCount = submission.likes_count
            dislikesCount = submission.dislikes_count
        }
    }
    
    func deleteSubmission() async {
        await supabaseManager.deleteSubmissionAndReplies(submissionID: submission.id)
        onDelete(submission.id)
    }
    
    func reportSubmission() async {
        await supabaseManager.reportSubmission(submissionID: submission.id)
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
                           edited_at: Date().formatted(),
                           likes_count: 0,
                           dislikes_count: 0,
                           replies_count: 0,
                           score: 0,
                           reports: 0
                          ), onDelete: {deletedPostID in }
        )
        .environmentObject(SupabaseManager())
    }
}
