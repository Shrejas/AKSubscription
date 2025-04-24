enum SubscriptionPeriod {
    case weekly
    case monthly
    case yearly
    case custom(days: Int)
}