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
    
    @State var power: Int = 0
    @State var time: Int = 0
    @State var price: Int = 0
    @State var icon: String = ""
    
    let action: () -> Void // Action closure when the button is tapped
    
    var body: some View {
        Button(action: {
            Task {
                await boostPurchased()
                action()
            }
            
        }) {
            
            HStack(spacing:2) {
                    Text(icon)
                Text("\(abs(power))")
                    
                    Spacer()
                    
                    Text("⏱️")
                    Text("\(time)")
                    
                    Spacer()
                    
                    Image("coin")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("\(price)")
            }
            .padding(8)
        }
        .foregroundColor(.white)
        .background(power < 0 ? .red : .blue)
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
        icon = boostInfo.icon
    
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
    BoostButtonView(name:"star") {
        print("Executing Boost Action")
    }
}
