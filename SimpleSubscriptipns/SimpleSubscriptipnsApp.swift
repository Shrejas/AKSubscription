//
//  SimpleSubscriptipnsApp.swift
//  SimpleSubscriptipns
//
//  Created by IE MacBook Pro 2014 on 26/02/25.
//

import SwiftUI
import _StoreKit_SwiftUI
import AKSubscription

@main
struct SimpleSubscriptipnsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    IAPConstants.configure(
                        autoRenewable: [
                            "com.infoenum.RatePulse.autoRenewableOneWeek",
                            "com.infoenum.RatePulse.autoRenewableOneMonth",
                            "com.infoenum.RatePulse.autoRenewableOneYear",
                            "com.infoenum.new.RatePulse.autoRenewableOneMonth"
                        ],
                        nonRenewable: [
                            "com.infoenum.RatePulse.NonRenewableOneWeek",
                            "com.infoenum.RatePulse.NonRenewableOneYear"
                        ],
                        consumable: [
                            "com.SimpleSubscription.coins100",
                            "com.SimpleSubscription.coins500",
                            "com.SimpleSubscription.coins1000"
                        ],
                        nonConsumable: [
                            "com.SimpleSubscription.googleAdd",
                            "com.SimpleSubscription.CustomTheme"
                        ]
                    )
                    
                   print("isRunningInSandbox",isRunningInSandbox())
                }
        }
    }
    func isRunningInSandbox() -> String {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            return ""
        }

        return appStoreReceiptURL.absoluteString
    }
}
