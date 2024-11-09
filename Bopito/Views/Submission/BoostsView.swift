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
    
    @State var loading: Bool = true
    
    
    var body: some View {
        VStack (spacing:0) {
            
            Capsule()
                .fill(Color.secondary)
                .opacity(0.5)
                .frame(width: 50, height: 5)
                .padding(.top, 20)
            Text("Battle")
                .font(.title2)
                .padding(.top, 10)
            
            ZStack {
                //                Rectangle()
                //                    .foregroundColor(Color.primary)
                //                    .frame(height: 70)
                HStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.red)//.tertiary)
                        .frame(height:50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20) // Same corner radius for the outline
                                .stroke(Color.red, lineWidth: 2) // Outline color and width
                        )
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue)//.quaternary)
                        .frame(height:50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20) // Same corner radius for the outline
                                .stroke(Color.blue, lineWidth: 2) // Outline color and width
                        )
                }
                .padding(.horizontal, 10)
                
                HStack {
                    Spacer()
                    let negativePowerTotal = supabaseManager.boosts
                        .filter { $0.power < 0 }
                        .reduce(0) { $0 + $1.power }
                    Text("\(negativePowerTotal)")
                        .bold()
                        .font(.title2)
                        .foregroundStyle(.white)
                        .shadow(color:.red, radius: 7)
                    Spacer()
                    Spacer()
                    let positivePowerTotal = supabaseManager.boosts
                        .filter { $0.power > 0 }
                        .reduce(0) { $0 + $1.power }
                    Text("\(positivePowerTotal)")
                        .bold()
                        .font(.title2)
                        .foregroundStyle(.white)
                        .shadow(color:.blue, radius: 7)
                    Spacer()
                }
                
                Circle()
                    .foregroundColor(.primary)
                    .frame(height: 50)
                //                    .overlay(
                //                        Circle()
                //                            .stroke(Color.primary, lineWidth: 3) // Yellow stroke with specified line width
                //
                //                    )
                    .overlay(
                        Image("bopito-logo")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.bottom,3)
                        
                    )
            }
            .padding(.vertical, 10)
            
            
            Divider()
            
            
            VStack (spacing:0) {
                if supabaseManager.boosts.isEmpty {
                    Image(systemName: "bolt.slash")
                        .font(.system(size: 70))
                } else {
                    ScrollView {
                        VStack(spacing:0) {
                            ForEach(supabaseManager.boosts, id: \.id) { boost in
                                BoostView(boost: boost)
                                    .background()
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background()//(.quinary)
            
            
            Divider()
            
            ZStack {
                if let currentUser = currentUser {
                    HStack (spacing:0) {
                        Spacer()
                        Image("coin")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(String(currentUser.balance))
                            //.bold()
                        Spacer()
                    }
                    .padding(10)
                }
                
                HStack {
                    Spacer()
                    Divider()
                        .frame(maxHeight: 20)
                    Text("Smites")
                        .padding(.horizontal, 5)
                        .bold()
                        .cornerRadius(10)
                    Divider()
                        .frame(maxHeight: 20)
                    Spacer()
                    
                    
                    Spacer()
                    Divider()
                        .frame(maxHeight: 20)
                    Text("Boosts")
                        .padding(.horizontal, 5)
                        .bold()
                        .cornerRadius(10)
                    Divider()
                        .frame(maxHeight: 20)
                    Spacer()
                }
            }
            
           
            
            Divider()
            
            ScrollView {
                VStack (spacing:10){
                    
                    HStack {
                        Spacer()
                        Group {
                            BoostButtonView(submission: submission, name: "spider") { // Smite 1
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                            BoostButtonView(submission: submission, name: "poop") { // Smite 2
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                        }
                        Spacer()
                        Spacer()
                        Group {
                            BoostButtonView(submission: submission, name: "star") { // Boost 1
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                            BoostButtonView(submission: submission, name: "popper") { // Boost 2
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                        }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Group {
                            BoostButtonView(submission: submission, name: "skunk") { // Smite 3
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                            BoostButtonView(submission: submission, name: "ghost") { // Smite 4
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                        }
                        Spacer()
                        Spacer()
                        Group {
                            BoostButtonView(submission: submission, name: "jellyfish") { // Boost 3
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                            BoostButtonView(submission: submission, name: "sun") { // Boost 4
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                        }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Group {
                            BoostButtonView(submission: submission, name: "tornado") { // Smite 5
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                            BoostButtonView(submission: submission, name: "trex") { // Smite 6
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                        }
                        Spacer()
                        Spacer()
                        Group {
                            BoostButtonView(submission: submission, name: "eggplant") { // Boost 5
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                            BoostButtonView(submission: submission, name: "alien") { // Boost 6
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                        }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Group {
                            BoostButtonView(submission: submission, name: "bomb") { // Smite 7
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                            BoostButtonView(submission: submission, name: "skull") { // Smite 8
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                        }
                        Spacer()
                        Spacer()
                        Group {
                            BoostButtonView(submission: submission, name: "dragon") { // Boost 7
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                            BoostButtonView(submission: submission, name: "rocket") { // Boost 8
                                Task {
                                    currentUser = await supabaseManager.getCurrentUser()
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.scrollIndicators(.hidden)
            
            
            
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
        
        supabaseManager.currentRealtimeSubmissionID = submission.id
        
        if let boosts = await supabaseManager.getLiveBoosts(submissionID: submission.id) {
            supabaseManager.boosts = boosts
        }
    }
    
    
    
    
    
}

#Preview {
    BoostsView()
        .environmentObject(SupabaseManager())
}
