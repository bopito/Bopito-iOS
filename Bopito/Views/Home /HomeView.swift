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
    
    
    let feedTypes = ["All", "Following"]
    let feedFilters = ["New", "Hot", "Top"] // top posts expire after 7 days
    @State private var selectedFeedType = "All"
    @State private var selectedFilterType = "New" // maybe randomize to inspire exploration for now?
    
    var body: some View {
        
        ZStack {
            VStack (spacing:0){
                
                Image("bopito-logo")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding()
                
                HStack (spacing:0){
                    Picker("Feed Type", selection: $selectedFeedType) {
                        ForEach(feedTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal,10)
                    .onChange(of: selectedFeedType) {
                        Task {
                            await selectionChanged()
                        }
                    }
                    
                    Picker("Sort by", selection: $selectedFilterType) {
                        ForEach(feedFilters, id: \.self) { sort in
                            Text(sort)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 10)
                    .onChange(of: selectedFilterType) {
                        Task {
                            await selectionChanged()
                        }
                    }
                }
                Divider()
                    .padding(.top, 10)
                
                if isLoading {
                    ProgressView()
                } else if let error = error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    ScrollView {
                        
                        LazyVStack(spacing: 0) {
                            if let submissions = submissions {
                                ForEach(submissions) { submission in
                                    SubmissionView(submission: submission)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Divider()
                                    
                                }
                            }
                        }
                        .padding(.bottom, 100) // Adding some space at the bottom
                    }.scrollIndicators(.hidden)
                }
                Spacer()
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
        submissions = await supabaseManager.getAllSubmissions(feedType: selectedFeedType, feedFilter: selectedFilterType)
        isLoading = false
    }
    
    func selectionChanged() async {
        print(selectedFeedType, selectedFilterType)
        isLoading = true
        submissions = await supabaseManager.getAllSubmissions(feedType: selectedFeedType, feedFilter: selectedFilterType)
        isLoading = false
    }
}


#Preview {
    
    HomeView()
        .environmentObject(SupabaseManager())
}

