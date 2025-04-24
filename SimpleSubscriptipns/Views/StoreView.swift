import SwiftUI
import StoreKit

struct ProductSection: View {
    let title: String
    let products: [Product]
    let store: BaseStore
    
    var body: some View {
        if !products.isEmpty {
            Section(title) {
                ForEach(products) { product in
                    ProductRow(product: product, store: store)
                }
            }
        }
    }
}

struct StoreView: View {
    @StateObject private var consumableStore = ConsumableStore()
    @StateObject private var nonConsumableStore = NonConsumableStore()
    @StateObject private var renewableStore = RenewableStore()
    @StateObject private var nonRenewableStore = NonRenewableStore()
    
    var body: some View {
        NavigationView {
            List {
                ProductSection(title: "Subscriptions", 
                              products: renewableStore.renewableProducts,
                              store: renewableStore)
                
                ProductSection(title: "Consumable Products", 
                              products: consumableStore.consumableProducts,
                              store: consumableStore)
                
                ProductSection(title: "One-Time Purchases", 
                              products: nonConsumableStore.nonConsumableProducts,
                              store: nonConsumableStore)
            }
            .navigationTitle("Store")
        }
    }
}