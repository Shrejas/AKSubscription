enum SubscriptionResult {
    case success
    case error(SubscriptionError)
}

enum SubscriptionError: Error {
    case invalidSubscription
    case paymentFailed
    case alreadySubscribed
    case notSubscribed
    case networkError
    case unknown
}