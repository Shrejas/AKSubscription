//
//  RenewableSubscriptionsView.swift
//  SimpleSubscriptipns
//
//  Created by IE MacBook Pro 2014 on 03/03/25.
//

import Foundation
import SwiftUI
import AKSubscription
import StoreKit

struct RenewableSubscriptionView: View {
    private let store = RenewableStore.shared
    let info = RenewableStore.shared.getSubscriptionInfo()
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    if store.renewableProducts.isEmpty {
                        subscriptionLoadingView
                    } else {
                        productListView
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
                    }
                }
                .padding(.bottom,50)
                
            }
            .padding(.horizontal)
            if store.isLoading {
                loadingView
            }
        }
    }
}


//MARK: - Extension
extension RenewableSubscriptionView {
    //MARK: - Private Views
    private var loadingView : some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            Spacer()
        }
        .background(.black.opacity(0.3))
    }
    
    private var restoreButton: some View {
        VStack {
            Button {
                store.isLoading = true
                store.restorePurchases { success, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    store.isLoading = false
                    if success {
                        print("Restored successFully")
                    }
                }
            } label: {
                HStack {
                    Text("Restore")
                        .padding(5)
                        .foregroundColor(.white)
                }.background(.blue)
                    .cornerRadius(5)
            }
        }
    }
    
    
    private var subscriptionLoadingView: some View {
        Text("Loading renewable subscriptions...")
    }
    
    private var productListView: some View {
        VStack {
            
            Text("Renewable Products")
                .font(.largeTitle)
            
            Text("isUserSubscribed = \(store.isAnySubscriptionActive ? "true" : "false" ) ")
                .font(.title3)
            
            
            
            ForEach(store.renewableProducts.values.flatMap { $0 }, id: \.id) { product in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.displayName)
                                .font(.headline)
                            Text(product.description)
                                .font(.subheadline)
                            Text(product.displayPrice)
                                .font(.subheadline)
                           
                            if let payload = store.getSubscription(for: product.id) {
                                if let endDate = payload.subscriptionEndDate {
                                    if let isLatest = payload.isLatestPurchased, isLatest {
                                        Text("✅ Active Subscription")
                                            .font(.footnote)
                                            .foregroundColor(.green)
                                    } else if let isSubscribed = payload.isSubscribed, isSubscribed {
                                        Text("🟢 Subscribed (Not Latest)")
                                            .font(.footnote)
                                            .foregroundColor(.green)
                                    } else {
                                        Text("🔴 Subscription Expired")
                                            .font(.footnote)
                                            .foregroundColor(.red)
                                    }
                                    
                                    // ✅ Additional Info (Optional)
                                    if let originalTransactionId = payload.originalTransactionId {
                                        Text("Transaction ID: \(originalTransactionId)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    if let productId = payload.productId {
                                        Text("Product ID: \(productId)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    if let purchaseDate = payload.subscriptionStartDate {
                                        Text("Purchased On: \(purchaseDate)")
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    if let endDate = payload.subscriptionEndDate {
                                        Text("Expires On: \(endDate)")
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                    }
                                    
                                }
                            }
                           
                        }
                        Spacer()
                    }
                    /// Subscription Button View
                    subscribeButtonView(for: product)
                }
                .padding(.vertical)
            }
            ///Restore Button View
            restoreButton
        }
    }
    
    private func subscribeButtonView(for product: Product) -> some View {
        Button("Subscribe") {
            print("Product To Purchase Name = \(product.displayName)")
            print("Product To Purchase Price = \(product.displayPrice)")
            print("Product To Purchase Id = \(product.id)")
            
            store.purchaseProduct(product: product) { transaction in
                print(transaction)
                Task {
                    store.isAnySubscriptionActive = await store.isAnySubscriptionActive()
                }
            }
        }
        .buttonStyle(.borderedProminent)
    }
}

