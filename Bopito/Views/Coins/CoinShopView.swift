//
//  CoinShopView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/26/24.
//

import SwiftUI

struct CoinShopView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var currentUser: User?
    
    @State private var selectedItem: Int? = 4
    let items = [
        ("100", "$0.99"),
        ("200", "$1.99"),
        ("300", "$2.99"),
        ("400", "$3.99"),
        ("500", "$4.99"),
        ("600", "$5.99"),
        ("700", "$6.99"),
        ("800", "$7.99"),
        ("900", "$8.99")
    ]
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        VStack (spacing:0){
            HStack {
                Text("Get Coins")
                    .font(.title2)
                    .padding(10)
            }
            .frame(maxWidth: .infinity)
            .background()
            
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(.green)
                    .bold()
                Text("Secure Payment")
                    .foregroundStyle(.green)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(.green.quaternary)
            
            
            VStack (spacing:0) {
                HStack {
                    Text("Balance:")
                    Image("coin")
                        .resizable()
                        .frame(width: 25, height: 25)
                    if let currentUser = currentUser {
                        Text("\(currentUser.balance)")
                    }
                }
                .font(.title3)
                .bold()
                .padding(.top, 10)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<items.count, id: \.self) { index in
                        let item = items[index]
                        
                        Button(action: {
                            // Set the selected item to the current index
                            selectedItem = index
                        }) {
                            VStack {
                                HStack {
                                    Image("coin")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                    Text(item.0)
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                Text(item.1)
                                    .font(.callout)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(selectedItem == index ? Color.blue : .secondary)
                            .cornerRadius(10)
                            .padding(0)
                        }
                    }
                }
                .padding(10)
                
                
            }
            .background()
            .cornerRadius(10)
            .padding(10)
            
            
            VStack (spacing:0){
                Text("Don't want to pay? Not a problem!")
                    .padding(.top,10)
                HStack {
                    Image(systemName: "play")
                    Text("Earn for Free")
                }
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(.green)
                .cornerRadius(10)
                .padding(10)
            }
            .background()
            .cornerRadius(10)
            .padding(.horizontal, 10)
            
            
            Spacer()
            
            Image("bopito-logo-gray")
                .resizable()
                .frame(width: 48, height: 40)
            Text("Bopito")
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer()
            
            
            
            VStack (spacing:0){
                HStack {
                    Text("Total")
                        .bold()
                    Spacer()
                    Text("$0")
                        .bold()
                }
                .padding(20)
                
                Button(action: {
                                    // Add recharge functionality here
                                }) {
                                    HStack {
                                        Text("")
                                        Text("Recharge")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                
            }
            .background()
        }
        .background(.quaternary)
        .task {
            await load()
        }
    }
    
    func load() async {
        currentUser = await supabaseManager.getCurrentUser()
    }
}

#Preview {
    CoinShopView()
        .environmentObject(SupabaseManager())
}
