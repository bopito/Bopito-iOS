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
                
                VStack {
                    if let currentUser = currentUser {
                        HStack (spacing:0) {
                            Spacer()
                            ProfilePictureView(profilePictureURL: currentUser.profile_picture)
                                .frame(width: 50, height: 50)
                            Spacer()
                        }
                        
                    }
                }
                .padding(.vertical, 10)
                
                HStack (spacing:10) {
                    VStack (spacing:10) {
                        BoostButtonView(submission: submission, name: "poop") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "skull") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "tornado") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "skunk") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "bomb") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "trex") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "ghost") {
                            Task {
                                //await load()
                            }
                        }
                    }
                    
                    VStack (spacing:10) {
                        BoostButtonView(submission: submission, name: "star") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "popper") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "jellyfish") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "sun") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "alien") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "rocket") {
                            Task {
                                //await load()
                            }
                        }
                        BoostButtonView(submission: submission, name: "eggplant") {
                            Task {
                                //await load()
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                
                
                if let currentUser = currentUser {
                    HStack (spacing:0) {
                        Spacer()
                        
                        Image("coin")
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("\(currentUser.balance)")
                            .bold()
                        Spacer()
                    }
                    .padding(.bottom, -10)
                    .padding(.top, 5)
                }
                
                
            
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
        
        if let boosts = await supabaseManager.getLiveBoosts(submissionID: submission.id) {
            supabaseManager.boosts = boosts
        }
        supabaseManager.currentRealtimeSubmissionID = submission.id
    }
    
   
    
    

}

#Preview {
    BoostsView()
        .environmentObject(SupabaseManager())
}
