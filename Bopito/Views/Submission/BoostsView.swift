//
//  BoostsView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/24/24.
//

import SwiftUI
import Charts


struct BoostsView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var submission: Submission?
    @State var currentUser: User?
    
    //@State var boosts: [Boost]?
    
    
    var body: some View {
        VStack {
            Capsule()
                    .fill(Color.secondary)
                    .opacity(0.5)
                    .frame(width: 50, height: 5)
                    .padding(.top, 20)
            
            Text("Battle")
                .font(.title2)
            
            Divider()
            
            HStack {
                if let currentUser = currentUser {
                    ProfilePictureView(profilePictureURL: currentUser.profile_picture)
                        .frame(width: 50, height: 50)
                    VStack (alignment: .leading, spacing: 0) {
                        HStack (spacing: 0) {
                            Image("coin")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Text("\(currentUser.balance)")
                                .bold()
                        }
                        Text(currentUser.username)
                            .padding(.leading, 2)
                    }
                }
                
            }
            
            HStack (spacing:10) {
                Spacer()
                
                    BoostButtonView(submission: submission, name: "poop", emoji: "💩", backgroundColor: .red) {
                        Task {
                            //await load()
                        }
                    }
                    BoostButtonView(submission: submission, name: "skull", emoji: "💀", backgroundColor: .red) {
                        Task {
                            //await load()
                        }
                    }
                
                    BoostButtonView(submission: submission, name: "star", emoji: "🌟", backgroundColor: .blue) {
                        Task {
                            //await load()
                        }
                    }
                    BoostButtonView(submission: submission, name: "rocket", emoji: "🚀", backgroundColor: .blue) {
                        Task {
                            //await load()
                        }
                    }
                Spacer()
            }
            
            VStack {
                if supabaseManager.boosts.isEmpty {
                    Text("No boosts available")
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(supabaseManager.boosts, id: \.id) { boost in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("\(boost.name) power:\(boost.power) price:\(boost.price) time:\(boost.time)")
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .shadow(radius: 2)
                            }
                        }
                        .padding()
                    }
                }
            }
            
            
            
           
            
            Spacer()
        }
        .onAppear() {
            Task {
                await load()
            }
        }
        
    }
    
    func load() async {
        currentUser = await supabaseManager.getCurrentUser()
    
        guard let submission else {
            return
        }
        await supabaseManager.subscribeToBoostsRealtime(submissionID: submission.id)
    }
    
   
    
    

}

#Preview {
    BoostsView()
        .environmentObject(SupabaseManager())
}
