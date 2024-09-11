//
//  EditProfileView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/10/24.
//

import SwiftUI

struct EditProfileView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var posts: [Submission]?
    @State var user: User?
    
    // Properties for form fields
    @State var name: String = ""
    @State var username: String = ""
    @State var bio: String = ""
    
    var body: some View {
        VStack {
            Text("Edit Profile")
                .font(.title)
            
            if let user = user {
                // Profile picture
                ProfilePictureView(profilePictureURL: user.profile_picture)
                    .frame(width: 100, height: 100)
                    .padding()
                
                Button(action: {
                    // Handle edit picture action
                }) {
                    Text("Edit Picture")
                        .font(.headline)
                }
                
                Divider()
                
                HStack {
                    Text("Name")
                        .font(.headline)
                        .padding(.leading, 10)
                    Spacer()
                    TextField("Enter your name", text: $name)
                        .padding(.trailing, 10)
                        .frame(maxWidth: 200)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                
                HStack {
                    Text("Username")
                        .font(.headline)
                        .padding(.leading, 10)
                    Spacer()
                    TextField("@\(user.username)", text: $username)
                        .padding(.trailing, 10)
                        .frame(maxWidth: 200)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                
                HStack {
                    Text("Bio")
                        .font(.headline)
                        .padding(.leading, 10)
                    Spacer()
                    TextField("Enter your bio", text: $bio)
                        .padding(.trailing, 10)
                        .frame(maxWidth: 200)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                user = await supabaseManager.getCurrentUser()
                if let user = user {
                    // Initialize the fields with the current user info
                    name = user.name ?? ""
                    username = user.username
                    bio = user.bio
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(SupabaseManager())
}
