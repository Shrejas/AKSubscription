//
//  SubscriptionPayload.swift
//  AKSubscription
//
//  Created by IE MacBook Pro 2014 on 23/04/25.
//

import Foundation

// MARK: - Subscription Payload Model

public struct SubscriptionPayload: Codable {
    public var isLatestPurchased: Bool?
    public let isSubscribed: Bool?
    public let transactionId: String?
    public let originalTransactionId: String?
    public let subscriptionStartDate: String?
    public let subscriptionEndDate: String?
    public let productId: String? 
}
