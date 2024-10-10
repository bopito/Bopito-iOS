//
//  SearchView.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/8/24.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager  // SupabaseManager for querying data
    
    @State var users: [User] = []
    @State var submissions: [Submission] = []
    
    @State private var searchText = ""
    @State private var searchOption: SearchOption = .users  // To select between Users and Posts
    
    // Enum for search options
    enum SearchOption: String, CaseIterable {
        case users = "Users"
        case submissions = "Posts"
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Find")
                    .font(.title2)
                    .padding(10)
            }
            .frame(maxWidth: .infinity)
            .background()
            
            // Search Bar and Picker
            HStack {
                // Search text input
                TextField("Search", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 10)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                    .onChange(of: searchText) {
                        Task {
                            await performSearch()
                        }
                    }
                
                // Picker for Users or Posts
                Picker("Search for", selection: $searchOption) {
                    ForEach(SearchOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                .onChange(of: searchOption) {
                    Task {
                        await performSearch()
                    }
                }
                .pickerStyle(MenuPickerStyle())

            }
            
            // Display the search results
            if searchOption == .users {
                // Show User Results
                if users.isEmpty {
//                    Text("* *crickets chirping* *")
//                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(users, id: \.id) { user in
                                VStack(alignment: .leading) {
                                    FollowView(user: user)
                                    Divider()
                                }
                            }
                        }
                    }
                }
            } else {
                // Show Post Results
                if submissions.isEmpty {
//                    Text("* *crickets chirping* *")
//                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(submissions, id: \.id) { submission in
                                VStack(alignment: .leading) {
                                    SubmissionView(submission: submission)
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
    
    // Function to perform search based on the selected option
    private func performSearch() async {
        if searchText.isEmpty {
            // Reset users and submissions if the search text is empty
            users = []
            submissions = []
            return
        }
        
        switch searchOption {
        case .users:
            users = await supabaseManager.searchForUsers(query: searchText)
            submissions = [] // Clear submissions if searching for users
        case .submissions:
            submissions = await supabaseManager.searchForSubmissions(query: searchText)
            users = [] // Clear users if searching for submissions
        }
    }
}


#Preview {
    SearchView()
}
