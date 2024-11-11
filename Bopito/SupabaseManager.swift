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
    
    @Published var boosts: [Boost] = []
    @Published var currentRealtimeSubmissionID: String?
    
    init() {
        supabase = SupabaseClient(
            supabaseURL: URL(string:"https://lqqhpvlxroqfqyfrpaio.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxxcWhwdmx4cm9xZnF5ZnJwYWlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU1NTk3ODEsImV4cCI6MjA0MTEzNTc4MX0.oH5JtLv2yefdNkpQ81PESC3d5iSPsWHhJUHzplosnvQ"
        )
        Task {
            await updateAuthenticationState() // Check auth status on init
            await subscribeToBoostsRealtime()
            
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
                
                if currentVersion >= latestVersion.version {
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
            print("Error in supabase.updateAuthenticationState(): \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        }
    }
    
    func addFirebaseCloudMessengerToken(token: String) async {
        do {
            // Assuming the user is already authenticated and you have their ID
            let currentUser = try await supabase.auth.session.user
            
            if let user = await getCurrentUser() {
                print(currentUser.id, user.id)
            }

            // Update the user's FCM token
            try await supabase
                .from("users")
                .update(["fcm_token": token]) // Update the FCM token
                .eq("id", value: currentUser.id) // Match by user ID
                .execute()

            print("FCM token updated successfully.")

        } catch {
            print("Error updating FCM token: \(error)")
        }
    }
    
    func signInAnonymously() async {
        do {
            try await supabase.auth.signInAnonymously()
            print("Signed in anonymously.")
            // Store user data in the database
            let user = try await supabase.auth.user()
            await createUserInDatabase(userId: user.id.uuidString)
            // update isAuthenticated
            await updateAuthenticationState()
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
                    User(
                        id: userId,
                        username: randomUsername,
                        bio: nil,
                        profile_picture: "https://api.dicebear.com/9.x/bottts-neutral/jpeg?seed=\(RandomGeneratorTool.shared.randomAlphaNumericString(length: 5))",
                        name: randomUsername,
                        followers_count: 0,
                        following_count: 0,
                        verified: false,
                        balance: 1000,
                        fcm_token: nil
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
    // Block/Unblock Users
    //
    func blockUser(userID: String) async {
        if let currentUser = await getCurrentUser() {
            let block = Block(
                id: UUID().uuidString,
                created_at: nil,
                blocker_id: currentUser.id,
                blocked_id: userID)
            do {
                try await supabase
                    .from("blocks")
                    .upsert(block)
                    .execute()
                print("Blocked '\(userID)'")
            } catch {
                print("Failed to block '\(userID)' ... Error: \(error.localizedDescription)")
            }
        }
    }
    
    func unblockUser(userID: String) async {
        if let currentUser = await getCurrentUser() {
            do {
                try await supabase.from("blocks")
                    .delete()
                    .eq("blocker_id", value: currentUser.id)
                    .eq("blocked_id", value: userID)
                    .execute()
                print("Unblocked '\(userID)'")
            } catch {
                print("Failed to Unblock '\(userID)' ... Error: \(error.localizedDescription)")
            }
        }
    }
    
    func isUserBlocked(userID: String) async -> Bool {
        if let currentUser = await getCurrentUser() {
            do {
                let block: Block = try await supabase
                    .from("blocks")
                    .select()
                    .eq("blocker_id", value: currentUser.id)
                    .eq("blocked_id", value: userID)
                    .single() // Fetch a single row if it exists
                    .execute()
                    .value
                
                print(block)
                
                return true
                
            } catch {
                // Handle the case where no block exists or there is an error
                print("Failed to check block for user '\(userID)' ... Error: \(error.localizedDescription)")
                return false
            }
        }
        return false    }
    
    
    //
    // Supabase Notifications
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
    
    func usernameAvailable(username: String) async -> Bool {
        do {
            // Fetch users with the given username
            let users: [User] = try await supabase
                .from("users")
                .select()
                .eq("username", value: username)  // Use the provided username instead of a hardcoded value
                .execute()
                .value
            
            // If the array is empty, the username is available
            if users.isEmpty {
                return true
            } else {
                // Username already exists
                print("Username is already taken: \(users.first?.username ?? "")")
                return false
            }
        } catch {
            print("Error checking username availability: \(error)")
            return false
        }
    }
    
    func updateProfilePicture(imageData: String) async {
        do {
            let response = try await supabase.functions
                .invoke(
                    "update-profile-picture",
                    options: FunctionInvokeOptions(
                        body: [
                            "imageData": imageData
                        ]
                    ),
                    decode: { data, response in
                        String(data: data, encoding: .utf8)
                    }
                )
            print(response ?? "No Response from update-profile-picture()")
        }
        catch {
            print("Error:", error.localizedDescription)
        }
    }
    
    
    //
    // Submissions
    //
    func postSubmission(parentId: String?, submissionText: String) async {
        do {
            let response = try await supabase.functions
                .invoke(
                    "post-submission",
                    options: FunctionInvokeOptions(
                        body: [
                            "parentId": parentId,
                            "submissionText": submissionText
                        ]
                    ),
                    decode: { data, response in
                        String(data: data, encoding: .utf8)
                    }
                )
            print(response ?? "")
        }
        catch {
            print("Error:", error.localizedDescription)
        }
        
    } // Edge done
    
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
    
    func deleteSubmissionAndReplies(submissionID: String) async {
        do {
            // Recursively delete replies
            if let replies = await getReplies(parentID: submissionID) {
                for submission in replies {
                    await deleteSubmissionAndReplies(submissionID: submission.id)
                }
            }
            // Delete the submission
            try await supabase
                .from("submissions")
                .delete()
                .eq("id", value: submissionID)
                .execute()
        } catch {
            print("Failed while trying to delete submission. Error: \(error)")
        }
        
        // Update replies_count on parentSubmission
        guard let submission = await getSubmission(submissionID: submissionID) else {
            return
        }
        if let parent_id = submission.parent_id {
            print("sub", submissionID, "par", parent_id)
            await updateRepliesCount(submissionID: parent_id)
        }
    }
    
    func reportSubmission(submissionID: String) async {
        guard let submission = await getSubmission(submissionID: submissionID) else {
            print("No submission found in database when trying to report...")
            return
        }
        do {
            try await supabase
              .from("submissions")
              .update(["reports": submission.reports + 1])
              .eq("id", value: submissionID)
              .execute()
            print("Submission reported successfully!")
        } catch {
            print("Failed to update submission reports count. Error: \(error)")
        }
    }
    
    func updateLikesCount(submissionID: String) async {
        do {
            let response = try await supabase
                .from("votes")
                .select(count: .exact)
                .eq("submission_id", value: submissionID)
                .eq("value", value: 1)
                .execute()
            if let count = response.count {
                try await supabase
                  .from("submissions")
                  .update(["likes_count": count])
                  .eq("id", value: submissionID)
                  .execute()
            } else {
                print("error getting likes count")
            }
        } catch {
            print("Failed to get likes or update submission likes_count. Error: \(error)")
        }
    }
    
    func updateDislikesCount(submissionID: String) async {
        do {
            let response = try await supabase
                .from("votes")
                .select(count: .exact)
                .eq("submission_id", value: submissionID)
                .eq("value", value: -1)
                .execute()
            if let count = response.count {
                try await supabase
                  .from("submissions")
                  .update(["dislikes_count": count])
                  .eq("id", value: submissionID)
                  .execute()
            } else {
                print("error getting likes count")
            }
        } catch {
            print("Failed to get likes or update submission likes_count. Error: \(error)")
        }
    }
    
    func updateRepliesCount(submissionID: String) async {
        do {
            let response = try await supabase
                .from("submissions")
                .select(count: .exact)
                .eq("parent_id", value: submissionID)
                .execute()
            if let count: Int = response.count {
                try await supabase
                  .from("submissions")
                  .update(["replies_count": count])
                  .eq("id", value: submissionID)
                  .execute()
            } else {
                print("error getting replies count")
            }
        } catch {
            print("Failed to get replies or update submission replies count. Error: \(error)")
        }
    }
    
    func getScore(submissionID: String) async -> Int {
        
        guard let liveBoosts = await getLiveBoosts(submissionID: submissionID) else {
            print("Error fetching live boosts")
            return 0
        }
        
        var positive = 0
        var negative = 0
        for boost in liveBoosts {
            if boost.power > 0 {
                positive += boost.power
            }
            else if boost.power < 0 {
                negative += boost.power
            }
        }
        let score = positive - negative
        
        return score
    }

    
    //
    // Voting
    //
    func castVote(submissionID: String, voterID: String, receiverID: String, value: Int) async {
        do {
            let vote: Vote = try await supabase
                .from("votes")
                .select()
                .eq("voter_id", value: voterID)
                .eq("submission_id", value: submissionID)
                .single()
                .execute()
                .value
            print("old vote value: \(vote.value)")
            vote.value = value
            print("new vote value: \(vote.value)")
            do {
                try await supabase
                    .from("votes")
                    .upsert(vote)
                    .execute()
            } catch {
                print("Failed to replace Vote in DB: \(error.localizedDescription)")
            }
        } catch {
            print("Vote not found: \(error.localizedDescription)")
            print("Creating new Vote")
            let vote = Vote(
                id: UUID().uuidString,
                submission_id: submissionID,
                voter_id: voterID,
                receiver_id: receiverID,
                value: value)
            print("creating new vote with: \(vote.value)")
            do {
                try await supabase
                    .from("votes")
                    .upsert(vote)
                    .execute()
            } catch {
                print("Failed to add Vote to DB: \(error.localizedDescription)")
            }
            
        }
    }
 
    func getUserVote(submissionID: String, userID: String) async -> Int {
        do {
            let vote: Vote = try await supabase
                .from("votes")
                .select()
                .eq("submission_id", value: submissionID)
                .eq("voter_id", value: userID)
                .single()
                .execute()
                .value
            return vote.value
        } catch {
            return 0
        }
    }
    
    func getSubmissionVotes(parentID: String) async -> [Vote]? {
        do {
            let votes: [Vote] = try await supabase
                .from("votes")
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
    func purchaseBoost(boostName: String, submissionID: String) async {
        do {
            let response = try await supabase.functions
                .invoke(
                    "purchase-boost",
                    options: FunctionInvokeOptions(
                        body: [
                            "boostName": boostName,
                            "submissionID": submissionID
                        ]
                    ),
                    decode: { data, response in
                        String(data: data, encoding: .utf8)
                    }
                )
            print(response ?? "")
        }
        catch {
            print("Error:", error.localizedDescription)
        }
    } // edge done
    
    func getBoostInfo(boostName: String) async -> BoostInfo? {
        do {
            let boostInfo: BoostInfo = try await supabase
                .from("boost_info")
                .select()
                .eq("name", value: boostName)
                .single()
                .execute()
                .value
            return boostInfo
        } catch {
            print("Failure - Could not get info for boost with name \(boostName) ... Error: \(error.localizedDescription)")
            return nil  // Return nil if there's an error
        }
    }
    
    func getLiveBoosts(submissionID: String) async -> [Boost]? {
        do {
            let boosts: [Boost] = try await supabase
                .from("boosts")
                .select()
                .eq("live", value: "true")
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
    
    func verifyReceiptAndAddToBalance() async {
        // Get the receipt from the app bundle
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: appStoreReceiptURL) else {
            print("No receipt data found.")
            return
        }
        let receiptString = receiptData.base64EncodedString()
        
        guard let currentUser = await getCurrentUser() else {
            return
        }
        
        var environment = "production"
        if ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] == nil {
            environment = "development"
        }
        do {
            let response = try await supabase.functions
                .invoke(
                    "verify-receipt",
                    options: FunctionInvokeOptions(
                        body: [
                            "userId": currentUser.id,
                            "receipt": receiptString,
                            "environment": environment
                        ]
                    ),
                    decode: { data, response in
                        String(data: data, encoding: .utf8)
                    }
                )
            print(response ?? "")
            print(type(of: response)) // String?
        }
        catch {
            print("Error:", error.localizedDescription)
        }
        
    }   // edge done
    
    func subscribeToBoostsRealtime() async {
        
        // Subscribe to Channel
        let myChannel = supabase.channel("boost-changes")

        let changes = myChannel.postgresChange(
          AnyAction.self,
          schema: "public",
          table: "boosts"
        )
        await myChannel.subscribe()
        
        // Get existing boosts that are live
//        guard let liveBoosts = await getLiveBoosts(submissionID: submissionID) else {
//            print("Error fetching live boosts")
//            return
//        }
//        
//        DispatchQueue.main.async {
//            self.boosts = liveBoosts
//        }
        
        // Add new boosts as they go live in the "boosts" table
        for await _ in changes {
            guard let currentRealtimeSubmissionID else {
                return
            }
            guard let liveBoosts = await getLiveBoosts(submissionID: currentRealtimeSubmissionID) else {
                print("error getting boosts")
                return
            }
            DispatchQueue.main.async {
                self.boosts = liveBoosts
            }
            
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
    
    
    //
    // Feeds
    //
    func getAllSubmissions(feedType: String, feedFilter: String) async -> [Submission]? {
        
        struct SubmissionsResponse: Codable {
            let data: [Submission]
            let message: String
        }
        
        do {
            // Invoke the Supabase function
            let response = try await supabase.functions
                .invoke(
                    "get_feed",
                    options: FunctionInvokeOptions(
                        body: [
                            "feedType": feedType,
                            "feedFilter": feedFilter
                        ]
                    ),
                    decode: { data, response in
                        /*
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("JSON Response:", jsonString)
                        }
                         */
                        return try JSONDecoder().decode(SubmissionsResponse.self, from: data)
                    }
                )
            return response.data
            
            
        } catch {
            // Print the error if the invocation fails
            print("Error:", error.localizedDescription)
            return nil // Ensure nil is returned on error
        }
        
    }
    
    
    //
    // Search
    //
    func searchForUsers(query: String) async -> [User] {
        guard !query.isEmpty else {
            return [] // Return an empty array if the search query is empty
        }
        
        do {
            let users: [User] = try await supabase
                .from("users") // Replace with your actual users table name
                .select()
                .ilike("username", pattern: "%\(query)%")
                .execute()
                .value
            return users
        } catch {
            print("Error searching for users: \(error)")
            return []
        }
    
    }
    
    func searchForSubmissions(query: String) async -> [Submission] {
        guard !query.isEmpty else {
            return [] // Return an empty array if the search query is empty
        }
        print("searching")
        do {
            let submissions: [Submission] = try await supabase
                .from("submissions") // Replace with your actual users table name
                .select()
                .ilike("text", pattern: "%\(query)%")
                .execute()
                .value
            return submissions
        } catch {
            print("Error searching for submissions: \(error)")
            return []
        }
    }
    

    
    
    
}
