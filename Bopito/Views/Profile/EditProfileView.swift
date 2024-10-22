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
    @State var name: String = ""
    @State var username: String = ""
    @State var bio: String = ""
    
    @State var errorMessage: String?
    
    @State var isEditingProfilePicture: Bool = false
    
    @State var selection: PhotosPickerItem? = nil
    
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
                    //                        .overlay(alignment: .bottomTrailing) {
                    //                                
                    //                                    Image(systemName: "pencil.circle.fill")
                    //                                        .symbolRenderingMode(.multicolor)
                    //                                        .font(.system(size: 30))
                    //                                        .foregroundColor(.accentColor)
                    //                                
                    //                                .buttonStyle(.borderless)
                    //                            }
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
                    Text("Change Image")
                        .font(.callout)
                }
                
                //Divider()
                
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
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
                
            }
            Spacer()
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
            
        }
        .onAppear {
            Task {
                print(isEditingProfilePicture)
                user = await supabaseManager.getCurrentUser()
                if let user = user {
                    // Initialize the fields with the current user info
                    name = user.name
                    
                    username = user.username
                    bio = user.bio ?? ""
                    
                    if name == username { name = ""}
                }
            }
        }
        .fullScreenCover(isPresented: $isEditingProfilePicture, onDismiss: {
            print("dismissed")
        }) {
            EditProfilePictureView()
            
        }
    }
    
    func sanitizeUsername(_ input: String) -> String {
        // Only allow English letters (both lowercase and uppercase) and numbers
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        return input.unicodeScalars.filter { allowedCharacters.contains($0) }.map(String.init).joined().lowercased()
    }
    
    func saveChangesPressed() async {
        if let user = user {
            if username != user.username {
                guard await supabaseManager.usernameAvailable(username: username) else {
                    errorMessage = "Error: username taken"
                    return
                }
            }
            user.username = username
            user.name = name
            user.bio = bio
            
            await supabaseManager.updateUser(user: user)
            presentationMode.wrappedValue.dismiss()
        }
        
    }
}

#Preview {
    EditProfileView()
        .environmentObject(SupabaseManager())
}
