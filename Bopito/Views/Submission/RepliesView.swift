import SwiftUI

struct RepliesView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    
    
    @State var submission: Submission

    @State private var replies: [Submission]?
    
    @State var user: User?
    @State var currentUser: User?
    
    @State private var isLoading: Bool = true
    @State private var error: String?
    
    @State private var replyText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                Capsule()
                        .fill(Color.secondary)
                        .opacity(0.5)
                        .frame(width: 50, height: 5)
                        .padding(.top, 20)
                
                Text("Replies")
                    .font(.title2)
                
                Divider()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        if var replies = replies {
                            ForEach(replies) { reply in
                                SubmissionView(submission: reply, onDelete: { deletedPostID in
                                    replies.removeAll { $0.id == deletedPostID }
                                })
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                        }
                    }
                    .padding(.bottom, 100) // Adding some space at the bottom
                }
                
            }
            
            if isTextFieldFocused {
                // Transparent overlay to detect taps
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
            }
            
            // Keyboard layer with comment input
            VStack (spacing: 0){
                Spacer()
                
                Divider()

                HStack (spacing:0) {
                    if let currentUser = currentUser {
                        ProfilePictureView(profilePictureURL: currentUser.profile_picture)
                            .frame(width: 60, height: 60)
                    } else {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                    
                    
                    TextField("Add a comment...", text: $replyText)
                        .padding(.leading, 8)
                        .padding(7)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .focused($isTextFieldFocused)

                    Button(action: {
                        // Handle send comment action
                        Task {
                            await sendReply()
                            await loadData()
                        }
                    }) {
                        Text("Send")
                            //.padding(.trailing)
                            .padding(15)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(30)
                            
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                    
            }
                
                
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done") {
                    isTextFieldFocused = false
                }
            }
        }
        .animation(.easeOut, value: isTextFieldFocused)
        .onAppear() {
            Task {
                await loadData()
            }
        }
    }

    func loadData() async {
        user = await supabaseManager.getUserByID(id: submission.author_id)
        currentUser = await supabaseManager.getCurrentUser()
        replies = await supabaseManager.getReplies(parentID: submission.id)
    }
    
    func sendReply() async {
        let trimmedText = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if postText is not just empty space or a completely empty string
        if !trimmedText.isEmpty {
            
            if let currentUser = currentUser, let user = user {
                // Create Submission in DB
                await supabaseManager.postSubmission(
                    author_id: currentUser.id,
                    parent_id: submission.id,
                    image: nil,
                    text: replyText)
                
                // Update Replies Count for Submission
                await supabaseManager.updateRepliesCount(parentID: submission.id)
                
                // Create Notification in DB
                let isPost = submission.parent_id == nil
                let message = "replied to your \(isPost ? "post" : "comment")!"
                let type = "comment"
                await supabaseManager.createNotification(
                    recipitentID: user.id,
                    senderID: currentUser.id,
                    type: type,
                    submissionID: submission.id,
                    message: message
                )
                
                replyText = "" // Clear the text editor on success
            }
            isTextFieldFocused = false
        }
    }
    
    func reloadSubmission() async {
        if let updatedPost = await supabaseManager.getSubmission(submissionID: submission.id) {
            submission = updatedPost
        }
    }
    
    
    
}

#Preview {
    RepliesView(
        submission:
            Submission(id: "1",
                       author_id: "1",
                       parent_id: nil,
                       image: "none",
                       text: "hello",
                       created_at: Date().formatted(.dateTime.year().month().day().hour().minute().second()),
                       edited_at: Date().formatted(.dateTime.year().month().day().hour().minute().second()),
                       likes_count: 0,
                       dislikes_count: 0,
                       boosts_count: 0,
                       replies_count: 0,
                       score: 0,
                       reports: 0
                      )
        )
    .environmentObject(SupabaseManager())
}
