//
//  InAppPurchaseManager.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/1/24.
//

import StoreKit

class InAppPurchaseManager: NSObject, SKProductsRequestDelegate {
    
    static let shared = InAppPurchaseManager()

    // Store the products fetched from the App Store
    @Published var products: [SKProduct] = []
    
    func fetchProducts() {
        let productIDs = Set(["com.Bopito.coins100"])
        
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()  // Initiates the request to fetch products
    }
    
    // SKProductsRequestDelegate - This method is called when the product info is received
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
                    self.products = response.products
                    
                    // Debugging: Check if products are loaded
                    print("Loaded products: \(self.products)")
                }
                
                if !response.invalidProductIdentifiers.isEmpty {
                    print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
                }
    }
    
    // Handle errors
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load products: \(error.localizedDescription)")
    }
}

extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? "$\(self.price)"
    }
}

extension InAppPurchaseManager: SKPaymentTransactionObserver {
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
    
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Handle successful purchase
                complete(transaction: transaction)
            case .failed:
                // Handle failed purchase
                failed(transaction: transaction)
            case .restored:
                // Handle restoring purchases
                restore(transaction: transaction)
            default:
                break
            }
        }
    }
    
    func complete(transaction: SKPaymentTransaction) {
        // Unlock the purchased content for the user
        print("Purchase successful!")
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func failed(transaction: SKPaymentTransaction) {
        // Handle a failed transaction
        if let error = transaction.error as? SKError {
            print("Failed to purchase: \(error.localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func restore(transaction: SKPaymentTransaction) {
        // Handle a restored purchase
        print("Restored purchase: \(transaction.payment.productIdentifier)")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
