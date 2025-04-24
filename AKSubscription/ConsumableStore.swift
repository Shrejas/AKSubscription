//
//  ConsumableStore.swift
//  SimpleSubscriptipns
//
//  Created by IE MacBook Pro 2014 on 03/03/25.
//

import Foundation
import StoreKit

@Observable
public class ConsumableStore: BaseStore {
    
    // MARK: - Singleton Instance
    public static let shared = ConsumableStore()
    
    // MARK: - Computed Properties
    
    /// Returns a sorted list of all consumable products in descending order by price.
    public var consumableProducts: [Product] {
        allProducts
            .filter { $0.type == .consumable }
            .sorted { $0.price > $1.price }
    }
    
    // MARK: - Initializer
    
    public override init() {
        super.init()
    }
    
    // MARK: - Purchase Handling
    
    /// Initiates the purchase flow for a consumable product.
    /// - Parameters:
    ///   - product: The product to be purchased.
    ///   - completion: A closure that returns the `Transaction` on success or an `Error` on failure.
    public func purchaseProduct(
        product: Product,
        completion: @escaping (Transaction?, Error?) -> Void
    ) {
        Task {
            do {
                // Attempt to buy the product asynchronously
                await buyProduct(product) { transaction, error in
                    DispatchQueue.main.async {
                        completion(transaction, error)
                    }
                }
            } catch {
                // Log and handle error if purchase attempt fails
                logger.error("Purchase failed: \(error, privacy: .public)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
