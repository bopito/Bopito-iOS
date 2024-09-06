import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State private var isLoading = true
    @State private var error: Error?
    @State private var posts: [Submission] = []
    
    // Use the Account object directly
    @State private var user: User?
    
    var body: some View {
        VStack {
            // Profile picture
            ZStack {
                Circle()
                    .strokeBorder(Color.gray, lineWidth: 4) // Gray outline
                    .background(Circle().fill(Color.black))
                    .frame(width: 100, height: 100) // Adjust size
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 100, height: 100)
                } else {
               
//                    AsyncImage(url: account?.picture) { phase in
//                        switch phase {
//                        case .empty:
//                            ProgressView()
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .scaledToFill()
//                                .clipShape(Circle()) // Make image circular
//                                .shadow(radius: 10) // Optional: Add shadow
//                                .frame(width: 50, height: 50)
//                        case .failure:
//                            Image(systemName: "person.crop.circle.fill")
//                                .resizable()
//                                .scaledToFill()
//                                .clipShape(Circle())
//                                .frame(width: 100, height: 100)
//                                .foregroundColor(.gray)
//                        @unknown default:
//                            Image(systemName: "person.crop.circle.fill")
//                                .resizable()
//                                .scaledToFill()
//                                .clipShape(Circle())
//                                .frame(width: 100, height: 100)
//                                .foregroundColor(.gray)
//                        }
//                    }
                    
                }
            }
            
            // Username
            if true {
                Text("@fix for username")
                    .font(.headline)
                Text("No bio")
                    .foregroundColor(.black)
                    .font(.callout)
                Text("edit bio")
                    .foregroundColor(.blue)
                    .font(.headline)
            } else {
                Text("Loading...")
                    .font(.headline)
                    .padding()
            }
            
            // Buttons in an HStack
            HStack(spacing: 1) {
                Button(action: {
                    // Action for the "Posts" button
                    print("Posts button tapped")
                }) {
                    Text("Posts")
                        .frame(maxWidth: .infinity) // Make the button take up all available width
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                }
                
                Button(action: {
                    // Action for the "Comments" button
                    print("Comments button tapped")
                }) {
                    Text("Comments")
                        .frame(maxWidth: .infinity) // Make the button take up all available width
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                }
                
                Button(action: {
                    // Action for the "Likes" button
                    print("Likes button tapped")
                }) {
                    Text("Likes")
                        .frame(maxWidth: .infinity) // Make the button take up all available width
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                }
            }
            .frame(width: UIScreen.main.bounds.width) // Ensure HStack takes up full width
  
            if isLoading {
                ProgressView("Loading...")
            } else if let error = error {
                Text("Error loading posts: \(error.localizedDescription)")
            } else {
                ScrollView {
                    Text("test")
//                    VStack(spacing: 1) {
//                        ForEach(posts) { post in
//                            PostView(post: post)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            
//                        }
//                        Text("That's all for now!")
//                            .padding(.top, 40)
//                            .padding(.bottom, 40)
//                            .foregroundColor(.gray)
//                    }
                }
            }
        }
        .onAppear {
            Task {
//                do {
//                    // Load account and posts data
//                    account = await authManager.getAccountByID(accountId: try authManager.getCurrentUserID())
//                    // Load user posts
//                    posts = try await authManager.getUserPosts(accountID:  try authManager.getCurrentUserID())
//                    isLoading = false
//                } catch {
//                    self.error = error
//                    isLoading = false
//                }
            }
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(SupabaseManager())
}


