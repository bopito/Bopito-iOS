//
//  SupabaseManager.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/5/24.
//

import Foundation
import Supabase


class SupabaseManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    private var supabase: SupabaseClient
    
    init() {
        supabase = SupabaseClient(
            supabaseURL: URL(string:"https://lqqhpvlxroqfqyfrpaio.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxxcWhwdmx4cm9xZnF5ZnJwYWlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU1NTk3ODEsImV4cCI6MjA0MTEzNTc4MX0.oH5JtLv2yefdNkpQ81PESC3d5iSPsWHhJUHzplosnvQ"
        )
    }
    
    func signInAnonymously() async {
        do {
            let session = try await supabase.auth.signInAnonymously()
            print("Signed in anonymously. Session: \(session)")
        } catch {
            print("Failed to sign in anonymously. Error: \(error.localizedDescription)")
        }
        await updateAuthenticationStatus()
    }
    
    func updateAuthenticationStatus() async {
        do {
            let user = try await supabase.auth.user()
            print("\(user) is signed in")
            isAuthenticated = true
        } catch {
            print("Error checking user status: \(error.localizedDescription)")
            print("not signed in")
            isAuthenticated = false
        }
    }
  
    
}
