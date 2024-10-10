//
//  InAppPurchaseManager.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/1/24.
//

import StoreKit
import SwiftUI

class InAppPurchaseManager: NSObject, ObservableObject {
    
    @Published var products: [SKProduct] = []
    @Published var transactionState: SKPaymentTransactionState? // Track transaction state
    
    // Fetch products from the App Store
    func fetchProducts() {
        let productIDs = Set(["100coins", "250coins", "500coins", "1000coins", "2500coins", "5000coins"])  // Add more IDs as needed
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()  // Initiates the request to fetch products
    }
    
    // Purchase a product
    func purchaseProduct(_ product: SKProduct, completion: @escaping (Int?) -> Void) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        
        self.purchaseCompletionHandler = completion // Store the completion handler to call after transaction completion
    }
    
    private var purchaseCompletionHandler: ((Int?) -> Void)?
    
    // Complete a transaction (this handles adding coins and updating the user's balance)
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        // Unlock the purchased content
        let productID = transaction.payment.productIdentifier
        var coinsPurchased = 0
        
        if productID == "100coins" {
            coinsPurchased = 100
        }
        if productID == "250coins" {
            coinsPurchased = 250
        }
        if productID == "500coins" {
            coinsPurchased = 500
        }
        if productID == "1000coins" {
            coinsPurchased = 1000
        }
        if productID == "2500coins" {
            coinsPurchased = 2500
        }
        if productID == "5000coins" {
            coinsPurchased = 5000
        }
        
        print("Successfully purchased \(coinsPurchased) coins!")
        purchaseCompletionHandler?(coinsPurchased) // Notify success
        
        SKPaymentQueue.default().finishTransaction(transaction)  // Finish transaction
    }
    
    // Handle a failed transaction
    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError {
            print("Transaction failed: \(error.localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // Handle a restored transaction (if needed)
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        print("Restored purchase: \(transaction.payment.productIdentifier)")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // Start observing payment transactions
    func startObserving() {
        stopObserving()
        SKPaymentQueue.default().add(self)
    }
    
    // Stop observing payment transactions
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
}

// MARK: - SKProductsRequestDelegate
extension InAppPurchaseManager: SKProductsRequestDelegate {
    
    func getNumericPrefix(from identifier: String) -> Int {
        let numberString = identifier.prefix { $0.isNumber } // Extracts numeric prefix
        return Int(numberString) ?? 0  // Converts the prefix to Int, defaults to 0 if not found
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            
            self.products = response.products.sorted {
                self.getNumericPrefix(from: $0.productIdentifier) < self.getNumericPrefix(from: $1.productIdentifier)
            }
            
            if !response.invalidProductIdentifiers.isEmpty {
                // Print out the products with invalid ids / not found
                print("Invalid product IDs: \(response.invalidProductIdentifiers)")
            } else {
                // Print out the products found
                //print(response.products)
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to fetch products: \(error.localizedDescription)")
    }
}

// MARK: - SKPaymentTransactionObserver
extension InAppPurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                completeTransaction(transaction)  // Handle successful purchase
            case .failed:
                failedTransaction(transaction)  // Handle failure
            case .restored:
                restoreTransaction(transaction)  // Handle restored purchase
            default:
                break
            }
        }
    }
}

// MARK: - SKProduct Price Formatter
extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? "\(self.price)"
    }
}
