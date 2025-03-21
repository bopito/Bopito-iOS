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
enum ActiveFullscreenCover: Identifiable {
    case post, profile
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
    
    @State var submissionText: String = ""
    
    @State var likesCount: Int = 0
    @State var dislikesCount: Int = 0
    @State var repliesCount: Int = 0
    @State var sharesCount: Int = 0
    
    @State var flagged: Bool = false
    
    @State var score: Int?
    
    // Popup Views
    @State private var activeSheet: ActiveSheet?
    @State private var activeFullscreenCover: ActiveFullscreenCover?
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
                            //activeFullscreenCover = .profile
                        }
                } else {
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .symbolRenderingMode(.palette) // Allows foreground and background color customization
                        .foregroundStyle(.background, .secondary) // First color for the icon, second for the background
                        .frame(width: 35, height: 35)
                }
                HStack (alignment:.center, spacing:0) {
                    if let user = user, let time_since = time_since {
                        
                        Text("\(user.name)")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                                .onTapGesture {
                                    activeSheet = .profile
                                }
                                .padding(.leading, 8)
                                .layoutPriority(2) // Higher priority
                                .lineLimit(1)
                                .truncationMode(.tail)

                            // Username - truncate if needed
                            Text("@\(user.username)")
                                .font(.system(size: 16, weight: .light, design: .default))
                                .foregroundColor(.secondary)
                                .onTapGesture {
                                    activeSheet = .profile
                                }
                                .padding(.leading, 4)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .layoutPriority(0) // lowest priority

                            // Verified badge if user is verified
                            if user.verified == true {
                                ZStack(alignment: .center) {
                                    Circle()
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(.white)
                                    Image(systemName: "checkmark.seal.fill")
                                        .resizable()
                                        .frame(width: 17, height: 17)
                                        .foregroundColor(.blue)
                                }
                                .padding(.leading, 4)
                            }

                            // Time
                            Text("· \(time_since)")
                                .font(.system(size: 16, weight: .light, design: .default))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                                .layoutPriority(3) // highest priority
                            
                    } else {
                        //placeholder
                        /*
                        Text("@username")
                            .padding(.leading, 10)
                            .font(.subheadline)
                            .bold()
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .frame(width: 17, height: 17)
                            .foregroundColor(.blue)
                            .padding(.leading, 7)
                        Text("?h")
                            .padding(.leading, 10)
                            .font(.subheadline)
                         */
                         
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
                            .padding(.leading, 5)
                            .padding(.vertical, 10)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle()) // Make the entire area tappable
                    
                }
            }.padding(10)
            
            // Submission Text
            HStack {
                let components = extractLinks(from: submissionText)

                        // Use a VStack or HStack to display the components inline
                VStack (alignment: .leading) {
                            // Iterate through components and display them
                            ForEach(components, id: \.text) { component in
                                if let url = component.url {
                                    // For links, make them tappable
                                    Text(component.text)
                                        .foregroundColor(.blue)
                                        .underline()
                                        .onTapGesture {
                                            UIApplication.shared.open(url)
                                        }
                                } else {
                                    // For non-link text, display normally
                                    Text(component.text)
                                        .frame(width: .infinity)
                                        .lineLimit(8)
                                        .truncationMode(.tail)

                                }
                            }
                            .font(.body)
                        }
                
            }.padding(.horizontal, 10)
            
            // Image
            /*
            Image("SampleImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(.background)
                .cornerRadius(10)
                .padding(10)
            */
            
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
                await supabaseManager.unsubscribeToBoostsRealtime()
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
        .fullScreenCover(item: $activeFullscreenCover, onDismiss: {
            Task {
                await reloadSubmission()
            }
        }) { cover in
            switch cover {
                case .post:
                    PostView()
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
        .onDisappear() {
            //print("onDisappear()")
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
        
        // Set submissionText
        submissionText = submission.text
        
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
        repliesCount = submission.replies_count
        // Score (Boosts/Smites)
        if let submissionScore = submission.score {
            score = submissionScore
        }
    }
    
    func votePressed(value: Int) async {
        print("voting: \(value)")
        // Temporarily update likes/dislikes counts
        let oldVoteValue = voteValue
        if oldVoteValue == 0 {
            if value == 1 {
                likesCount += 1
            } else if value == -1 {
                dislikesCount += 1
            }
        } else if oldVoteValue == 1 {
            if value == 0 {
                likesCount -= 1
            } else if value == 1 {
                likesCount -= 1
            } else if value == -1 {
                likesCount -= 1
                dislikesCount += 1
            }
        } else if oldVoteValue == -1 {
            if value == 0 {
                dislikesCount -= 1
            } else if value == 1 {
                likesCount += 1
                dislikesCount -= 1
            } else if value == -1 {
                dislikesCount -= 1
            }
        }
        // Update thumbs sup/down color
        voteValue = value
        
        // Cast vote into database
        await supabaseManager.castVote(
            voteValue: value,
            submissionId: submission.id
        )
        
        await reloadSubmission()
        likesCount = submission.likes_count
        dislikesCount = submission.dislikes_count
        
    }
    
    func deleteSubmission() async {
        submissionText = "[Marked for Deletion]"
        
        await supabaseManager.deleteSubmission(submissionId: submission.id)
        onDelete(submission.id)
    }
    
    func reportSubmission() async {
        await supabaseManager.reportSubmission(submissionId: submission.id, reason: "other")
    }
    
    func extractLinks(from text: String) -> [LinkComponent] {
            let words = text.split(separator: " ")
            var components: [LinkComponent] = []

            var currentText = ""
            for word in words {
                if let url = URL(string: String(word)), url.scheme == "http" || url.scheme == "https" {
                    if !currentText.isEmpty {
                        components.append(LinkComponent(text: currentText))
                        currentText = ""
                    }
                    components.append(LinkComponent(text: String(word), url: url))
                } else {
                    currentText += (currentText.isEmpty ? "" : " ") + word
                }
            }

            if !currentText.isEmpty {
                components.append(LinkComponent(text: currentText))
            }

            return components
        }
}

struct LinkComponent: Hashable {
    let text: String
    let url: URL?

    init(text: String, url: URL? = nil) {
        self.text = text
        self.url = url
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
                           score: 0
                          ), onDelete: {deletedPostID in }
        )
        .environmentObject(SupabaseManager())
    }
}
