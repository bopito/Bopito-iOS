//
//  EditProfileView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/10/24.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    @Environment(\.presentationMode) var presentationMode // Add this line to access presentation mode
    
    @State var posts: [Submission]?
    @State var user: User?
    
    // Properties for form fields
    @State var incognitoToggleOn: Bool = false
    @State var name: String = ""
    @State var username: String = ""
    @State var bio: String = ""
    
    @State var errorMessage: String?
    
    @State var isEditingProfilePicture: Bool = false
    
    @State var selection: PhotosPickerItem? = nil
    
    @State var profilePictureRefreshID: UUID = UUID()
    
    var body: some View {
        VStack (spacing:10) {
            Text("Edit Profile")
                .font(.title2)
                .padding(.top, 10)
            Divider()
            
            if let user = user {
                // Profile picture
                ZStack {
                    ProfilePictureView(profilePictureURL: user.profile_picture)
                        .frame(width: 100, height: 100)
                        .id(profilePictureRefreshID)
                    Circle()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.4))
                    Button(action: {
                        isEditingProfilePicture = true
                    }) {
                        Image(systemName: "camera")
                            .resizable()
                            .frame(width: 30, height: 24)
                            .foregroundColor(.white)
                        //.bold()
                    }
                    
                }
                
                
                Button(action: {
                    isEditingProfilePicture = true
                }) {
                    Text("Change Avatar")
                        .font(.callout)
                }
                .padding(.bottom, 10)
                
                /*
                // Settings
                HStack {
                    Text("Ghost Mode")
                        .font(.headline)
                    Toggle("", isOn: $incognitoToggleOn)
                        .labelsHidden()
                }
                 */
                
                if !incognitoToggleOn {
                    HStack {
                        Text("Name")
                            .font(.headline)
                            .padding(.leading, 10)
                        Spacer()
                        TextField("Enter your name", text: $name)
                            .padding(.trailing, 10)
                            .frame(maxWidth: 200)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.name)
                    }
                    
                    
                    HStack {
                        Text("Username")
                            .font(.headline)
                            .padding(.leading, 10)
                        Spacer()
                        TextField("@\(username)", text: $username)
                        .padding(.trailing, 10)
                        .frame(maxWidth: 200)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.asciiCapable) // only letter and numbers
                        .autocapitalization(.none)
                        .textContentType(.none)
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
                            .textContentType(.none)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
                
            }
            
            Button(action: {
                Task {
                    await saveChangesPressed()
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
            .padding(.top, 10)
            
            Spacer()
            
        }
        .onAppear {
            Task {
                await load()
            }
        }
        .fullScreenCover(isPresented: $isEditingProfilePicture, onDismiss: {
            Task {
                await load()
                profilePictureRefreshID = UUID()
            }
        }) {
            EditProfilePictureView()
            
        }
    }
    
    func load() async {
        user = await supabaseManager.getCurrentUser()
        if let user = user {
            // Initialize the fields with the current user info
            name = user.name
            
            username = user.username
            bio = user.bio ?? ""
            
            if name == username { name = ""}
        }
    }
    
    func saveChangesPressed() async {
        if let user = user {

            user.username = username
            user.name = name
            user.bio = bio
            
            do {
                try await supabaseManager.updateProfile(editedUser: user)
                presentationMode.wrappedValue.dismiss()
            } catch {
                print(error.localizedDescription)
                errorMessage = "Error updating profile: \(error.localizedDescription)"
            }
            
        }
        
    }
}

#Preview {
    EditProfileView()
        .environmentObject(SupabaseManager())
}
