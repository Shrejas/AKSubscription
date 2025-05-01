//
//  NonRenewableStore.swift
//  SimpleSubscriptipns
//
//  Created by IE MacBook Pro 2014 on 03/03/25.
//

import Foundation
import StoreKit

/// A store responsible for managing non-renewable in-app purchases.
/// Handles product fetching, transaction verification, and entitlement management.
public final class NonRenewableStore: BaseStore {
    
    // MARK: - Singleton
    
    /// Shared instance of `NonRenewableStore`.
    public static let shared = NonRenewableStore()
    
    // MARK: - Public Properties

    /// A sorted list of all available non-renewable products, ordered by price descending.
    public var nonRenewableProducts: [Product] {
        allProducts
            .filter { $0.type == .nonRenewable }
            .sorted { $0.price > $1.price }
    }

    /// A dictionary of valid entitlements for non-renewable purchases.
    /// Keyed by product ID.
//    @MainActor
//    public private(set) var nonRenewableEntitlements: [String: Transaction] = [:]
    @Published public private(set) var nonRenewableEntitlements: [String: Transaction] = [:]


    // MARK: - Initialization
    
    private override init() {
        super.init()
        Task {
            await loadEntitlements()
        }
    }

    // MARK: - Entitlement Management

    /// Loads and verifies all current non-renewable entitlements.
    /// Populates `nonRenewableEntitlements` with valid transactions.
    @MainActor
    public func loadEntitlements() async {
        var validEntitlements: [String: Transaction] = [:]

            for await result in Transaction.currentEntitlements {
                if let transaction = try? checkVerified(result),
                   transaction.productType == .nonRenewable {
                    validEntitlements[transaction.productID] = transaction
                }
            }

            self.nonRenewableEntitlements = validEntitlements
    }

    // MARK: - Purchase Flow

    /// Initiates a purchase for a non-renewable product.
    /// - Parameters:
    ///   - product: The product to purchase.
    ///   - completion: A closure called with the resulting transaction or error.
    public func purchaseProduct(
        product: Product,
        completion: @escaping (_ transaction: Transaction?, _ error: Error?) -> Void
    ) {
        Task {
                await buyProduct(product) {  transaction, error in
                    if let transaction {
                        Task {
                            await self.loadEntitlements()
                        }
                        DispatchQueue.main.async {
                            completion(transaction, nil)
                        }
                    } else if let error = error {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
        }
    }

    // MARK: - Transaction Verification

    /// Verifies the provided transaction result.
    /// - Parameter result: The verification result returned by StoreKit.
    /// - Returns: The verified transaction if successful.
    /// - Throws: `StoreError.failedVerification` if the transaction is not verified.
    internal override func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.failedVerification
        }
    }
}
