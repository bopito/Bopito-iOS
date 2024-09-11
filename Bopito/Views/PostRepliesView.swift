import SwiftUI

struct PostRepliesView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var post: Submission
    @State var user: User?
    @State var currentUser: User?
    @State private var replies: [Submission]?
    
    @State private var isLoading: Bool = true
    @State private var error: String?
    
    @State private var replyText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                Text("Replies")
                    .font(.title2)
                    .padding()

                ScrollView {
                    VStack(spacing: 1) {
                        // original post
                        PostView(post: post)
                
                        Divider()
                       
                        if let replies = replies {
                            ForEach(replies) { reply in
                                PostView(post: reply)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 25)
                                Divider()
                                if reply.replies_count == 0 {
                                        
                                }
//                                ReplyView(reply: reply)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
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

                HStack {
                    if let currentUser = currentUser {
                        ProfilePictureView(profilePictureURL: currentUser.profile_picture)
                            .frame(width: 60, height: 60)
                    } else {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                    
                    
                    TextField("Add a comment...", text: $replyText)
                        .padding(.leading)
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
                            .padding(.trailing)
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
        user = await supabaseManager.getUserByID(id: post.author_id)
        currentUser = await supabaseManager.getCurrentUser()
        replies = await supabaseManager.getReplies(parentID: post.id)
    }
    
    func sendReply() async {
        // todo
        // update auth status
        // if authorized check if allowed to take action
        
        if let currentUser = currentUser { // if logged in
            let authorID = currentUser.id
            await supabaseManager.postSubmission(
                author_id: authorID,
                parent_id: post.id,
                image: nil,
                text: replyText)
            replyText = "" // Clear the text editor on success
        }
        isTextFieldFocused = false
    }
    
    func reloadSubmission() async {
        if let updatedPost = await supabaseManager.getSubmission(submissionID: post.id) {
            post = updatedPost
            print(post.likes_count)
        }
    }
    
    
    
}

#Preview {
    PostRepliesView(
        post:
            Submission(id: "1", 
                       author_id: "1",
                       parent_id: nil,
                       replies_count: 1,
                       likes_count: 2,
                       image: "none",
                       text: "hello",
                       created_at: Date().formatted(.dateTime.year().month().day().hour().minute().second()),
                       edited_at: Date().formatted(.dateTime.year().month().day().hour().minute().second())
                      )
        )
    .environmentObject(SupabaseManager())
}
