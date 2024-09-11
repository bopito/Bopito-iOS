import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    
    @State var posts: [Submission]?
    @State var user: User?
    
    @State var isCurrentUsersProfile: Bool = false
    @State var isFollowing: Bool = false
    
    @State var isViewingEditProfile: Bool = false
    @State var isViewingSettings: Bool = false

    
    var body: some View {
        VStack (spacing: 0){
            HStack {
                Spacer()
                Button(action: {
                    isViewingSettings = true
                }) {
                    Image(systemName :"gearshape")
                        .font(.system(size: 30))
                        .foregroundColor(.black)
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
                .sheet(isPresented: $isViewingSettings, onDismiss:  {
                    //
                }) {
                    SettingsView()
                }
            }
             
             
            if let user = user {
                //username
                Text("\(user.name ?? user.username)")
                    .font(.title2)
                    .padding(.bottom, 10)
                // profile picture
                ProfilePictureView(profilePictureURL: user.profile_picture)
                    .frame(width: 85, height: 85)
                    .padding(.bottom, 10)
                //username
                Text("@\(user.username)")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                // bio
                Text("\(user.bio)")
                    .font(.callout)
                    .padding(.bottom, 10)
                
                // followers/following
                HStack {
                    VStack {
                        Text("\(user.followers_count)")
                            .font(.title3)
                            .bold()
                        Text("Followers")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    Divider()
                        .frame(height: 35)
                        .padding(.horizontal, 10)
                    VStack {
                        Text("\(user.following_count)")
                            .font(.title3)
                            .bold()
                        Text("Following")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }.padding(.bottom, 10)
               
                if isCurrentUsersProfile {
                    Button(action: {
                        Task {
                           isViewingEditProfile = true
                        }
                    }) {
                        Text("Edit Profile")
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Color(uiColor: .systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(10)  // Adjust this value for more or less rounded corners
                    }
                    .padding(.bottom, 10)
                    .sheet(isPresented: $isViewingEditProfile, onDismiss:  {
                        //
                    }) {
                        EditProfileView()
                    }
                } else {
                    Button(action: {
                        Task {
                            await followPressed()
                        }
                    }) {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(isFollowing ? Color.blue : Color(uiColor: .systemGray5))
                            .foregroundColor(isFollowing ? .white : .primary)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 10)
                }
                
                
                Divider()
                
            } else {
                ProgressView()
            }
            
            // Buttons in an HStack
//            HStack(spacing: 1) {
//                Button(action: {
//                    // Action for the "Posts" button
//                    print("Posts button tapped")
//                }) {
//                    Text("Posts")
//                        .font(.title3)
//                        .foregroundColor(.primary)
//                        .frame(maxWidth: .infinity) // Make the button take up all available width
//                        .padding()
//                        .background(Color.gray)
//                }
//                Button(action: {
//                    // Action for the "Comments" button
//                    print("Comments button tapped")
//                }) {
//                    Text("Comments")
//                        .font(.title3)
//                        .foregroundColor(.primary)
//                        .frame(maxWidth: .infinity) // Make the button take up all available width
//                        .padding()
//                }
//                
//                Button(action: {
//                    // Action for the "Likes" button
//                    print("Likes button tapped")
//                }) {
//                    Text("Likes")
//                        .font(.title3)
//                        .foregroundColor(.primary)
//                        .frame(maxWidth: .infinity) // Make the button take up all available width
//                        .padding()
//                }
//            }
//            .frame(width: UIScreen.main.bounds.width) // Ensure HStack takes up full width
  
            if let posts = posts {
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
            } else {
                Spacer()
            }
        }
        .onAppear {
            Task {
                await load()
            }
        }
    }
    
    
    func load() async {
        // Load account
        if user == nil {
            // show currentUser's account if not instantiated with another User
            user = await supabaseManager.getCurrentUser()
            isCurrentUsersProfile = true
        } else {
            // get the current info for the account being viewed
            if let userAccount = user {
                user = await supabaseManager.getUserByID(id: userAccount.id)
                // check if following to update state
                if let currentUser = await supabaseManager.getCurrentUser() {
                    isFollowing = await supabaseManager.isFollowing(userID: userAccount.id, followerID: currentUser.id)
                    if userAccount.id == currentUser.id {
                        isCurrentUsersProfile = true
                    } else {
                        isCurrentUsersProfile = false
                    }
                }
            }
        }
        
        // Load user posts
        if let user = user {
            posts = await supabaseManager.getUserPosts(userID: user.id)
        }
    }
    
    func followPressed() async {
        // get current user
        if let userToFollow = user {
            if let currentUser = await supabaseManager.getCurrentUser() {
                // update @State for isLiked
                isFollowing = await supabaseManager.isFollowing(userID: userToFollow.id, followerID: currentUser.id)
                // check if liked
                if !isFollowing {
                    // follow
                    await supabaseManager.followUser(userID: userToFollow.id)
                } else {
                    // otherwise unfollow
                    await supabaseManager.unfollowUser(userID: userToFollow.id)
                }
                // update @State for isLiked
                isFollowing = await supabaseManager.isFollowing(userID: userToFollow.id, followerID: currentUser.id)
                
                user = await supabaseManager.getUserByID(id: userToFollow.id)
            }
        }
        
    }
}

#Preview {
    ProfileView()
        .environmentObject(SupabaseManager())
}


