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

🚀 Getting Started
1. Importing AKSubscription:
```ruby
import AKSubscription
```
- The AKSubscription framework is imported to provide subscription-related functionalities, such as fetching subscription information, managing products, and handling purchase transactions.

2. Accessing RenewableStore:
```ruby
private let store = RenewableStore.shared
```
- RenewableStore is likely a singleton provided by AKSubscription to manage subscription-related data and operations.
- The shared instance is used throughout the code to access subscription-related methods and properties.

3. Fetching Subscription Information:
```ruby
let info = RenewableStore.shared.getSubscriptionInfo()
```
- The getSubscriptionInfo() method fetches subscription details, such as the latest purchased product and subscription history.
- This information is used later in the code to display subscription status and history.

4. Checking Active Subscriptions
```ruby
store.isAnySubscriptionActive = await store.isAnySubscriptionActive()
```
- The isAnySubscriptionActive() method checks if any subscription is currently active.
- This is used to update the UI and display whether the user has an active subscription.

5. Fetching Subscription Info Asynchronously
```ruby
let result = await RenewableStore.shared.fetchSubscriptionInfo()
```
- The **fetchSubscriptionInfo()** method retrieves the latest subscription information asynchronously.
- The result is handled using a **switch** statement to process success or failure cases.

6. Accessing Subscription Products
```ruby
ForEach(store.renewableProducts.values.flatMap { $0 }, id: \.id) { product in
```
- store.renewableProducts contains the list of available subscription products.
- Each product is displayed in the UI with details like name, description, and price.

7. Displaying Subscription Status
```ruby
if let payload = store.getSubscription(for: product.id) {
    if let isSubscribed = payload.isSubscribed, isSubscribed {
        Text("🟢 Subscribed")
    } else {
        Text("🔴 Subscription Expired")
    }
}
```
- The **getSubscription(for:)** method retrieves subscription details for a specific product.
- The **payload** contains information like subscription status, start date, end date, and transaction ID.

8. Restoring Purchases
```ruby
store.restorePurchases { success, error in
    if success {
        print("Restored successfully")
    }
}
```
- The restorePurchases method is used to restore previously purchased subscriptions.
- It takes a completion handler to handle success or error cases.

9. Purchasing a Product
```ruby
store.purchaseProduct(product: product) { transaction in
    print(transaction)
}
```
- The purchaseProduct(product:) method initiates the purchase of a subscription product.
- The completion handler provides the transaction details after the purchase is completed.

10. Determining App Store Environment
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

## Summary
The AKSubscription framework is used extensively in this code to:
- Fetch subscription information.
- Manage subscription products.
- Handle purchases and restore operations.
- Check subscription status and environment.
This integration ensures a seamless subscription management experience for the app.
