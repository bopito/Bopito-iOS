//
//  HomeView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct ComposePostView: View {
    
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
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
                        await submit()
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
    
    
    func submit() async {
        guard let user = await supabaseManager.getCurrentUser() else {
            return
        }
        let authorID = user.id
        await supabaseManager.postSubmission(
            author_id: authorID,
            parent_id: nil,
            image: "none",
            text: postText)
        // Clear the text editor on success
        postText = ""
        
    }
    
    
}


#Preview {
    ComposePostView()
        .environmentObject(SupabaseManager())
}


