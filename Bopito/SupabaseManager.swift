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
            let user = try await supabase.auth.user()
            print("\(user.id) is signed in")
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        } catch {
            print("Error checking user status: \(error.localizedDescription)")
            print("not signed in")
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
    
    private func createUserInDatabase(userId: String) async {
        do {
            print("creating acccount in supabase")
            let randomUsername = "user\(Int.random(in: 1000000...9999999))"
            try await supabase
                .from("users")
                .upsert(
                    User(id: userId,
                         email: nil,
                         phone: nil,
                         username: randomUsername,
                         bio: "?",
                         profile_picture: "https://lqqhpvlxroqfqyfrpaio.supabase.co/storage/v1/object/sign/profile_pictures/default.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJwcm9maWxlX3BpY3R1cmVzL2RlZmF1bHQucG5nIiwiaWF0IjoxNzI1NjA5MzE5LCJleHAiOjIwNDA5NjkzMTl9.ONDdeTtJgJ03xfskqFij2PTx2SDNsVaI1IdlZoCEv_g")
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
    
    
    
    func postSubmission(author_id: String, parent_id: String?, image: String, text: String) async {
        do {
            let submission = Submission(
                id: UUID().uuidString,
                author_id: author_id,
                parent_id: parent_id,
                replies_count: 0,
                likes_count: 0,
                image: image,
                text: text)
            do {
                try await supabase
                    .from("submissions")
                    .insert(submission)
                    .execute()
            } catch {
                print(error)
            }
        } catch {
            print(error)
            return
        }
        
        
    }
    
    
    func getRecentPosts() async -> [Submission]? {
        do {
            let submissions: [Submission] = try await supabase
                        .from("submissions")
                        .select()
                        .execute()
                        .value
            print(submissions)
            return submissions
            
        } catch {
            print("Failed to get user by ID. Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getUserPosts(userID: String) async -> [Submission]? {
        do {
            let submissions: [Submission] = try await supabase
                        .from("submissions")
                        .select()
                        .eq("author_id", value: userID)
                        .order("created_at", ascending: false)
                        .execute()
                        .value
            print(submissions)
            return submissions
            
        } catch {
            print("Failed to get user by ID. Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    
}
