//
//  EditProfileView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/10/24.
//

import SwiftUI

struct EditProfileView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    @Environment(\.presentationMode) var presentationMode // Add this line to access presentation mode
    
    @State var posts: [Submission]?
    @State var user: User?
    
    // Properties for form fields
    @State var name: String = ""
    @State var username: String = ""
    @State var bio: String = ""
    
    var body: some View {
        VStack (spacing:10) {
            Text("Edit Profile")
                .font(.title)
            
            if let user = user {
                // Profile picture
                ProfilePictureView(profilePictureURL: user.profile_picture)
                    .frame(width: 100, height: 100)
                    
                Button(action: {
                    // Handle edit picture action
                }) {
                    /*
                    Text("Change Picture")
                        .font(.headline)
                     */
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
                    TextField("@\(username)", text: Binding(
                        get: { username },
                        set: { newValue in
                            username = sanitizeUsername(newValue)
                        }
                    ))
                    .padding(.trailing, 10)
                    .frame(maxWidth: 200)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.asciiCapable) // only letter and numbers
                    .autocapitalization(.none)
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
            
            Button(action: {
                Task {
                    await saveChangesPressed()
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Save Changes")
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)  // Adjust this value for more or less rounded corners
            }
            .padding(20)
            
            
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
                    bio = user.bio ?? ""
                }
            }
        }
    }
    
    func sanitizeUsername(_ input: String) -> String {
        // Only allow English letters (both lowercase and uppercase) and numbers
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        return input.unicodeScalars.filter { allowedCharacters.contains($0) }.map(String.init).joined().lowercased()
    }
    
    func saveChangesPressed() async {
        if let user = user {
            user.name = name
            user.username = username
            user.bio = bio
            await supabaseManager.updateUser(user: user)
        }
        
    }
}

#Preview {
    EditProfileView()
        .environmentObject(SupabaseManager())
}
