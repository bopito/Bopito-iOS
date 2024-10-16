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
    
    let name: String
    let emoji: String
    let backgroundColor: Color
    
    let value: Int = 0
    let time: Int = 0
    let price: Int = 0
    
    let action: () -> Void // Action closure when the button is tapped
    
    var body: some View {
        Button(action: {
            Task {
                await boostPurchased()
                action()
            }
            
        }) {
            HStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text(emoji)
                        .font(.title2)
                    Text("\(value)")
                        .font(.title2)
                    Spacer()
                }
                .padding(5)
                .background(.secondary)
                .cornerRadius(10)
                
                Spacer()
                
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
                
                Spacer()
                
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
        .padding(.horizontal)
    }
    
    
//    func boostPurchased(price: Int, time: Int, value:Int, category: String) async {
//        if let submission = submission, let currentUser = await supabaseManager.getCurrentUser() {
//            // Add boost
//            print(currentUser.balance)
//            await supabaseManager.applyBoost(
//                price: price,
//                time: time,
//                value: value,
//                category: category,
//                submissionID: submission.id,
//                userID: currentUser.id
//            )
//            
//        }
//        
//    }
    func boostPurchased() async {
        if let submission = submission {
            await supabaseManager.purchaseBoost(
                boostName: self.name,
                submissionID: submission.id)
        }
    }
}


#Preview {
    BoostButtonView(name:"dragon", emoji: "🐲", backgroundColor: .blue) {
        print("Executing Boost Action")
    }
}
