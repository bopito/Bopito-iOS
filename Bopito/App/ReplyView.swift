//
//  ReplyView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/4/24.
//

//
//  PostView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct ReplyView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @State var account: Account?
    var reply: Reply
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
                    Text(reply.text)
                        .font(.body)
                        //.foregroundColor(.black)
                    
                    HStack {
                        // time
                        Text(reply.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.gray)
                        // date
                        Text(reply.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Reply button
                        Button(action: {
                            isShowingReplies = true
                        }) {
                            Text("\(reply.repliesCount)")
                                .font(.body)
                                .foregroundColor(.gray)
                            Image(systemName: "bubble.left.fill")
                                .font(.body)
                                .foregroundColor(.gray)
                        }.sheet(isPresented: $isShowingReplies, onDismiss: {
                            //
                        }) {
                            //PostRepliesView(post: post)
                        }
                        
                        
                        Spacer()
                        
                        // Like button
                        Button(action: {
                            Task {
                                do {
                                    try await authManager.incrementReplyLikesCount(reply: reply)
                                    reply.likesCount = try await authManager.getReplyLikesCount(reply: reply)
                                    isLiked = try await authManager.getReplyIsLiked(reply: reply)
                                } catch {
                                    print("Error updating or fetching like count: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            HStack {
                                
                                if isLiked {
                                    Text("\(reply.likesCount)")
                                        .font(.body)
                                        .foregroundColor(.red)
                                    Image(systemName: "heart.fill")
                                        .font(.body)
                                        .foregroundColor(.red)
                                } else {
                                    Text("\(reply.likesCount)")
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
                    account = await authManager.getAccountByID(accountId: reply.userID)
                    isLiked = try await authManager.getReplyIsLiked(reply: reply)
                } catch {
                    print("Error loading post data: \(error.localizedDescription)")
                }
            }
            
        }
        
    }
    
    
}


