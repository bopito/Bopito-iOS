//
//  CoinShopView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/26/24.
//

import SwiftUI
import StoreKit

struct CoinShopView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    @EnvironmentObject var inAppPurchaseManager: InAppPurchaseManager
    
    @State var currentUser: User?
    
    @State private var products: [SKProduct] = []
    
    @State private var selectedItem: Int? = nil  // Tracks the selected product
    
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
                
                // Use StoreKit products in LazyVGrid
                LazyVGrid(columns: columns, spacing: 10) {
                    if inAppPurchaseManager.products.isEmpty {
                        Text("Loading products...")
                            .font(.body)
                    } else {
                        ForEach(inAppPurchaseManager.products.indices, id: \.self) { index in
                            let product = inAppPurchaseManager.products[index] // Correctly reference the products
                            
                            Button(action: {
                                // Set the selected product to the current index
                                selectedItem = index
                            }) {
                                VStack {
                                    HStack {
                                        Image("coin")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                        Text(product.localizedTitle)
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                    // Display localized price
                                    Text(product.localizedPrice())
                                        .font(.callout)
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical,10)
                                .frame(maxWidth: .infinity, minHeight: 70)
                                .background(selectedItem == index ? Color.blue : .secondary)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(10)
            }
            .background()
            .cornerRadius(10)
            .padding(10)
            
            /*
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
             */
            
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
                    Text(selectedItem != nil ? "\(inAppPurchaseManager.products[selectedItem!].localizedPrice())" : "$0")
                        .bold()
                }
                .padding(20)
                
                Button(action: {
                    Task {
                        await purchase()
                    }
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
        .onAppear {
            Task {
                await load()
            }
        }
        .onDisappear {
            inAppPurchaseManager.stopObserving()  // Stop observing transactions
        }
    }
    
    // Fetch current user data
    func load() async {
        currentUser = await supabaseManager.getCurrentUser()
            inAppPurchaseManager.fetchProducts()
            inAppPurchaseManager.startObserving()  // Start observing transactions
    }
    
    func purchase() async {
        if let selectedIndex = selectedItem {
            let selectedProduct = inAppPurchaseManager.products[selectedIndex]
            inAppPurchaseManager.purchaseProduct(selectedProduct) { coinsPurchased in
                guard let amount = coinsPurchased else {
                    print("Purchase failed or no coins added.")
                    return
                }
                Task {
                    await supabaseManager.increaseUserBalance(amount: amount) // Add purchased amount to supabase
                    await load() // Reload currentUser to show new balance
                }
            }
        }
        
    }
    
    
}

#Preview {
    CoinShopView()
        .environmentObject(SupabaseManager())
        .environmentObject(InAppPurchaseManager())
}
