//
//  BoostButtonView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/26/24.
//

import SwiftUI

struct BoostButtonView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var submission: Submission?
    
    @State var boostInfo: BoostInfo?
    
    let name: String
    let emoji: String
    let backgroundColor: Color
    
    @State var power: Int = 0
    @State var time: Int = 0
    @State var price: Int = 0
    
    let action: () -> Void // Action closure when the button is tapped
    
    var body: some View {
        Button(action: {
            Task {
                await boostPurchased()
                action()
            }
            
        }) {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Text(emoji)
                        .font(.title2)
                    Text("\(power)")
                        .font(.title2)
                    Spacer()
                }
                .padding(5)
                .background(.secondary)
                .cornerRadius(10)
                
                HStack {
                    Spacer()
                    Text("⏱️")
                    Text("\(time)")
                    Spacer()
                }
                .font(.title2)
                .padding(5)
                .background(.secondary)
                .cornerRadius(10)
                
                HStack {
                    Spacer()
                    Image("coin")
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("\(price)")
                    Spacer()
                }
                .font(.title2)
                .padding(5)
                .background(.secondary)
                .cornerRadius(10)
            }
            .padding(8)
        }
        .foregroundColor(.white)
        .background(backgroundColor)
        .cornerRadius(10)
        .frame(maxWidth: 200)
        .task {
            await load()
        }
    }
    
    func load() async {
        guard let submission else {
            return
        }
        guard let boostInfo = await supabaseManager.getBoostInfo(boostName: name) else {
            return
        }
        price = boostInfo.price
        power = boostInfo.power
        time = boostInfo.time
    
    }
    
    
    func boostPurchased() async {
        if let submission = submission {
            await supabaseManager.purchaseBoost(
                boostName: self.name,
                submissionID: submission.id)
        }
    }
}


#Preview {
    BoostButtonView(name:"star", emoji: "🐲", backgroundColor: .blue) {
        print("Executing Boost Action")
    }
}
