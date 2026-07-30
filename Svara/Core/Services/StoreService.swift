import Foundation
import StoreKit

/// Product identifiers for Svara Plus (freemium upgrade).
enum SvaraProductID {
    static let monthly = "com.svara.plus.monthly"
    static let yearly = "com.svara.plus.yearly"
    static let lifetime = "com.svara.plus.lifetime"

    static let all: [String] = [monthly, yearly, lifetime]
}

/// StoreKit 2 service for the freemium "Svara Plus" upgrade. Loads products,
/// processes purchases, listens for transactions and publishes entitlement.
///
/// In MVP there is no backend receipt validation — entitlement is derived
/// from `Transaction.currentEntitlements`, which StoreKit 2 verifies on-device.
@Observable
@MainActor
final class StoreService {
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var loadError: String?

    /// Whether the user currently has any Svara Plus entitlement.
    var isPlus: Bool { !purchasedProductIDs.isEmpty }

    /// Internal plumbing — not observed state; `nonisolated(unsafe)` so the
    /// nonisolated `deinit` can cancel it.
    @ObservationIgnored nonisolated(unsafe) private var updatesTask: Task<Void, Never>?

    init(previewPurchasedProductIDs: Set<String> = []) {
        purchasedProductIDs = previewPurchasedProductIDs
        updatesTask = listenForTransactions()
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Products

    func loadProducts() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }
        do {
            let storeProducts = try await Product.products(for: SvaraProductID.all)
            // Order: monthly, yearly, lifetime.
            products = storeProducts.sorted { $0.price < $1.price }
            await refreshEntitlements()
        } catch {
            loadError = "Couldn't load upgrade options. Please try again."
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> PurchaseOutcome {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await refreshEntitlements()
            await transaction.finish()
            return .verified
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .cancelled
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    // MARK: - Entitlements

    func refreshEntitlements() async {
        var owned: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if transaction.revocationDate == nil {
                owned.insert(transaction.productID)
            }
        }
        purchasedProductIDs = owned
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if let transaction = try? self.checkVerified(result) {
                    await self.refreshEntitlements()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum PurchaseOutcome {
    case verified
    case pending
    case cancelled
}

enum StoreError: LocalizedError {
    case failedVerification
    var errorDescription: String? {
        "We couldn't verify that purchase. Please contact support if you were charged."
    }
}
