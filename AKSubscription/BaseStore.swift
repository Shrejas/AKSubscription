//
//  BaseStore.swift
//  SimpleSubscriptipns
//
//  Created by IE MacBook Pro 2014 on 26/02/25.
//

import Foundation
import StoreKit
import os

// MARK: - Base Store Class
@MainActor
public class BaseStore: ObservableObject {
    
    // MARK: - Properties
    
    @Published var allProducts: [Product] = []
    public static var productIds: [String] = []
    @Published public var isLoading: Bool = false
    @Published var alertMessage: String = ""
    @Published var alertType: String = ""
    @Published var showAlert: Bool = false
    @Published var subscriptionGroups: [String: [Product]] = [:]
    public let logger = Logger(subsystem: "com.infoenum.subscriptions", category: "Store")

    
    // MARK: - Initialization
    
    public init() {
        Task { await requestProducts() }
        Task.detached { [weak self] in
            await self?.listenForTransactions()
        }
    }
    
    // MARK: - Product Request
    
    /// Requests products from the App Store using identifiers from the plist.
    @MainActor
    func requestProducts() async {
        do {
            let products = try await Product.products(for: BaseStore.productIds)
            self.allProducts = products
        } catch {
            logger.error("❌ Failed product request: \(error.localizedDescription, privacy: .public)")

        }
    }
    
    // MARK: - Transaction Handling
    
    /// Continuously listens for transaction updates from the App Store.
    private func listenForTransactions() async {
        for await verification in Transaction.updates {
            do {
                let transaction = try checkVerified(verification)
                await handleTransaction(transaction)
                await transaction.finish()
            } catch {
                logger.error("❌ Transaction verification failed: \(error.localizedDescription, privacy: .public)")

            }
        }
    }
    
    /// Handles verified transactions.
    func handleTransaction(_ transaction: Transaction) async {
        DispatchQueue.main.async {
            self.logger.debug("✅ Transaction completed: \(transaction.productID, privacy: .public)")
        }
    }
    
    /// Verifies a transaction and throws if it's unverified.
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safeValue):
            return safeValue
        case .unverified:
            throw StoreError.failedVerification
        }
    }

    // MARK: - Purchase
    
    /// Initiates a purchase for the given product.
    func buyProduct(_ product: Product, completion: @escaping (Transaction?, Error?) -> Void) async {
        isLoading = true
        do {
            let result = try await product.purchase()
            switch result {
            case let .success(.verified(transaction)):
                logger.info("✅ Purchase Successful")

                logger.debug("transactionId: \(transaction.id, privacy: .public)")
                logger.debug("originalTransactionId: \(transaction.originalID, privacy: .public)")
                logger.debug("subscriptionOriginalStartDate: \(transaction.originalPurchaseDate, privacy: .public)")
                logger.debug("subscriptionStartDate: \(transaction.purchaseDate, privacy: .public)")
                logger.debug("subscriptionEndDate: \(String(describing: transaction.expirationDate), privacy: .public)")
                logger.debug("productId: \(transaction.productID, privacy: .public)")
               

                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isLoading = false
                    completion(transaction, nil)
                }
                await transaction.finish()
                
            case let .success(.unverified(_, error)):
                logger.warning("⚠️ Unverified purchase. Possibly jailbroken device. Error: \(error.localizedDescription, privacy: .public)")
                completion(nil, error)
                self.showAlert(with: error.localizedDescription, alertTitle: "Error")
                
            case .pending:
                logger.info("⏳ Transaction pending (Ask to Buy or SCA).")
                completion(nil, NSError(domain: "Store", code: 1, userInfo: [NSLocalizedDescriptionKey: "Transaction is pending."]))
                self.showAlert(with: "Transaction waiting or might be pending", alertTitle: "Error")
                
            case .userCancelled:
                logger.debug("❎ User cancelled the transaction.")
                completion(nil, NSError(domain: "Store", code: 2, userInfo: [NSLocalizedDescriptionKey: "User cancelled the transaction."]))
                isLoading = false
                
            @unknown default:
                logger.error("❌ Unknown purchase result.")
                completion(nil, NSError(domain: "Store", code: 999, userInfo: [NSLocalizedDescriptionKey: "Unknown purchase result."]))
                self.showAlert(with: "Failed to purchase the product!", alertTitle: "Error")
            }
        } catch {
            logger.error("❌ Purchase failed: \(error.localizedDescription, privacy: .public)")
            completion(nil, error)
            self.showAlert(with: error.localizedDescription, alertTitle: "Error")
        }
    }
    
    // MARK: - Product Lookup
    
    /// Returns the Product instance for a given ID, if available.
    public func getProductDetails(for id: String) -> Product? {
        return allProducts.first { $0.id == id }
    }
    
    // MARK: - App Store Environment
    
    /// Determines the current App Store environment (simulator, sandbox, production, or unknown).
    public func currentAppStoreEnvironment() -> AppStoreEnvironment {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return .unknown
        }
        
        let path = receiptURL.path
        if path.contains("/StoreKit/receipt") {
            return .simulator
        } else if receiptURL.lastPathComponent == "sandboxReceipt" {
            return .sandbox
        } else if receiptURL.lastPathComponent == "receipt" {
            return .production
        } else {
            return .unknown
        }
    }

    // MARK: - Restore Purchases
    
    /// Initiates a restore flow for previous purchases.
    public func restore(completion: @escaping (Bool, Error?) -> Void) {
        Task {
            do {
                try await AppStore.sync()
                completion(true, nil)
            } catch {
                logger.error("❌ Restore failed: \(error.localizedDescription, privacy: .public)")

                completion(false, error)
            }
        }
    }
}

// MARK: - Alert Utility
extension BaseStore {
    
    func showAlert(with message: String, alertTitle : String) {
        self.alertMessage = message
        self.alertType = alertTitle
        self.showAlert = true
        self.isLoading = false
    }
}



