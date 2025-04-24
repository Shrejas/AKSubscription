// Purchase a subscription
Task {
    let result = await SubscriptionManager.shared.purchase(subscriptionId: "premium_monthly", userId: "user123")
    switch result {
    case .success:
        print("Successfully subscribed!")
    case .error(let error):
        print("Subscription failed: \(error)")
    }
}

// Check subscription status
let status = SubscriptionManager.shared.checkSubscriptionStatus(subscriptionId: "premium_monthly", userId: "user123")
if status.isActive {
    print("Subscription is active with \(status.remainingDays ?? 0) days remaining")
} else {
    print("No active subscription")
}