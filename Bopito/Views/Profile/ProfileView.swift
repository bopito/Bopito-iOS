import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var posts: [Submission]?
    @State var user: User?
    @State var currentUser: User?
    @State var openedFromProfileTab: Bool
    
    @State var isCurrentUsersProfile: Bool = false
    @State var isFollowing: Bool = false
    @State var isBlocked: Bool = false
    
    @State var isViewingEditProfile: Bool = false
    @State var isViewingSettings: Bool = false
    @State var isViewingFollows: Bool = false
    @State var followsTab: Int = 0

    var body: some View {
        ZStack {
            VStack {
                HStack (alignment:.top) {
                    Spacer()
                    Menu {
                        if let user = user, let currentUser = currentUser {
                            if user.id == currentUser.id {
                                Button(action: {
                                    Task {
                                        print("need to move signout/delete to function")
                                        await supabaseManager.signOut()
                                    }
                                }) {
                                    Label("Delete Account", systemImage: "trash")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                                Button(action: {
                                    Task {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            await UIApplication.shared.open(url)
                                        }
                                    }
                                }) {
                                    Label("Notifications Settings", systemImage: "bell")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                                
                            } else {
                                Button(action: {
                                    Task {
                                        if isBlocked {
                                            await unblockUser()
                                        } else {
                                            await blockUser()
                                        }
                                        await load()
                                    }
                                }) {
                                    if isBlocked {
                                        Label("Unblock \(user.username)", systemImage: "exclamationmark.triangle")
                                            .foregroundColor(.red)
                                            .font(.title2)
                                    } else {
                                        Label("Block \(user.username)", systemImage: "xmark.square")
                                            .foregroundColor(.red)
                                            .font(.title2)
                                    }
                                }
                                
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .padding(.horizontal, 10)
                            .padding(.vertical, (openedFromProfileTab ? 20 : 45))
                            .background()
                    }
                    .contentShape(Rectangle()) // Make the entire area tappable
                }
                Spacer()
            }
            
            VStack (spacing: 0){
                
                if let user = user {
                    //username
                    
                    if openedFromProfileTab {
                        Text("\(user.name ?? user.username)'s Profile")
                            .font(.title2)
                            .padding(.top, 10)
                    } else {
                        Capsule()
                            .fill(Color.secondary)
                            .opacity(0.5)
                            .frame(width: 50, height: 5)
                            .padding(.top, 20)
                        Text("\(user.name ?? user.username)'s Profile")
                            .font(.title2)
                            .padding(.top, 10)
                    }
                    
                    
                    
                }
                
                
                
                if let user = user {
                    // profile picture
                    ProfilePictureView(profilePictureURL: user.profile_picture)
                        .frame(width: 85, height: 85)
                        .padding(.vertical, 10)
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
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)  // Adjust this value for more or less rounded corners
                        }
                        .padding(.bottom, 10)
                        
                    } else {
                        if !isBlocked {
                            FollowButtonView(user: user, currentUser: currentUser)
                                .padding(.bottom, 10)
                        } else {
                            Button(action: {
                                Task {
                                    await unblockUser()
                                    await load()
                                }
                            }) {
                                Text("Unblock")
                                    .font(.subheadline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)  // Adjust this value for more or less rounded corners
                            }
                            .padding(.bottom, 10)
                        }
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
    }
    
    
    func load() async {
        // Load account
        if user == nil {
            // show currentUser's account if not instantiated with another User
            user = await supabaseManager.getCurrentUser()
            
            currentUser = await supabaseManager.getCurrentUser()
            print("causes: Failed to get current user. Error: cancelled")
            
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
                    
                    // check if blocked
                    isBlocked = await supabaseManager.isUserBlocked(userID: user.id)
                }
            }
        }
        
        // Load user posts
        if let user = user {
            posts = await supabaseManager.getUserSubmissions(userID: user.id)
        }
        
    }
    
    
    func blockUser() async {
        if let user = user {
            await supabaseManager.blockUser(userID: user.id)
        }
    }
    
    func unblockUser() async {
        if let user = user {
            await supabaseManager.unblockUser(userID: user.id)
        }
    }
    
}

#Preview {
    ProfileView(openedFromProfileTab: true)
        .environmentObject(SupabaseManager())
}


