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
    
    func appVersionCurrent() async -> Bool {
        // Get the current version of the app from the Info.plist
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            do {
                // Fetch the latest version from Supabase
                let latestVersion: Version = try await supabase
                    .from("version")
                    .select()
                    .single() // need this if not doing [User] array
                    .execute()
                    .value
                
                print(latestVersion.version)
                
                if currentVersion == latestVersion.version {
                    return true
                } else {
                    return false
                }
            } catch {
                print("Error checking version: \(error.localizedDescription)")
            }
        }
        return false
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
            let randomUsername = "user\(Int.random(in: 100000...999999))"
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
                         following_count: 0,
                         verified: false
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
    // Notifications
    //
    func createNotification(recipitentID: String, senderID: String, type: String, submissionID: String?, message: String) async {
        let notification = Notification(id: UUID().uuidString,
                                        recipient_id: recipitentID,
                                        sender_id: senderID,
                                        type: type,
                                        submission_id: submissionID,
                                        is_read: false,
                                        message: message
        )
        print(notification.id)
        do {
            try await supabase
                .from("notifications")
                .insert(notification)
                .execute()
        } catch {
            print("Failed to insert Notification. Error: \(error.localizedDescription)")
        }
    }
    
    func getNotifications() async -> [Notification]? {
        do {
            let currentUser = try await supabase.auth.session.user
            let notifications: [Notification] = try await supabase
                .from("notifications")
                .select()
                .eq("recipient_id", value: currentUser.id)
                .order("created_at", ascending: false)
                .execute()
                .value
            return notifications
        } catch {
            print("Failure - Could not get notifications ... Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    //
    // User
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
    // Submissions
    //
    func postSubmission(author_id: String, parent_id: String?, image: String?, text: String) async {
        let submission = Submission(
            id: UUID().uuidString,
            author_id: author_id,
            parent_id: parent_id,
            image: image,
            text: text,
            created_at: nil, //database can create this value
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
                    try await supabase
                        .from("submissions")
                        .upsert(parentSubmission)
                        .execute()
                    print("Success - Submission posted!")
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getAllSubmissions(feedFilter: String) async -> [Submission]? {
        do {
            // let type = // need to check if
            var order = "created_at"
            if feedFilter == "New" {
                order = "created_at"
            } else if feedFilter == "Hot" {
                order = "created_at"
            }
            else if feedFilter == "Top" {
                
            }
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
    
    func getUserSubmissions(userID: String) async -> [Submission]? {
        do {
            let submissions: [Submission] = try await supabase
                        .from("submissions")
                        .select()
                        .is("parent_id", value: nil)
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
    
    func deleteSubmission(submissionID: String) async {
        do {
            // Fetch the submission to check if it has a parent
            if let submissionToDelete = await getSubmission(submissionID: submissionID) {
                // If the submission has a parent, reduce the replies_count on it
                if let parentID = submissionToDelete.parent_id {
                    if let parentSubmission = await getSubmission(submissionID: parentID) {
                        // Update the parent submission
                        try await supabase
                            .from("submissions")
                            .upsert(parentSubmission)
                            .execute()
                    }
                }
                // Now delete the submission
                try await supabase
                    .from("submissions")
                    .delete()
                    .eq("id", value: submissionID)
                    .execute()
                
                print("Submission deleted successfully!")
            } else {
                print("Submission not found.")
            }
        } catch {
            print("Failed to delete submission. Error: \(error)")
        }
    }
    
    func getCommentsCount(parentID: String) async -> Int {
        do {
            let response = try await supabase
                .from("submissions")
                .select(count: .exact)
                .eq("parent_id", value: parentID)
                .execute()
            if let count = response.count {
                return count
            } else {
                return 0
            }
        } catch {
            return 0
        }
    }

    
    //
    // Voting
    //
    func castVote(submissionID: String, likerID: String, receiverID: String, value: Int) async {
        do {
            let vote: Like = try await supabase
                .from("likes")
                .select()
                .eq("liker_id", value: likerID)
                .eq("submission_id", value: submissionID)
                .single()
                .execute()
                .value
            print("old vote value: \(vote.value)")
            vote.value = value
            print("new vote value: \(vote.value)")
            do {
                try await supabase
                    .from("likes")
                    .upsert(vote)
                    .execute()
            } catch {
                print("Failed to replace Vote in DB: \(error.localizedDescription)")
            }
        } catch {
            print("Vote not found: \(error.localizedDescription)")
            print("Creating new Vote")
            let vote = Like(
                id: UUID().uuidString,
                submission_id: submissionID,
                liker_id: likerID,
                receiver_id: receiverID,
                value: value)
            print("creating new vote with: \(vote.value)")
            do {
                try await supabase
                    .from("likes")
                    .upsert(vote)
                    .execute()
            } catch {
                print("Failed to add Vote to DB: \(error.localizedDescription)")
            }
            
        }
    }
 
    func getUserVote(submissionID: String, userID: String) async -> Int {
        do {
            let vote: Like = try await supabase
                .from("likes")
                .select()
                .eq("submission_id", value: submissionID)
                .eq("liker_id", value: userID)
                .single()
                .execute()
                .value
            return vote.value
        } catch {
            return 0
        }
    }
    
    func getSubmissionVotesCount(submissionID: String, value: Int) async -> Int {
        do {
            let response = try await supabase
                .from("likes")
                .select(count: .exact)
                .eq("submission_id", value: submissionID)
                .eq("value", value: value)
                .execute()
            if let count = response.count {
                return count
            } else {
                return 0
            }
        } catch {
            return 0
        }
    }
    
    func getSubmissionVotes(parentID: String) async -> [Like]? {
        do {
            let votes: [Like] = try await supabase
                .from("likes")
                .select()
                .eq("submission_id", value: parentID)
                .neq("value", value: 0)
                .order("created_at", ascending: false)
                .execute()
                .value
            return votes
        } catch {
            print("Failure - Could not get votes ... Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    //
    // Boosts
    //
    func applyBoost(price: Int, time: Int, value:Int, category: String, submissionID: String, userID: String) async {
        // Add the time (in seconds) to the current date
        let expirationDate = DateTimeTool.shared.convertSwiftDateToSupabaseString(
            date: Date().addingTimeInterval(TimeInterval(time))
        )
        let boost: Boost = Boost(
            id: UUID().uuidString,
            expires_at: expirationDate,
            value: value,
            submission_id: submissionID,
            user_id: userID,
            live: true,
            price: price,
            time: time,
            category: category
        )
        do {
            print("NOTE - Maybe change to UPSERT so Boost can't be abused by people with more money?")
            try await supabase
                .from("boosts")
                .insert(boost)
                .execute()
        } catch {
            print("Failed to add Boost: \(error.localizedDescription)")
        }
    }
    
    func getBoosts(submissionID: String) async -> [Boost]? {
        do {
            let boosts: [Boost] = try await supabase
                .from("boosts")
                .select()
                .eq("submission_id", value: submissionID)
                .order("created_at", ascending: false)
                .execute()
                .value
            return boosts
        } catch {
            print("Failure - Could not get boosts ... Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getBoostsCount(submissionID: String) async -> Int {
        do {
            let response = try await supabase
                .from("boosts")
                .select(count: .exact)
                .eq("submission_id", value: submissionID)
                .eq("live", value: true)
                .execute()
            if let count = response.count {
                return count
            } else {
                return 0
            }
        } catch {
            return 0
        }
    }
    
    
    //
    // Follow/Unfollow
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
    
    func getFollowers(userID: String) async -> [Follow]? {
        do {
            let followers: [Follow] = try await supabase
                .from("follows")
                .select()
                .eq("user_id", value: userID)
                .order("created_at", ascending: false)
                .execute()
                .value
            return followers
        } catch {
            print("Failure - Could not get followers ... Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getFollowing(userID: String) async -> [Follow]? {
        do {
            let following: [Follow] = try await supabase
                .from("follows")
                .select()
                .eq("follower_id", value: userID)
                .order("created_at", ascending: false)
                .execute()
                .value
            return following
        } catch {
            print("Failure - Could not get following ... Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    
    
    
    
}
