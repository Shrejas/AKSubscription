//
//  NonConsumableProductView.swift
//  SimpleSubscriptipns
//
//  Created by IE15 on 06/03/25.
//

import SwiftUI
import AKSubscription

struct NonConsumableProductView: View {
    @State private var purchasedProductIDs: Set<String> = []
    @StateObject private var store = NonConsumableStore.shared

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Text("NonConsumable Products")
                        .font(.largeTitle)

                    if store.nonConsumableProducts.isEmpty {
                        Text("Loading consumable subscriptions...")
                    } else {
                        ForEach(store.nonConsumableProducts, id: \.id) { product in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.displayName)
                                            .font(.headline)
                                        Text(product.description)
                                            .font(.subheadline)
                                        Text(product.displayPrice)
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                }

                                if purchasedProductIDs.contains(product.id) {
                                    Text("Purchased")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                } else {
                                    Button("Buy") {
                                        store.purchaseProduct(product: product) { transaction, error in
                                            if let error = error {
                                                print(error.localizedDescription)
                                                return
                                            }
                                            if let transaction = transaction {
                                                print(transaction)
                                                purchasedProductIDs.insert(product.id)
                                            }
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .onAppear {
                Task {
                    var owned = Set<String>()
                    for product in store.nonConsumableProducts {
                        let isOwned = await store.isProductPurchased(product)
                        if isOwned {
                            owned.insert(product.id)
                        }
                    }
                    purchasedProductIDs = owned
                }
            }

            if store.isLoading {
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
        }
    }
}
