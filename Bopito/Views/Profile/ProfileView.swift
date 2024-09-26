import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    
    @State var posts: [Submission]?
    @State var user: User?
    @State var currentUser: User?
    
    @State var isCurrentUsersProfile: Bool = false
    @State var isFollowing: Bool = false
    
    @State var isViewingEditProfile: Bool = false
    @State var isViewingSettings: Bool = false
    @State var isViewingFollows: Bool = false
    @State var followsTab: Int = 0

    
    var body: some View {
        VStack (spacing: 0){
            HStack {
                Spacer()
                Button(action: {
                    isViewingSettings = true
                }) {
                    Image(systemName :"gearshape")
                        .font(.system(size: 30))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
                
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
                if let bio = user.bio {
                    Text(bio)
                        .font(.callout)
                        .padding(.bottom, 10)
                }
                
                
                // followers/following
                HStack {
                    Button(action: {
                        // Action to navigate to FollowersView
                        followsTab = 0
                        isViewingFollows = true
                    }) {
                        VStack {
                            Text("\(user.followers_count)")
                                .font(.title3)
                                .bold()
                            Text("Followers")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    
                    Divider()
                        .frame(height: 35)
                        .padding(.horizontal, 10)
                    
                    Button(action: {
                        // Action to navigate to FollowersView
                        followsTab = 1
                        isViewingFollows = true
                    }) {
                        VStack {
                            Text("\(user.following_count)")
                                .font(.title3)
                                .bold()
                            Text("Following")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    
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
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)  // Adjust this value for more or less rounded corners
                    }
                    .padding(.bottom, 10)
                    
                } else {
                    FollowButtonView(user: user, currentUser: currentUser)
                        .padding(.bottom, 10)
                }
                
                
                Divider()
                
            } else {
                ProgressView()
            }
            
            
  
            if let posts = posts {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(posts) { post in
                            SubmissionView(submission: post)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                        }
                        
                            
                    }
                    .padding(.bottom, 40)
                    
                }.scrollIndicators(.hidden)
            } else {
                Spacer()
            }
        }
        .onAppear {
            Task {
                await load()
            }
        }
        .sheet(isPresented: $isViewingSettings, onDismiss:  {
            //
        }) {
            SettingsView()
        }
        .sheet(isPresented: $isViewingEditProfile, onDismiss:  {
            Task {
                await load()
            }
        }) {
            EditProfileView()
        }
        .sheet(isPresented: $isViewingFollows) {
            FollowsTabView(selectedTab: followsTab, user: user)
        }
    }
    
    
    func load() async {
        // Load account
        if user == nil {
            // show currentUser's account if not instantiated with another User
            user = await supabaseManager.getCurrentUser()
            currentUser = await supabaseManager.getCurrentUser()
            isCurrentUsersProfile = true
        } else {
            currentUser = await supabaseManager.getCurrentUser()
            
            if let reloadUser = user {
                user = await supabaseManager.getUserByID(id: reloadUser.id)
            }
            
            if let user = user, let currentUser = currentUser {
                if user.id == currentUser.id {
                    isCurrentUsersProfile = true
                } else {
                    isCurrentUsersProfile = false
                }
            }
            
        }
        
        // Load user posts
        if let user = user {
            posts = await supabaseManager.getUserPosts(userID: user.id)
        }
    }
    
    
}

#Preview {
    ProfileView()
        .environmentObject(SupabaseManager())
}


