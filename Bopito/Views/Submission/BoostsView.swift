//
//  BoostsView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/24/24.
//

import SwiftUI
import Charts

struct BoostData {
    let category: String
    var totalValue: Int
}

struct BoostsView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var submission: Submission?
    @State var currentUser: User?
    
    @State var boosts: [Boost]?
    
    // Sample data for the chart
    @State var boostData: [BoostData] = []
    
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
                // Chart
                ZStack {
                    if boostData.isEmpty {
                        // Display a gray placeholder chart if there's no data
                        Chart {
                            SectorMark(
                                angle: .value("Placeholder", 1),
                                innerRadius: .ratio(0.4)
                            )
                            .foregroundStyle(.gray)
                        }
                        .scaledToFit()
                    } else {
                        Chart(boostData, id: \.category) { item in
                            SectorMark(
                                angle: .value("Count", item.totalValue),
                                innerRadius: .ratio(0.4),
                                angularInset: 2
                            )
                            .cornerRadius(5)
                            .foregroundStyle(by: .value("Category", item.category))
                            .annotation(position: .overlay) {
                                if item.totalValue != 0 {
                                    Text("\(item.totalValue)")
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .scaledToFit()
                        .chartLegend(.hidden)
                        .chartForegroundStyleScale(
                            ["pushesLive": .blue,
                             "pushesDead": Color(red: 0.1, green: 0.8, blue: 1.0),
                             "pullsLive": Color(red: 1.0, green: 0.3, blue: 0.3),
                             "pullsDead": Color(red: 1.0, green: 0.5, blue: 0.4),
                            ]
                        )
                    }
                    
                    Image("boost")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.yellow)
                }
                .padding(.leading, 20)
                .padding(.trailing, 10)
                
                // Legend
                VStack {
                    HStack {
                        ZStack{
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: 80, height: 70)
                                .cornerRadius(10)
                            VStack {
                                Text("7")
                                    .font(.title2)
                                Text("Live")
                            }.foregroundColor(.white)
                        }
                        ZStack{
                            Rectangle()
                                .foregroundColor(Color(red: 0.1, green: 0.8, blue: 1.0))
                                .frame(width: 80, height: 70)
                                .cornerRadius(10)
                            VStack {
                                Text("3")
                                    .font(.title2)
                                Text("Dead")
                            }.foregroundColor(.white)
                        }
                    }
                    HStack {
                        ZStack{
                            Rectangle()
                                .foregroundColor(.red)
                                .frame(width: 80, height: 70)
                                .cornerRadius(10)
                            VStack {
                                Text("7")
                                    .font(.title2)
                                Text("Live")
                            }.foregroundColor(.white)
                        }
                        ZStack{
                            Rectangle()
                                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.4))
                                .frame(width: 80, height: 70)
                                .cornerRadius(10)
                            VStack {
                                Text("3")
                                    .font(.title2)
                                Text("Dead")
                            }.foregroundColor(.white)
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 10)
            }
            
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
            
            BoostButtonView(submission: submission, emoji: "🌟", backgroundColor: .blue, value: 1, time: 10, price: 1, category: "pushes") {
                Task {
                    await updateBoostData()
                }
            }
            BoostButtonView(submission: submission, emoji: "🚀", backgroundColor: .blue,  value: 2, time: 30, price: 5, category: "pushes") {
                Task {
                    await updateBoostData()
                }
            }
            BoostButtonView(submission: submission, emoji: "🌟", backgroundColor: .red, value: -1, time: 10, price: 1, category: "pulls") {
                Task {
                    await updateBoostData()
                }
            }
            BoostButtonView(submission: submission, emoji: "🌟", backgroundColor: .red, value: -2, time: 30, price: 5, category: "pulls") {
                Task {
                    await updateBoostData()
                }
            }
           
            
            Spacer()
        }
        .task {
            await load()
        }
        
    }
    
    func load() async {
        currentUser = await supabaseManager.getCurrentUser()
        await updateBoostData()
    }
    
   
    
    
    func updateBoostData() async {
        // Check if both submission and currentUser are available
        if let submission = submission {
            
            // Update Boosts count on Submission
            await supabaseManager.updateBoostsCount(submissionID: submission.id)
            // Fetch boosts from the server
            boosts = await supabaseManager.getBoosts(submissionID: submission.id)
            
            if let boosts = boosts {
                if boosts.isEmpty {
                    return
                }
                // Initialize the counts for each category
                var pushesDead = BoostData(category: "pushesDead", totalValue: 0)
                var pullsDead = BoostData(category: "pullsDead", totalValue: 0)
                var pullsLive = BoostData(category: "pullsLive", totalValue: 0)
                var pushesLive = BoostData(category: "pushesLive", totalValue: 0)
                
                // Update counts based on the fetched boosts
                for boost in boosts {
                    if boost.category == "pushes" {
                        if boost.live {
                            pushesLive.totalValue += boost.value
                        } else {
                            pushesDead.totalValue += boost.value
                        }
                    } else if boost.category == "pulls" {
                        if boost.live {
                            pullsLive.totalValue += boost.value
                        } else {
                            pullsDead.totalValue += boost.value
                        }
                    }
                }
                // Reset boostData and add the updated counts
                boostData = [pushesDead, pullsDead, pullsLive, pushesLive]
            }
        }
    }
    
}

#Preview {
    BoostsView()
        .environmentObject(SupabaseManager())
}
