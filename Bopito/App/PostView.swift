//
//  PostView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct PostView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @State var account: Account?
    var post: Post
    @State var isLiked: Bool = false
    
    @State var isViewingAccount = false
    @State var isShowingReplies = false
    
    var body: some View {
        VStack {
            
            
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.black, lineWidth: 1) // Gray outline
                        .background(Circle().fill(account?.toColor() ?? .black))
                        .frame(width: 70, height: 70) // Slightly larger than the image
                        //.shadow(radius: 3)
                    
                    if let pictureURL = account?.picture {
                        AsyncImage(url: pictureURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                    } else {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                }
                
                
                VStack(alignment: .leading, spacing: 8) {
                    // username button
                    Button(action: {
                        isViewingAccount = true
                    }) {
                        Text("@\(account?.username ?? "Unknown")")
                            .font(.headline)
                            .foregroundColor(account?.toColor() ?? .gray)
                    }.sheet(isPresented: $isViewingAccount, onDismiss: {
                        //
                    }) {
                        AccountView()
                    }
            
                    // body text
                    Text(post.text)
                        .font(.body)
                        //.foregroundColor(.black)
                    
                    HStack {
                        // time
                        Text(post.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.gray)
                        // date
                        Text(post.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Reply button
                        Button(action: {
                            isShowingReplies = true
                        }) {
                            Text("\(post.repliesCount)")
                                .font(.body)
                                .foregroundColor(.gray)
                            Image(systemName: "bubble.left.fill")
                                .font(.body)
                                .foregroundColor(.gray)
                        }.sheet(isPresented: $isShowingReplies, onDismiss: {
                            
                        }) {
                            PostRepliesView(post: post)
                        }
                        
                        
                        Spacer()
                        
                        // Like button
                        Button(action: {
                            Task {
                                do {
                                    
                                    // Increment like count and fetch updated count
                                    try await authManager.incrementPostLikesCount(post: post)
                                    post.likesCount = try await authManager.getPostLikesCount(post: post)
                                    isLiked = try await authManager.getPostIsLiked(post: post)
                                } catch {
                                    print("Error updating or fetching like count: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            HStack {
                                
                                if isLiked {
                                    Text("\(post.likesCount)")
                                        .font(.body)
                                        .foregroundColor(.red)
                                    Image(systemName: "heart.fill")
                                        .font(.body)
                                        .foregroundColor(.red)
                                } else {
                                    Text("\(post.likesCount)")
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
            .background(
                (account?.toColor() ?? .white)
                    .opacity(0.2) // Set background color opacity to 0.1
            )
            //.cornerRadius(8)
            .task {
                do {
                    account = await authManager.getAccountByID(accountId: post.userID)
                    isLiked = try await authManager.getPostIsLiked(post: post)
                } catch {
                    print("Error loading post data: \(error.localizedDescription)")
                }
            }
            
//            VStack(spacing: 1) {
//               load replies
//            }
        }
        
    }
    
    
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(
            post: Post(
                uuid: "sample-uuid",
                userID: "hans",
                timestamp: Date(),
                repliesIDs: [],
                repliesCount: 0,
                likesCount: 5,
                likers: ["user1", "user2"],
                text: "This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test! This is a test!"
            )
        )
        .environmentObject(AuthManager())
    }
}
