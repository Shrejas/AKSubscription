//
//  NonConsumableStore.swift
//  SimpleSubscriptipns
//
//  Created by IE MacBook Pro 2014 on 03/03/25.
//

import Foundation
import StoreKit

/// A store responsible for managing non-consumable in-app purchases.
/// Supports purchase flow and entitlement verification.
@Observable
public final class NonConsumableStore: BaseStore {
    
    // MARK: - Singleton
    
    /// Shared instance of `NonConsumableStore`.
    public static let shared = NonConsumableStore()
    
    // MARK: - Public Properties
    
    /// A sorted list of all available non-consumable products, ordered by price descending.
    public var nonConsumableProducts: [Product] {
        allProducts
            .filter { $0.type == .nonConsumable }
            .sorted { $0.price > $1.price }
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
    }
    
    // MARK: - Purchase Flow
    
    /// Initiates a purchase for a non-consumable product.
    /// - Parameters:
    ///   - product: The product to purchase.
    ///   - completion: A closure called with the resulting transaction or error.
    public func purchaseProduct(
        product: Product,
        completion: @escaping (_ transaction: Transaction?, _ error: Error?) -> Void
    ) {
        Task { [weak self] in
            guard let self else { return }
            
                await self.buyProduct(product) { transaction, error in
                    if let transaction {
                        DispatchQueue.main.async {
                            completion(transaction, nil)
                        }
                    } else if let error {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
        }
    }
    
    // MARK: - Entitlement Verification
    
    /// Checks if a non-consumable product has already been purchased and is still valid.
    /// - Parameter product: The product to check.
    /// - Returns: `true` if the product has been purchased and not revoked, otherwise `false`.
    public func isProductPurchased(_ product: Product) async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == product.id,
               transaction.revocationDate == nil {
                return true
            }
        }
        return false
    }
}
