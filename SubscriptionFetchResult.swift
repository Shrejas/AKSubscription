//
//  SubscriptionFetchResult.swift
//  AKSubscription
//
//  Created by IE MacBook Pro 2014 on 23/04/25.
//

import Foundation

// MARK: - Subscription Result Enum

/// Represents the result of a subscription fetch request.
public enum SubscriptionFetchResult {
    case success(latest: SubscriptionPayload?, history: [SubscriptionPayload])
    case failure(String) 
}
