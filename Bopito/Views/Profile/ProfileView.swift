import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var submissions: [Submission]?
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
    
    @State var profilePictureRefreshID: UUID = UUID()

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
                                    Label("Abandon Account", systemImage: "trash")
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
                        Image(systemName: "gear")
                            .padding(.horizontal, 10)
                            .padding(.vertical, (openedFromProfileTab ? 11 : 36))
                            .background()
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle()) // Make the entire area tappable
                }
                Spacer()
            }
            
            VStack (spacing: 0){
                if let user = user {
                    if !openedFromProfileTab {
                        Capsule()
                            .fill(Color.secondary)
                            .opacity(0.5)
                            .frame(width: 50, height: 5)
                            .padding(.top, 20)
                    }
                    if user.name != "" {
                        Text("\(user.name)'s Profile")
                            .font(.title2)
                            .padding(.top, 10)
                    } else {
                        Text("\(user.username)'s Profile")
                            .font(.title2)
                            .padding(.top, 10)
                    }
                }
                
                Divider()
                    .padding(.top, 10)
                
                if let user = user {
                    // profile picture
                    ProfilePictureView(profilePictureURL: user.profile_picture)
                        .frame(width: 100, height: 100)
                        .padding(.vertical, 10)
                        .id(profilePictureRefreshID)
                        
                    //username
                    Text("@\(user.username)")
                        .font(.callout)
                        .padding(.bottom, 10)
                    
                    // bio
                    if let bio = user.bio, !bio.isEmpty {
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
                    
                    // Join Date
                    if let joinDate =  user.created_at {
                        if let date =  DateTimeTool.shared.getSwiftDate(supabaseTimestamp: joinDate) {
                            Text("Joined \(date, format: .dateTime.month(.wide).year())")
                                .font(.footnote)
                                .padding(.bottom, 10)
                        }
                    }
                    
                    Divider()
                    
                } else {
                    ProgressView()
                }
                
                
                
                if var submissions = submissions {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(submissions) { submission in
                                SubmissionView(submission: submission, onDelete: { deletedPostID in
                                    submissions.removeAll { $0.id == deletedPostID }
                                })
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            
                            
                        }
                        .padding(.bottom, 40)
                        
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        //await load()
                    }
                } else {
                    Spacer()
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
                    profilePictureRefreshID = UUID()
                }
            }) {
                EditProfileView()
            }
            .sheet(isPresented: $isViewingFollows) {
                FollowsTabView(selectedTab: followsTab, user: user)
            }
            .onAppear {
                Task {
                    await load()
                }
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
       
        await loadSubmissions()
    }
    
    func loadSubmissions() async {
        guard let user else {
            return
        }
        submissions = await supabaseManager.getUserSubmissions(userID: user.id)
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


