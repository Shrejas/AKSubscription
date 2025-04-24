//
//  ContentView.swift
//  SimpleSubscriptipns
//
//  Created by IE MacBook Pro 2014 on 26/02/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RenewableSubscriptionView()
                .tabItem {
                    Label("Renewable", systemImage: "repeat")
                }
            
            NonRenewableSubscriptionView()
                .tabItem {
                    Label("Non-Renew", systemImage: "calendar")
                }

            ConsumableProductView()
                .tabItem {
                    Label("Consumables", systemImage: "cart")
                }

            NonConsumableProductView()
                .tabItem {
                    Label("Non-Consumables", systemImage: "lock.open")
                }
        }
    }
}





