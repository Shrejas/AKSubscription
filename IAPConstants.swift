//
//  IAPConstants.swift
//  SimpleSubscriptipns
//
//  Created by IE MacBook Pro 2014 on 03/03/25.
//
import Foundation

/// Constants for In-App Purchase product identifiers.

@MainActor
public struct IAPConstants {
    
    /// Auto-Renewable Subscriptions
    public static var autoRenewable: [String] = []
    
    /// Non-Renewable Subscriptions
    public static var nonRenewable: [String] = []
    
    /// Consumable Products
    public static var consumable: [String] = []
    
    /// Non-Consumable Products
    public static var nonConsumable: [String] = []
    
    /// Set available products dynamically from an external source
    /// 
    @MainActor
    public static func configure(
        autoRenewable: [String],
        nonRenewable: [String],
        consumable: [String],
        nonConsumable: [String]
    ) {
        self.autoRenewable = autoRenewable
        self.nonRenewable = nonRenewable
        self.consumable = consumable
        self.nonConsumable = nonConsumable
        BaseStore.productIds = IAPConstants.allProducts
    }
    
    /// Returns all product identifiers as an array
    public static var allProducts: [String] {
        return autoRenewable + nonRenewable + consumable + nonConsumable
    }
}
