//
//  RenewableStore.swift
//  SimpleSubscriptipns
//
//  Created by IE MacBook Pro 2014 on 03/03/25.
//
import Foundation
import StoreKit

// MARK: - Renewable Store (Auto-Renewable Subscription Handler)

@Observable
public class RenewableStore: BaseStore {
    
    // MARK: - Singleton Instance
    public static var shared = RenewableStore()
    
    // MARK: - Public Properties
    public var isAnySubscriptionActive: Bool = false
    
    /// Dictionary of renewable products grouped by their subscriptionGroupID.
    public var renewableProducts: [String: [Product]] {
        var groupedSubscriptions: [String: [Product]] = [:]
        let autoRenewable = allProducts
            .filter { $0.type == .autoRenewable }
            .sorted { $0.price > $1.price }

        for product in autoRenewable {
            if let groupID = product.subscription?.subscriptionGroupID {
                groupedSubscriptions[groupID, default: []].append(product)
            }
        }

        return groupedSubscriptions
    }
    
    public var productsHistory: [SubscriptionPayload] = []
    
    // MARK: - Initializer
    public override init() {
        super.init()
        Task {
            await waitForProductsAndUpdateStatus()
        }
    }

    // MARK: - Purchase Flow

    /// Purchases a given product and updates the subscription state.
    public func purchaseProduct(product: Product, completion: @escaping (Transaction) -> Void) {
        Task {
          //  do {
                await buyProduct(product) { transaction, error in
                    guard let transaction = transaction else { return }

                    Task {
                        self.productsHistory.removeAll()
                        
                        guard !self.renewableProducts.isEmpty else { return }

                        var tempProductsHistory: [SubscriptionPayload] = []

                        for (_, products) in self.renewableProducts {
                            for product in products {
                                if let payload = await self.fetchSubscriptionStatus(for: product.id) {
                                    tempProductsHistory.append(payload)
                                }
                            }
                        }

                        await self.updateLatestPurchaseProduct(tempProductsHistory: &tempProductsHistory)
                        self.productsHistory = tempProductsHistory
                    }

                    DispatchQueue.main.async {
                        completion(transaction)
                    }
                }
//            } catch {
//                logger.error("❌ Purchase failed: \(error, privacy: .public)")
//                showAlert(with: "Purchase failed: \(error)", alertTitle: "Error")
//                isLoading = false
//            }
        }
    }

    // MARK: - Subscription Check

    /// Checks whether any subscription is currently active.
    public func isAnySubscriptionActive() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               let expirationDate = transaction.expirationDate,
               expirationDate > Date() {
                return true
            }
        }
        return false
    }

    /// Returns active subscription details for a specific subscription group.
    public func activeSubscription(forGroupID groupID: String) async -> (isActive: Bool, payload: SubscriptionPayload?) {
       // do {
            while allProducts.isEmpty {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 sec
            }

            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   let product = allProducts.first(where: { $0.id == transaction.productID }),
                   product.type == .autoRenewable,
                   product.subscription?.subscriptionGroupID == groupID,
                   let expirationDate = transaction.expirationDate,
                   expirationDate > Date() {

                    let payload = SubscriptionPayload(
                        isLatestPurchased: true,
                        isSubscribed: true,
                        transactionId: "\(transaction.id)",
                        originalTransactionId: "\(transaction.originalID)",
                        subscriptionStartDate: transaction.purchaseDate.description,
                        subscriptionEndDate: expirationDate.description,
                        productId: transaction.productID
                    )

                    return (true, payload)
                }
            }

//        } catch {
//            logger.error(("❌ Error checking active subscription for group \(groupID): \(error, privacy: .public)"))
//        }

        return (false, nil)
    }

    /// Fetches subscription info: latest purchase and history.
    public func fetchSubscriptionInfo() async -> SubscriptionFetchResult {
      //  do {
            var tempHistory: [SubscriptionPayload] = []
            var latestProductIDs: Set<String> = []

            while allProducts.isEmpty {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 sec
            }

            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   let product = allProducts.first(where: { $0.id == transaction.productID }),
                   product.type == .autoRenewable {

                    let payload = SubscriptionPayload(
                        isLatestPurchased: true,
                        isSubscribed: transaction.expirationDate.map { $0 > Date() } ?? false,
                        transactionId: "\(transaction.id)",
                        originalTransactionId: "\(transaction.originalID)",
                        subscriptionStartDate: transaction.purchaseDate.description,
                        subscriptionEndDate: transaction.expirationDate?.description,
                        productId: transaction.productID
                    )

                    tempHistory.append(payload)
                    latestProductIDs.insert(transaction.productID)
                }
            }

            guard !tempHistory.isEmpty else {
                return .failure("No active subscriptions found.")
            }

            let latest = tempHistory.first(where: { latestProductIDs.contains($0.productId ?? "") })
            return .success(latest: latest, history: tempHistory)

//        } catch {
//            return .failure("Failed to fetch subscription info: \(error.localizedDescription)")
//        }
    }

    // MARK: - Subscription Status & History

    /// Waits for product load and updates subscription status.
    public func waitForProductsAndUpdateStatus() async {
        while allProducts.isEmpty {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
        }

        productsHistory.removeAll()
        var tempHistory: [SubscriptionPayload] = []

        for (_, products) in renewableProducts {
            for product in products {
                if let payload = await fetchSubscriptionStatus(for: product.id) {
                    tempHistory.append(payload)
                }
            }
        }

        await updateLatestPurchaseProduct(tempProductsHistory: &tempHistory)
        productsHistory = tempHistory
    }

    /// Fetches subscription status for a specific product.
    @MainActor
    func fetchSubscriptionStatus(for productID: String) async -> SubscriptionPayload? {
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first, let subscription = product.subscription else {
                logger.debug("❌ Product \(productID) is not a subscription")
                return SubscriptionPayload(
                    isLatestPurchased: false, isSubscribed: false,
                    transactionId: nil, originalTransactionId: nil,
                    subscriptionStartDate: nil, subscriptionEndDate: nil,
                    productId: productID
                )
            }

            let result = await Transaction.latest(for: productID)
            let transaction = result.flatMap { try? checkVerified($0) }


            let statuses = try await subscription.status

            for status in statuses {
                switch status.state {
                case .subscribed, .inBillingRetryPeriod:
                    return SubscriptionPayload(
                        isLatestPurchased: false,
                        isSubscribed: transaction?.expirationDate.map { $0 > Date() } ?? false,
                        transactionId: "\(transaction?.id ?? 0)",
                        originalTransactionId: "\(transaction?.originalID ?? 0)",
                        subscriptionStartDate: transaction?.purchaseDate.description,
                        subscriptionEndDate: transaction?.expirationDate?.description,
                        productId: productID
                    )

                case .expired:
                    logger.debug("❌ Subscription \(productID) expired")
                    return SubscriptionPayload(
                        isLatestPurchased: false, isSubscribed: false,
                        transactionId: "\(transaction?.id ?? 0)",
                        originalTransactionId: "\(transaction?.originalID ?? 0)",
                        subscriptionStartDate: transaction?.purchaseDate.description,
                        subscriptionEndDate: transaction?.expirationDate?.description,
                        productId: productID
                    )

                default:
                    return nil
                }
            }
        } catch {
            logger.error("❌ Failed to fetch subscription status: \(error, privacy: .public)")
        }
        return nil
    }

    /// Updates the flag for the latest purchased product in the given history.
    func updateLatestPurchaseProduct(tempProductsHistory: inout [SubscriptionPayload]) async {
        var latestProductIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                latestProductIDs.insert(transaction.productID)
            }
        }

        for i in 0..<tempProductsHistory.count {
            tempProductsHistory[i].isLatestPurchased = latestProductIDs.contains(tempProductsHistory[i].productId ?? "")
        }
    }

    // MARK: - Public Getters

    /// Returns the most recently purchased subscription product.
    public func getLatestPurchasedProduct() -> SubscriptionPayload? {
        return productsHistory.first(where: { $0.isLatestPurchased ?? false })
    }

    /// Returns the latest purchased subscription and full history.
    public func getSubscriptionInfo() -> (latestProduct: SubscriptionPayload?, history: [SubscriptionPayload]) {
        return (getLatestPurchasedProduct(), productsHistory)
    }

    /// Returns a subscription from history for the given product ID.
    public func getSubscription(for productId: String) -> SubscriptionPayload? {
        return productsHistory.first { $0.productId == productId }
    }
}


//MARK: - Restore Purchase
extension RenewableStore {
    /// Restores previous purchases from the App Store and updates subscription status.
    /// - Parameter completion: A closure that returns `true` if restore was successful, `false` otherwise.

    public func restorePurchases(completion: @escaping (Bool, Error?) -> Void) {
        Task {
            do {
                let results: () = try await AppStore.sync()
                logger.debug("🛠 Restore results: \(String(describing: results), privacy: .public)")

                
                await waitForProductsAndUpdateStatus()
                completion(true, nil)
            } catch {
                logger.error("❌ Restore failed: \(error, privacy: .public)")
                completion(false, error)
            }
        }
    }
}
