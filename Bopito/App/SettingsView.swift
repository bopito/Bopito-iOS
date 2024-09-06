//
//  SettingsView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @State private var newDisplayName: String = ""
    @State private var updateStatus: String = ""
    
    var body: some View {
        VStack {
            if let user = authManager.currentUser {
                Text("settings")
                    .font(.largeTitle)
                    .padding()
                
                HStack {
                    
                }
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                
                
                // Display the user's displayName
                Text(user.displayName ?? "Username not set")
                
                
                // Display the user's email
                Text(user.email ?? "Email not set")
                
                
                
                // Display and edit displayName
                TextField("Choose a username", text: $newDisplayName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onAppear {
                        // Initialize the text field with the current displayName
                        newDisplayName = user.displayName ?? ""
                    }
                
                Button(action: {
                    //authManager.updateUserDisplayName(username: "enter a username")
                }) {
                    Text("Update Username")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
                
                Text(updateStatus)
                    .foregroundColor(.red)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    authManager.signOut()
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
            } else {
                Text("User information is not available")
                    .padding()
            }
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthManager())
    }
}
