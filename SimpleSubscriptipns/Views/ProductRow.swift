import SwiftUI
import StoreKit

struct ProductRow: View {
    let product: Product
    let store: BaseStore
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.displayName)
                    .font(.headline)
                Text(product.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await purchase()
                }
            }) {
                if isPurchasing {
                    ProgressView()
                } else {
                    Text(product.displayPrice)
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            .disabled(isPurchasing)
        }
        .alert("Purchase Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
    
    private func purchase() async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            if let transaction = try await store.purchase(product) {
                print("Successfully purchased: \(transaction.productID)")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}