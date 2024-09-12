//
//  PostView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct PostView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var post: Submission
    
    @State var user: User?
    @State var currentUser: User?
    
    @State var time_since: String?
    @State var isLiked: Bool = false
    
    @State var isViewingAccount = false
    @State var isShowingReplies = false
    @State var isShowingDeleteAlert = false
    @State var isShowingReportAlert = false
    

    
    var body: some View {

            HStack(alignment: .top) {
                
                if let user = user {
                    ProfilePictureView(profilePictureURL: user.profile_picture)
                        .frame(width: 60, height: 60)
                        .padding(.top, 5)
                } else {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // username button
                    HStack {
                        if let user = user {
                            Button(action: {
                                isViewingAccount = true
                            }) {
                                Text("@\(user.username)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }.sheet(isPresented: $isViewingAccount, onDismiss: {
                                //
                            }) {
                                ProfileView(user: user)
                            }
                        } else {
                            Text(" ")
                        }
                        
                        Spacer()
                        
                        if let currentUser = currentUser, let user = user {
                            // if post was made by currentUser:
                            if currentUser.id == user.id {
                                // show delete button
                                Button(action: {
                                    isShowingDeleteAlert = true
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }.alert(isPresented: $isShowingDeleteAlert) {
                                    Alert(
                                        title: Text("Are you sure?"),
                                        message: Text("This action can not be undone"),
                                        primaryButton: .destructive(Text("Delete")) {
                                            Task {
                                                await deleteSubmission()
                                            }
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                            } else {
                                // show report button
                                Button(action: {
                                    isShowingReportAlert = true
                                }) {
                                    Image(systemName: "xmark.shield")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }.alert(isPresented: $isShowingReportAlert) {
                                    Alert(
                                        title: Text("Are you sure?"),
                                        message: Text("Be aware that making a fraudulent report will negatively affect your account status"),
                                        primaryButton: .destructive(Text("Report")) {
                                            Task {
                                                await reportSubmission()
                                            }
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                            }
                        }
                        
                    }
            
                    // body text
                    Text(post.text)
                        .font(.body)
                    
                    HStack {
                        if let time_since = time_since {
                            Text(time_since)
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                                Text("")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                        }
//                        Text(post.created_at, style: .time)
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                        // date
//                        Text(post.created_at, style: .date)
//                            .font(.caption)
//                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Reply button
                        Button(action: {
                            isShowingReplies = true
                        }) {
                            Text("\(post.replies_count)")
                                .font(.body)
                                .foregroundColor(.gray)
                            Image(systemName: "bubble.left.fill")
                                .font(.body)
                                .foregroundColor(.gray)
                        }.sheet(isPresented: $isShowingReplies, onDismiss: {
                            Task {
                                await reloadSubmission()
                            }
                        }) {
                            PostRepliesView(post: post)
                        }
                        
                        
                        Spacer()
                        
                        // Like button
                        Button(action: {
                            Task {
                                await likePressed()
                            }
                        }) {
                            HStack {
                                
                                if isLiked {
                                    Text("\(post.likes_count)")
                                        .font(.body)
                                        .foregroundColor(.red)
                                    Image(systemName: "heart.fill")
                                        .font(.body)
                                        .foregroundColor(.red)
                                } else {
                                    
                                    Text("\(post.likes_count)")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                    Image(systemName: "heart.fill")
                                        .font(.body)
                                        .foregroundColor(Color(uiColor: .lightGray))
                                }
                                
                            }
                        }
                    }
                }
            }
            .padding(8)
            //.background(.blue)
            .contentShape(Rectangle()) // Ensures the entire area responds to taps
            .onTapGesture {
                        isShowingReplies = true
                    }
                    .sheet(isPresented: $isShowingReplies) {
                        PostRepliesView(post: post)
                    }
            .onAppear() {
                Task{
                   await loadData()
                }
            }
            

                
    }
    
    func loadData() async {
        // load user who made the post
        user = await supabaseManager.getUserByID(id: post.author_id)
        // get current user to see if they've liked it
        currentUser = await supabaseManager.getCurrentUser()
        if let currentUser = currentUser {
            isLiked = await supabaseManager.isLiked(submissionID: post.id, userID: currentUser.id)
        }
        // set time_since based on post created_at timestamp
        if let created_at = post.created_at {
            if let datetime = DateTimeTool.shared.getSwiftDate(supabaseTimestamp: created_at) {
                time_since = DateTimeTool.shared.timeAgo(from: datetime)
            } else {
                
            }
        }
    }
    
    func reloadSubmission() async {
        if let updatedPost = await supabaseManager.getSubmission(submissionID: post.id) {
            post = updatedPost
            print(post.likes_count)
        }
        if let currentUser = currentUser {
            // update @State for isLiked
            isLiked = await supabaseManager.isLiked(submissionID: post.id, userID: currentUser.id)
        }
        
    }
    
    func likePressed() async {
        // get current user
        if let currentUser = currentUser {
            // update @State for isLiked
            isLiked = await supabaseManager.isLiked(submissionID: post.id, userID: currentUser.id)
            // check if liked
            if !isLiked {
                // like it if not
                await supabaseManager.likeSubmission(submissionID: post.id, userID: currentUser.id)
            } else {
                // otherwise unlike it
                await supabaseManager.unlikeSubmission(submissionID: post.id, userID: currentUser.id)
            }
            // update @State for isLiked
            isLiked = await supabaseManager.isLiked(submissionID: post.id, userID: currentUser.id)
            await reloadSubmission()
        }
    }
    
    func deleteSubmission() async {
        print("deleted!")
    }
    
    func reportSubmission() async {
        print("reported!")
    }
    
    
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(
            post:
                Submission(id: "1",
                           author_id: "1",
                           parent_id: nil,
                           replies_count: 1,
                           likes_count: 2,
                           image: "none",
                           text: "hello",
                           created_at: Date().formatted(),
                           edited_at: Date().formatted()
                           )
            )
            .environmentObject(SupabaseManager())
    }
}
