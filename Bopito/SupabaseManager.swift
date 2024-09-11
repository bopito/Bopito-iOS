//
//  SupabaseManager.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/5/24.
//

import Foundation
import Supabase


class SupabaseManager: ObservableObject {
    
    private var supabase: SupabaseClient
    
    @Published var isAuthenticated: Bool = false // Published property
    
    init() {
        supabase = SupabaseClient(
            supabaseURL: URL(string:"https://lqqhpvlxroqfqyfrpaio.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxxcWhwdmx4cm9xZnF5ZnJwYWlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU1NTk3ODEsImV4cCI6MjA0MTEzNTc4MX0.oH5JtLv2yefdNkpQ81PESC3d5iSPsWHhJUHzplosnvQ"
        )
        Task {
            await updateAuthenticationState() // Check auth status on init
        }
    }
    
    func updateAuthenticationState() async {
        do {
            _ = try await supabase.auth.user()
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        } catch {
            print("Error checking user status: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        }
    }
    
    func signInAnonymously() async {
        do {
            try await supabase.auth.signInAnonymously()
            print("Signed in anonymously.")
            // update isAuthenticated
            await updateAuthenticationState()
            // Store user data in the database
            let user = try await supabase.auth.user()
            await createUserInDatabase(userId: user.id.uuidString)
        } catch {
            print("Failed to sign in anonymously. Error: \(error.localizedDescription)")
        }
    }
    
    //
    // todo
    // in all functions check if user is authenticated and
    // check if user is allowed to perform that action (anon not allowed for some)
    // can change like and submission to get current user id in function here instead of view
    
    private func createUserInDatabase(userId: String) async {
        do {
            print("creating acccount in supabase")
            let randomUsername = "user\(Int.random(in: 1000...9999))"
            try await supabase
                .from("users")
                .upsert(
                    User(id: userId,
                         email: nil,
                         phone: nil,
                         username: randomUsername,
                         bio: nil,
                         profile_picture: "https://api.dicebear.com/9.x/bottts-neutral/jpeg?seed=\(RandomGeneratorTool.shared.randomAlphaNumericString(length: 5))",
                         name: nil,
                         followers_count: 0,
                         following_count: 0
                        )
                )
                .execute()
        } catch {
            print(error)
        }
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            print("Signed out successfully.")
            // update isAuthenticated
            await updateAuthenticationState()
        } catch {
            print("Failed to sign out. Error: \(error.localizedDescription)")
        }
    }
    
    //
    // Get User
    //
    func getCurrentUser() async -> User? {
        do {
            let currentUser = try await supabase.auth.session.user
            
            let user: User = try await supabase
                        .from("users")
                        .select()
                        .eq("id", value: currentUser.id)
                        .single() // need this if not doing [User] array
                        .execute()
                        .value
            //print(user.username)
            return user
        } catch {
            print("Failed to get current user. Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getUserByID(id: String) async -> User? {
        do {
            let user: User = try await supabase
                        .from("users")
                        .select()
                        .eq("id", value: id)
                        .single() // need this if not doing [User] array
                        .execute()
                        .value
            return user
        } catch {
            print("Failed to get user by ID. Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    //
    // Update User
    //
    func updateUser(user: User) async {
        do {
            try await supabase
                .from("users")
                .upsert(user)
                .execute()
        } catch {
            print("Failed to update User in Database. Error: \(error.localizedDescription)")
        }
    }
    
    
    //
    // Submit a Post/Reply (Submission)
    //
    func postSubmission(author_id: String, parent_id: String?, image: String?, text: String) async {
        let submission = Submission(
            id: UUID().uuidString,
            author_id: author_id,
            parent_id: parent_id,
            replies_count: 0,
            likes_count: 0,
            image: image,
            text: text,
            created_at: nil, //Date().formatted(.dateTime.year().month().day().hour().minute().second()),
            edited_at: nil
        )
        do {
            try await supabase
                .from("submissions")
                .insert(submission)
                .execute()
            // make sure can get submission to like it
            if let parent_id = parent_id {
                if let parentSubmission = await getSubmission(submissionID: parent_id) {
                    parentSubmission.replies_count += 1
                    try await supabase
                        .from("submissions")
                        .upsert(parentSubmission)
                        .execute()
                    print("Success - Submission liked!")
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    //
    // Get a Submission
    //
    func getSubmission(submissionID: String) async -> Submission? {
        do {
            let submission: Submission = try await supabase
                .from("submissions")
                .select()
                .eq("id", value: submissionID)
                .single()
                .execute()
                .value
            
            return submission
            
        } catch {
            print("Failed to get submission. Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    //
    // Like/Unlike a Submission
    //
    func isLiked(submissionID: String, userID: String) async -> Bool {
        do {
            try await supabase
                .from("likes")
                .select()
                .eq("user_id", value: userID)
                .eq("submission_id", value: submissionID)
                .single()
                .execute()
                .value
            return true
        } catch {
            return false
        }
    }
    
    func likeSubmission(submissionID: String, userID: String) async {
        let like = Like(
            id: UUID().uuidString,
            submission_id: submissionID,
            user_id: userID
        )
        do {
            print("Trying to like submission...")
            // make sure can get submission to like it
            if let submission = await getSubmission(submissionID: submissionID) {
                // update the submission with new like count
                submission.likes_count += 1
                try await supabase
                    .from("submissions")
                    .upsert(submission)
                    .execute()
                // add the like to "likes" table
                try await supabase
                    .from("likes")
                    .insert(like)
                    .execute()
                print("Success - Submission liked!")
            }
        } catch {
            print("Failure - Could not like submission ... Error: \(error.localizedDescription)")
        }
    }
    
    func unlikeSubmission(submissionID: String, userID: String) async {
        do {
            print("Trying to un-like submission...")
            // make sure can get submission to like it
            if let submission = await getSubmission(submissionID: submissionID) { 
                // update the submission with new like count
                submission.likes_count -= 1
                try await supabase
                    .from("submissions")
                    .upsert(submission)
                    .execute()
                try await supabase
                    .from("likes")
                    .delete()
                    .eq("user_id", value: userID)
                    .eq("submission_id", value: submissionID)
                    .single()
                    .execute()
                print("Success - Submission unliked!")
            }
        } catch {
            print("Failure - Could not unlike submission ... Error: \(error.localizedDescription)")
        }
    }
    
    
    //
    // Follow/Unfollow a User
    //
    func isFollowing(userID: String, followerID: String) async -> Bool {
        do {
            try await supabase
                .from("follows")
                .select()
                .eq("user_id", value: userID)
                .eq("follower_id", value: followerID)
                .single()
                .execute()
                .value
            return true
        } catch {
            return false
        }
    }

    func followUser(userID: String) async {
        if let currentUser = await getCurrentUser() {
            // create follow object
            let follow = Follow(
                id: UUID().uuidString,
                user_id: userID,
                follower_id: currentUser.id
            )
            do {
                if let user = await getUserByID(id: userID) {
                    if currentUser.id != user.id {
                        // increase user followers count
                        user.followers_count += 1
                        try await supabase
                            .from("users")
                            .upsert(user)
                            .execute()
                        
                        // increase currentUser following count
                        currentUser.following_count += 1
                        try await supabase
                            .from("users")
                            .upsert(currentUser)
                            .execute()
                        // add Follow to database
                        try await supabase
                            .from("follows")
                            .insert(follow)
                            .execute()
                        print("Success - User followed!")
                    }
                }
            } catch {
                print("Failure - Could not follow user ... Error: \(error.localizedDescription)")
            }
        }
    }
    
    func unfollowUser(userID: String) async {
        if let currentUser = await getCurrentUser() {
            if let user = await getUserByID(id: userID) {
                if currentUser.id != user.id {
                    do {
                        print("test")
                        // decrease counts
                        currentUser.following_count -= 1
                        try await supabase
                            .from("users")
                            .upsert(currentUser)
                            .execute()
                        user.followers_count -= 1
                        try await supabase
                            .from("users")
                            .upsert(user)
                            .execute()
                        try await supabase
                            .from("follows")
                            .delete()
                            .eq("user_id", value: userID)
                            .eq("follower_id", value: currentUser.id)
                            .single()
                            .execute()
                        print("Success - User unfollowed!")
                    } catch {
                        print("Failure - Could not unfollow user ... Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    
    
    //
    // Home Feed
    //
    func getRecentPosts() async -> [Submission]? {
        do {
//            let response = try await supabase
//                .from("submissions")
//                .select()
//                .execute()
            //print(response.string())
            
            let submissions: [Submission] = try await supabase
                .from("submissions")
                .select()
                .is("parent_id", value: nil)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return submissions
            
        } catch {
            print("Failed to get user by ID. Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getReplies(parentID: String) async -> [Submission]? {
        do {
            let submissions: [Submission] = try await supabase
                        .from("submissions")
                        .select()
                        .eq("parent_id", value: parentID)
                        .order("created_at", ascending: false)
                        .execute()
                        .value
            return submissions
            
        } catch {
            print("Failed to get replies for post with id:\(parentID) ... Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    //
    // Profile Feed
    //
    func getUserPosts(userID: String) async -> [Submission]? {
        do {
            let submissions: [Submission] = try await supabase
                        .from("submissions")
                        .select()
                        .eq("author_id", value: userID)
                        .order("created_at", ascending: false)
                        .execute()
                        .value
            return submissions
            
        } catch {
            print("Failed to get posts for user with id:\(userID) ... Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    
}
