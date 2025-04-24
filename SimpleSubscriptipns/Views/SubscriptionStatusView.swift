import SwiftUI
import StoreKit

struct SubscriptionStatusView: View {
    @StateObject private var renewableStore = RenewableStore()
    
    var body: some View {
        VStack {
            if renewableStore.isSubscriptionActive() {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.largeTitle)
                    Text("Active Subscription")
                        .font(.headline)
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                    Text("No Active Subscription")
                        .font(.headline)
                    NavigationLink("View Plans", destination: StoreView())
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                await renewableStore.updateSubscriptionStatus()
            }
        }
    }
}