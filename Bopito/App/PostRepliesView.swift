import SwiftUI

struct PostRepliesView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    var post: Submission?
    @State var user: User?
    
    @State private var replies: [Submission] = []
    @State private var isLoading: Bool = true
    @State private var error: String?
    
    @State private var replyText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                Text("Replies")
                    .padding(.bottom)
                
                if isLoading {
                    ProgressView("Loading Posts...")
                } else if let error = error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(replies) { reply in
                                ReplyView(reply: reply)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.bottom, 100) // Adding some space at the bottom
                    }
                }
            }
            
            if isTextFieldFocused {
                // Transparent overlay to detect taps
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
            }
            
            // Keyboard layer with comment input
            VStack {
                Spacer()

                
                HStack {
                    ZStack {
                        
                        Circle()
                            .strokeBorder(Color.black, lineWidth: 0) // Gray outline
                            .background(Circle().fill(.black))
                            .frame(width: 40, height: 40)
                        
//                        if let pictureURL = user?.profilePicture {
//                            AsyncImage(url: pictureURL) { image in
//                                image
//                                    .resizable()
//                                    .scaledToFill()
//                                    .clipShape(Circle())
//                                    .shadow(radius: 5)
//                            } placeholder: {
//                                ProgressView()
//                            }
//                            .frame(width: 20, height: 20)
//                        } else {
//                            ProgressView()
//                                .frame(width: 40, height: 40)
//                        }
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
                            await loadReplies()
                        }
                    }) {
                        Text("Send")
                            .padding(.trailing)
                    }
                }
                .padding()
                .background(Color.white)
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
                print("need to implement get account by id")
//                account = try await authManager.getAccountByID(accountId: authManager.getCurrentUserID())
//                await loadReplies()
            }
        }
    }

    
    
    private func sendReply() async {
        do {
            // Logic to send the comment
//            try await authManager.createSubmission(replyText: replyText, isTopLevel: true, parentID: post.uuid)
            // Dismiss the keyboard after sending
            isTextFieldFocused = false
        } catch {
            print("Error submitting reply: \(error.localizedDescription)")
        }
    }
    
    private func loadReplies() async {
//        do {
//            replies = try await authManager.getTopLevelReplies(postID: post.uuid)
//            isLoading = false
//        } catch {
//            self.error = error.localizedDescription // Ensure error is mutable
//            isLoading = false
//        }
    }
    
}

#Preview {
    PostRepliesView()
    
    
    .environmentObject(SupabaseManager())
}
