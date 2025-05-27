# 🔁 AKSubscriptionKit

A simple Swift wrapper for managing **Renewable Subscriptions** and **Non-Consumable** purchases using `StoreKit`.

---

## 📦 Installation

Add the pod to your `Podfile`:

```ruby
pod 'AKSubscription'
```
Then run:
```ruby
pod install
```
Importing AKSubscription:
```ruby
import AKSubscription
```
- The AKSubscription framework is imported to provide subscription-related functionalities, such as fetching subscription information, managing products, and handling purchase transactions.

🚀 Getting Started
1. Accessing RenewableStore:
```ruby
//Renewable Subscription:
private let store = RenewableStore.shared
```
```ruby
//Non-Renewable Subscription:
private let store = NonRenewableStore.shared
```
```ruby
//Consumable Subscription:
private let store = ConsumableStore.shared
```
```ruby
//Non-Consumable Subscription:
private let store = NonConsumableStore.shared
```
- Singleton provided by AKSubscription to manage subscription-related data and operations.
- The shared instance is used throughout the code to access subscription-related methods and properties.

2. Fetching Subscription Information:
```ruby
let info = RenewableStore.shared.getSubscriptionInfo()
```
- The getSubscriptionInfo() method fetches subscription details, such as the latest purchased product and subscription history.
- This information is used later in the code to display subscription status and history.

3. Checking Active Subscriptions
```ruby
store.isAnySubscriptionActive = await store.isAnySubscriptionActive()
```
- The isAnySubscriptionActive() method checks if any subscription is currently active.
- This is used to update the UI and display whether the user has an active subscription.

4. Fetching Subscription Info Asynchronously
```ruby
let result = await RenewableStore.shared.fetchSubscriptionInfo()
```
- The **fetchSubscriptionInfo()** method retrieves the latest subscription information asynchronously.
- The result is handled using a **switch** statement to process success or failure cases.

5. Determining App Store Environment
```ruby
let environment = store.currentAppStoreEnvironment()
switch environment {
case .simulator:
    print("🛠 Simulator StoreKit Environment")
case .sandbox:
    print("🧪 Sandbox Environment")
case .production:
    print("🚀 Production Environment")
}
```
- The currentAppStoreEnvironment() method determines the current App Store environment (e.g., simulator, sandbox, or production).
- This is useful for debugging and testing purposes.

```ruby
.onAppear {
    store.isLoading = true
     DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
        Task{
            store.isAnySubscriptionActive =  await store.isAnySubscriptionActive()

            if let latest = info.latestProduct {
                print("🔥 Latest Purchased: \(latest.productId ?? "Unknown")")
            }
            for item in info.history {
                print("💳 Product: \(item.productId ?? "N/A"), Subscribed: \(item.isSubscribed)")
            }
            let result = await RenewableStore.shared.fetchSubscriptionInfo()
            switch result {
            case .success(let latest, _):
                print(latest)
            case .failure(let error):
                print(error)
            }
            await store.waitForProductsAndUpdateStatus()
            store.isLoading = false
        }
        let environment = store.currentAppStoreEnvironment()

        switch environment {
        case .simulator:
            print("🛠 Simulator StoreKit Environment")
        case .sandbox:
            print("🧪 Sandbox Environment (Real Device + Test Apple ID)")
        case .production:
            print("🚀 Production Environment")
        case .unknown:
            print("❓ Unknown App Store Environment")
        }
    })
}
```

6. Accessing Subscription Products and Displaying Subscription Status
- Renewable Subscription:
```ruby
ForEach(store.renewableProducts.values.flatMap { $0 }, id: \.id) { product in
    VStack {
        print(product.displayName)
        print(product.description)
        print(product.displayPrice)
                           
        if let payload = store.getSubscription(for: product.id) {
            if let endDate = payload.subscriptionEndDate {
                if let isLatest = payload.isLatestPurchased, isLatest {
                    print("✅ Active Subscription")
                } else if let isSubscribed = payload.isSubscribed, isSubscribed {
                    print("🟢 Subscribed (Not Latest)")
                } else {
                    print("🔴 Subscription Expired")
                }
                                    
                // ✅ Additional Info (Optional)
                if let originalTransactionId = payload.originalTransactionId {
                    print("Transaction ID: \(originalTransactionId)")
                }
                                    
                if let productId = payload.productId {
                    print("Product ID: \(productId)")
                }
                                    
                if let purchaseDate = payload.subscriptionStartDate {
                    print("Purchased On: \(purchaseDate)")
                }
                                    
                if let endDate = payload.subscriptionEndDate {
                    print("Expires On: \(endDate)")
                }
            }
        }
    }
}
```
- Non-Renewable Subscription:
```ruby
ForEach(store.nonRenewableProducts, id: \.id) { product in
    VStack {
        print(product.displayName)
        print(product.description)
        print(product.displayPrice)
                                        
        if let transaction = store.nonRenewableEntitlements[product.id] {
            let purchaseDate = transaction.purchaseDate
            print("OriginalID:-\(transaction.originalID)")
            print("ID:-\(transaction.id)")
            print("PurchaseDate:\(transaction.purchaseDate)")
        }
    }                                    
}
```
- Consumable Subscription:
```ruby
//
ForEach(store.consumableProducts, id: \.id) { product in
    VStack {
        print(product.displayName)
        print(product.description)
        print(product.displayPrice)
    }
}
```
- Non-Consumable Subscription:
```ruby
ForEach(store.nonConsumableProducts, id: \.id) { product in
    VStack {
        print(product.displayName)
        print(product.description)
        print(product.displayPrice)
    }
    
    if purchasedProductIDs.contains(product.id) {
        print("Purchased")
    }
}
```
- The list of available subscription products.
- Each product is displayed in the UI with details like name, description, and price.

7. Restoring Purchases
```ruby
store.restorePurchases { success, error in
    if success {
        print("Restored successfully")
    }
}
```
- The restorePurchases method is used to restore previously purchased subscriptions.
- It takes a completion handler to handle success or error cases.

8. Purchasing a Product
```ruby
store.purchaseProduct(product: product) { transaction in
    print(transaction)
}
```
- The purchaseProduct(product:) method initiates the purchase of a subscription product.
- The completion handler provides the transaction details after the purchase is completed.

9. Loding Property:
```ruby
store.isLoading = true
 store.isLoading = false

if store.isLoading {
    //....
} else {
    //...
}
```

## Summary
The AKSubscription framework is used extensively in this code to:
- Fetch subscription information.
- Manage subscription products.
- Handle purchases and restore operations.
- Check subscription status and environment.
This integration ensures a seamless subscription management experience for the app.
