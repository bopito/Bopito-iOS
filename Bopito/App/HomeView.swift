//
//  HomeView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI


struct HomeView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @State private var isComposing = false
    
    @State private var posts: [Post] = []
    @State private var isLoading: Bool = true
    @State private var error: Error?
    
    var body: some View {
        ZStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Posts...")
                } else if let error = error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(posts) { post in
                                PostView(post: post)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.bottom, 100) // Adding some space at the bottom
                    }
                }
            }
            VStack {
                Spacer()
                // Floating "+" button
                HStack {
                    Spacer()
                    Button(action: {
                        isComposing = true
                    }) {
                        ZStack {
                            // Background Circle
                            Circle()
                                .fill(Color.blue) // Color of the circle
                                .strokeBorder(Color.white, lineWidth: 3) // Gray outline
                                .frame(width: 60, height: 60) // Size of the circle
                            // Plus Symbol
                            Image(systemName: "plus")
                                .font(.system(size: 40)) // Size of the plus symbol
                                .foregroundColor(.white) // Color of the plus symbol
                        }.padding(20)
                    }
                    .fullScreenCover(isPresented: $isComposing, onDismiss: {
                        // Call reloadPosts when the sheet is dismissed
                        Task {
                            await loadPosts()
                        }
                        
                    }) {
                        ComposePostView()
                    }
                }
                
            }
            
        }
        .onAppear {
            Task {
                await loadPosts()
            }
        }
    }
    
    
    
    func loadPosts() async {
        do {
            isLoading = true
            posts = try await authManager.getRecentPosts()
            isLoading = false
        } catch {
            isLoading = false
            self.error = error.localizedDescription as? any Error
        }
    }
}


#Preview {
    
    HomeView()
        .environmentObject(AuthManager())
}
