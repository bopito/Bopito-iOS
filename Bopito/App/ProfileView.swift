import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State private var isLoading = true
    @State private var error: Error?
    
    @State private var posts: [Submission] = []
    @State var profilePictureURL: String = "https://lqqhpvlxroqfqyfrpaio.supabase.co/storage/v1/object/sign/profile_pictures/default.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJwcm9maWxlX3BpY3R1cmVzL2RlZmF1bHQucG5nIiwiaWF0IjoxNzI1NjA5MzE5LCJleHAiOjIwNDA5NjkzMTl9.ONDdeTtJgJ03xfskqFij2PTx2SDNsVaI1IdlZoCEv_g"
    
    // Use the Account object directly
    @State var user: User?
    
    var body: some View {
        VStack {
            // Profile picture
            ZStack {
                Circle()
                    .frame(width: 100, height: 100) // Adjust size
                    .opacity(0)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 100, height: 100)
                } else {
                    
                    AsyncImage(url: URL(string:profilePictureURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle()) // Make image circular
                                //.shadow(radius: 10) // Optional: Add shadow
                                .frame(width: 100, height: 100)
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        @unknown default:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                    }
                    
                }
            }
            
            // Username
            if let user = user {
                Text("@\(user.username)")
                    .font(.headline)
                Text("\(user.bio)")
                    .font(.callout)
                Text("Edit Profile")
                    .foregroundColor(.blue)
                    .font(.footnote)
            } else {
                ProgressView()
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
                    VStack(spacing: 1) {
                        ForEach(posts) { post in
                            PostView(post: post)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.bottom, 40)
                    .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            Task {
                do {
                    // Load account and posts data
                    user = await supabaseManager.getCurrentUser()
                    // Load user posts
                    if let user = user {
                        posts = await supabaseManager.getUserPosts(userID: user.id) ?? []
                    }
                    
                    isLoading = false
                } catch {
                    self.error = error
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(SupabaseManager())
}


