//
//  BoostButtonView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/26/24.
//

import SwiftUI

struct BoostButtonView2: View {
    
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
            
            VStack(alignment:.leading, spacing:5) {
                HStack {
                    Text(icon)
                        .font(.title)
                }
                .padding(5)
                .frame(maxWidth: .infinity)
                .background()
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                HStack {
                    Text("💪")
                    Text(String(abs(power)))
              
                }
                .padding(5)
                .frame(maxWidth: .infinity)
                .background()
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                
                HStack {
                    Text("⏱️")
                    Text(String(time))
             
                }
                .padding(5)
                .frame(maxWidth: .infinity)
                .background()
                .cornerRadius(10)
                HStack {
                    Image("coin")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text(String(price))
                    
                }
                .padding(5)
                .frame(maxWidth: .infinity)
                .background()
                .cornerRadius(10)
            }
            .font(.footnote)
            .padding(5)
            
        }
        .foregroundColor(.primary)
        .background(power < 0 ? .red : .blue)
        .cornerRadius(10)
        .frame(maxWidth: 90) // This is just an estimation for testing here
        .task {
            Task.detached {
                    await load()
                }
        }
    }
    
    func load() async {
        guard let boostInfo = await supabaseManager.getBoostInfo(boostName: name) else {
            return
        }
        
        price = boostInfo.price
        power = boostInfo.power
        time = boostInfo.time
        icon = boostInfo.icon
        
    }
    
    
    func boostPurchased() async {
        guard let submission else {
            return
        }
        await supabaseManager.purchaseBoost(
            boostName: self.name,
            submissionID: submission.id)
        
    }
}


#Preview {
    BoostButtonView2(name:"eggplant") {
        print("Boost action test")
    }
    .environmentObject(SupabaseManager())
}
