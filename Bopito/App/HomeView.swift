//
//  HomeView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI


struct HomeView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State private var isComposing = false
    
    @State private var submissions: [Submission]?
    
    @State private var isLoading: Bool = true
    @State private var error: Error?
    
    var body: some View {
        ZStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let error = error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    ScrollView {
                        Text("placeholder")
                        VStack(spacing: 1) {
                            if let submissions = submissions {
                                ForEach(submissions) { submission in
                                    PostView(post: submission)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Divider()
//                                    Rectangle()
//                                        .fill(Color.) // You can use any color here
//                                                    .frame(height: 1)
                                        
                                }
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
        isLoading = true
        submissions = await supabaseManager.getRecentPosts()
        isLoading = false
    }
}


#Preview {
    
    HomeView()
        .environmentObject(SupabaseManager())
}
