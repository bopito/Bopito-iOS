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
        VStack (spacing:0) {
            Capsule()
                    .fill(Color.secondary)
                    .opacity(0.5)
                    .frame(width: 50, height: 5)
                    .padding(.top, 20)
            
            Text("Battle")
                .font(.title2)
                .padding(.vertical, 10)
            
            Divider()
            
            ZStack {
//                Rectangle()
//                    .foregroundColor(Color.primary)
//                    .frame(height: 70)
                HStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.red.tertiary)
                        .frame(height:50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20) // Same corner radius for the outline
                                .stroke(Color.red, lineWidth: 2) // Outline color and width
                        )
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue.quaternary)
                        .frame(height:50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20) // Same corner radius for the outline
                                .stroke(Color.blue, lineWidth: 2) // Outline color and width
                        )
                }
                .padding(.horizontal, 10)
                
                HStack {
                    Spacer()
                    Text("0")
                        .bold()
                        .foregroundStyle(Color(.systemBackground))
                        .shadow(color:.red, radius: 7)
                    Spacer()
                    Spacer()
                    Text("0")
                        .bold()
                        .foregroundStyle(Color(.systemBackground))
                        .shadow(color:.blue, radius: 7)
                    Spacer()
                }
                
                Circle()
                    .foregroundColor(Color(.systemBackground))
                    .frame(height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.yellow, lineWidth: 3) // Yellow stroke with specified line width
                           
                    )
                    .overlay(
                        Image("boost")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.yellow)
                            
                    )
            }
            .padding(.vertical, 10)
            
            Divider()
            
            
            Spacer()
            
            
            
            VStack {
                if supabaseManager.boosts.isEmpty {
                    Text("Fire in ze hole!")
                        //.background(.secondary)
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
                                //.foregroundStyle(Color(.systemBackground))
                        }
                        Text(currentUser.username)
                            .padding(.leading, 2)
                            //.foregroundStyle(Color(.systemBackground))
                    }
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            //.background(.primary)
            
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
            //.background(.primary)
            
            
            
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
