//
//  HomeView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct ComposePostView: View {
    
    
    @EnvironmentObject var authManager: AuthManager
    
    @Environment(\.presentationMode) var presentationMode // Add this line to access presentation mode
    @FocusState private var isTextFieldFocused: Bool // Add FocusState for managing focus
    
    @State private var postText: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    Task {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Cancel")
                        .bold()
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        do {
                            try await authManager.submitPost(postText: postText)
                            // Clear the text editor on success
                            postText = ""
                            print("Post submitted successfully.")
                        } catch {
                            print("Error submitting post: \(error.localizedDescription)")
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Post")
                        .bold()
                        .frame(width: 100, height: 40)
                        .background(Color.blue) // Green background
                        .foregroundColor(.white) // White text color
                        .cornerRadius(8) // Rounded corners
                        .disabled(postText.isEmpty)
                }
            }
            
            ScrollView {
                TextField("What's on your mind?", text: $postText, axis: .vertical)
                    .focused($isTextFieldFocused)
            }
            
        }
        .padding()
        .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        // Request focus after a slight delay
                        isTextFieldFocused = true
                    }
                }
    }
    
    
    
    
    
}


#Preview {
    ComposePostView()
        .environmentObject(AuthManager())
}


