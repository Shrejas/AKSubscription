//
//  NonRenewableSubscriptionView.swift
//  SimpleSubscriptipns
//
//  Created by IE15 on 06/03/25.
//

import SwiftUI
import AKSubscription


struct NonRenewableSubscriptionView: View {
    @StateObject private var store = NonRenewableStore.shared
    @State private var expiryDate: Date?
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    if store.nonRenewableProducts.isEmpty {
                        Text("Loading Non renewable subscriptions...")
                    } else {
                        Text("Non Renewable Products")
                            .font(.largeTitle)
                        ForEach(store.nonRenewableProducts, id: \.id) { product in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.displayName)
                                            .font(.headline)
//                                        Text(product.description)
//                                            .font(.subheadline)
                                        Text(product.displayPrice)
                                            .font(.subheadline)
                                        
                                        
                                        if let transaction = store.nonRenewableEntitlements[product.id] {
                                         
                                            let purchaseDate = transaction.purchaseDate
                                            let expiryDate = expiryDate(for: transaction.productID, purchaseDate: purchaseDate)
                                          //  VStack {
                                                    Text("OriginalID:-\(transaction.originalID)")
                                                    .font(.footnote)
                                                Text("ID:-\(transaction.id)")
                                                    .font(.footnote)
                                                Text("PurchaseDate:\(transaction.purchaseDate)")
                                                    .font(.footnote)
                                                
                                                
                                            if let expirationDate = expiryDate, expirationDate > Date() {
                                                Text("ExpiryDate: \(expirationDate)")
                                                    .font(.footnote)
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            } else {
                                                Text("Expired")
                                                    .foregroundColor(.red)
                                                    .font(.footnote)
                                                    .padding(6)
                                                    .background(Color.red.opacity(0.1))
                                                    .cornerRadius(8)
                                            }
                                      //  }
                                        }
                                    }
                                    
                                    
                                    
                                    Spacer()
                                    
                                }
                                
                                Button("Subscribe") {
                                    store.purchaseProduct(product: product) { transaction, error in
                                        if let error = error {
                                            print("❌ Error: \(error.localizedDescription)")
                                            return
                                        }
                                        if let transaction = transaction {
                                            print("✅ Transaction: \(transaction)")
                                        }
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal)

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
    
    func expiryDate(for productId: String, purchaseDate: Date) -> Date?{
        var dateComponent = DateComponents()
        if productId.contains("Week") {
            dateComponent.weekOfYear = 1
        } else if productId.contains("Month") {
            dateComponent.month = 1
        } else if productId.contains("Year") {
            dateComponent.year = 1
        }
        return Calendar.current.date(byAdding: dateComponent, to: purchaseDate)
    }

}

#Preview {
    NonRenewableSubscriptionView()
}
