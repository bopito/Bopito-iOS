//
//  PostView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct PostView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    var post: Submission
    
    @State var isLiked: Bool = false
    @State var username: String = ""
    
    @State var isViewingAccount = false
    @State var isShowingReplies = false
    
    @State private var isLoading: Bool = true
    @State private var error: Error?
    
    var body: some View {

            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.black, lineWidth: 1) // Gray outline
                        .background(Circle().fill(.black))
                        .frame(width: 70, height: 70) // Slightly larger than the image
                        //.shadow(radius: 3)
                    
//                    if let pictureURL = user?.profilePicture {
//                        AsyncImage(url: pictureURL) { image in
//                            image
//                                .resizable()
//                                .scaledToFill()
//                                .clipShape(Circle())
//                                .shadow(radius: 5)
//                        } placeholder: {
//                            ProgressView()
//                        }
//                        .frame(width: 40, height: 40)
//                    } else {
//                        ProgressView()
//                            .frame(width: 40, height: 40)
//                    }
                }
                
                
                VStack(alignment: .leading, spacing: 8) {
                    // username button
                    Button(action: {
                        isViewingAccount = true
                    }) {
                        Text("@\(username)")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }.sheet(isPresented: $isViewingAccount, onDismiss: {
                        //
                    }) {
                        ProfileView()
                    }
            
                    // body text
                    Text(post.text)
                        .font(.body)
                    
                    HStack {
                        Text("timestamp")
                            .font(.caption)
                            .foregroundColor(.gray)
                        // timestamp
//                        Text(post.timestamp, style: .time)
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                        // date
//                        Text(post.timestamp, style: .date)
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
                            
                        }) {
                            //PostRepliesView(post: post)
                        }
                        
                        
                        Spacer()
                        
                        // Like button
                        Button(action: {
                            Task {
                                do {
                                    
//                                    // Increment like count and fetch updated count
//                                    try await supabaseManager.incrementPostLikesCount(post: post)
//                                    post.likesCount = try await supabaseManager.getPostLikesCount(post: post)
//                                    isLiked = try await supabaseManager.getPostIsLiked(post: post)
                                } catch {
                                    print("Error updating or fetching like count: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            HStack {
                                
                                if isLiked {
                                    Text("?")
                                        .font(.body)
                                        .foregroundColor(.red)
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
//            .background(
//                .white
//                .opacity(0.02) // Set background color opacity to 0.1
//            )
            //.cornerRadius(8)
            .onAppear() {
                Task{
                    let user = await supabaseManager.getUserByID(id: post.author_id)
                    if let user = user {
                        username = user.username
                    }
                    
                }
            }
            

                
    }
    
  
    
    
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(
            post:
                Submission(id: "1", author_id: "1", parent_id: nil, replies_count: 1, likes_count: 2, image: "none", text: "hello")
            )
            .environmentObject(SupabaseManager())
    }
}
