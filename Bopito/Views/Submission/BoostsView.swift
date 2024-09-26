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
    var count: Double
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
                                angle: .value("Count", item.count),
                                innerRadius: .ratio(0.4),
                                angularInset: 2
                            )
                            .cornerRadius(5)
                            .foregroundStyle(by: .value("Category", item.category))
                            .annotation(position: .overlay) {
                                Text("\(Int(item.count))")
                                    .foregroundStyle(.white)
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
            
            
            Button(action: {
                Task{
                    await boostPurchased(price: 1, time: 1, value: 5, category: "pushes")
                }
            }) {
                HStack (spacing:10) {
                    Text("🔥")
                    Text("+1")
                    Spacer()
                    Text("⏱️")
                        .font(.title)
                    Text("100")
                    Spacer()
                    Image("coin")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("5")
                    Spacer()
                    Text("Buy")
                    
                }
                .padding()
            }
            .font(.title2)
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Button(action: {
                Task{
                    await boostPurchased(price: 1, time: 1, value: -3, category: "pulls")
                }
            }) {
                HStack (spacing:10) {
                    Text("🔥")
                    Text("-1")
                    Spacer()
                    Text("⏱️")
                        .font(.title)
                    Text("100")
                    Spacer()
                    Image("coin")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("5")
                    Spacer()
                    Text("Buy")
                    
                }
                .padding()
            }
            .font(.title2)
            .foregroundColor(.white)
            .background(.red)
            .cornerRadius(10)
            .padding(.horizontal)
            
            
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
    
    func boostPurchased(price: Int, time: Int, value:Int, category: String) async {
        if let submission = submission, let currentUser = currentUser {
            await supabaseManager.applyBoost(
                price: price,
                time: time,
                value: value,
                category: category,
                submissionID: submission.id,
                userID: currentUser.id
            )
        }
        await updateBoostData()
    }
    
    
    func updateBoostData() async {
        // Check if both submission and currentUser are available
        if let submission = submission, let currentUser = currentUser {
            // Fetch boosts from the server
            boosts = await supabaseManager.getBoosts(submissionID: submission.id)
            
            if let boosts = boosts {
                if boosts.isEmpty {
                    return
                }
                // Initialize the counts for each category
                var pushesDead = BoostData(category: "pushesDead", count: 0)
                var pullsDead = BoostData(category: "pullsDead", count: 0)
                var pullsLive = BoostData(category: "pullsLive", count: 0)
                var pushesLive = BoostData(category: "pushesLive", count: 0)
                
                // Update counts based on the fetched boosts
                for boost in boosts {
                    if boost.category == "pushes" {
                        if boost.live {
                            pushesLive.count += 1
                        } else {
                            pushesDead.count += 1
                        }
                    } else if boost.category == "pulls" {
                        if boost.live {
                            pullsLive.count += 1
                        } else {
                            pullsDead.count += 1
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
