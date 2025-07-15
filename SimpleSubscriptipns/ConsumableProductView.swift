//
//  ConsumableProductView.swift
//  SimpleSubscriptipns
//
//  Created by IE15 on 06/03/25.
//

import SwiftUI
import AKSubscription

struct ConsumableProductView: View {
   @StateObject private var store = ConsumableStore.shared
    @State var userCoins: Int = UserDefaults.standard.integer(forKey: "userCoins")
    @State var showAlert = false
    var body: some View {
        ZStack {
            ScrollView {
                
                VStack {
                    Text("Consumable Products")
                        .font(.largeTitle)
                    Text("Coins : \(userCoins)")
                    if store.consumableProducts.isEmpty {
                        Text("Loading consumable subscriptions...")
                    } else {
                        ForEach(store.consumableProducts, id: \.id) { product in
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
                                
                                Button("Subscribe") {
                                    store.purchaseProduct(product: product) { transaction, error  in
                                        if let error = error {
                                            print(error.localizedDescription)
                                            return
                                        }
                                        
                                        if let transaction = transaction {
                                            
                                            if "\(transaction.productID)" == "com.SimpleSubscription.coins100" {
                                                UserDefaults.standard.set(100 + self.userCoins, forKey: "userCoins")
                                            } else if "\(transaction.productID)" == "com.SimpleSubscription.coins500" {
                                                UserDefaults.standard.set(500 + self.userCoins, forKey: "userCoins")
                                            } else if "\(transaction.productID)" == "com.SimpleSubscription.coins1000" {
                                                UserDefaults.standard.set(1000 + self.userCoins, forKey: "userCoins")
                                            }
                                            //
                                            //                                        // ✅ Save coins to UserDefaults
                                            self.userCoins = UserDefaults.standard.integer(forKey: "userCoins")
                                            self.showAlert = true
                                        }
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.vertical)
                            .alert("Purchase Successful! \(self.userCoins)", isPresented: $showAlert) {
                                Button("OK", role: .cancel) { }
                            }
                        }
                    }
                }
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
}

#Preview {
    ConsumableProductView()
}
