import SwiftUI
import StoreKit

/// The freemium upgrade screen, driven by `StoreService` (StoreKit 2).
struct PaywallView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?
    @State private var noticeMessage: String?

    private let benefits = [
        ("infinity", "Every lesson", "The full learning path, including premium tracks."),
        ("book.fill", "All stories", "Unlock the complete library of stories & symbols."),
        ("sparkles", "Everything new", "New lessons, stories and festival guides as they're added — included."),
        ("heart.fill", "Support Svara", "Help a small team build mindful, ad-free tools.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SvaraTheme.Spacing.xl) {
                    hero
                    benefitsList
                    productList
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.svaraCaption)
                            .foregroundStyle(.red)
                    }
                    if let noticeMessage {
                        Text(noticeMessage)
                            .font(.svaraCaption)
                            .foregroundStyle(SvaraTheme.Colors.textSecondary)
                    }
                    purchaseButton
                    Button {
                        Task { await restorePurchases() }
                    } label: {
                        if isRestoring {
                            ProgressView()
                        } else {
                            Text("Restore Purchases")
                        }
                    }
                    .disabled(isRestoring || isPurchasing)
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)

                    Text(purchaseDisclosure)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)

                    HStack {
                        Link("Privacy Policy", destination: SvaraLinks.privacyPolicy)
                        Text("•")
                        Link("Terms of Service", destination: SvaraLinks.termsOfService)
                    }
                    .font(.caption2)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
                }
                .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
                .padding(.vertical, SvaraTheme.Spacing.lg)
            }
            .svaraScreenBackground()
            .navigationTitle("Svara Plus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                        .tint(SvaraTheme.Colors.textSecondary)
                }
            }
        }
        .task {
            if env.store.products.isEmpty { await env.store.loadProducts() }
            selectedProduct = env.store.products.first
        }
        .onChange(of: env.store.isPlus) { _, isPlus in
            if isPlus { dismiss() }
        }
    }

    private var hero: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            ZStack {
                Circle().fill(SvaraTheme.Gradients.saffron).frame(width: 88, height: 88)
                Image(systemName: "star.fill").font(.system(size: 40)).foregroundStyle(.white)
            }
            Text("Go deeper with Svara Plus")
                .font(.svaraTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
        }
        .padding(.top, SvaraTheme.Spacing.md)
    }

    private var benefitsList: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            ForEach(benefits, id: \.0) { icon, title, detail in
                HStack(spacing: SvaraTheme.Spacing.lg) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(SvaraTheme.Colors.primary)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.svaraHeadline).foregroundStyle(SvaraTheme.Colors.textPrimary)
                        Text(detail).font(.svaraCallout).foregroundStyle(SvaraTheme.Colors.textSecondary)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    @ViewBuilder
    private var productList: some View {
        if env.store.isLoading {
            ProgressView().padding()
        } else if env.store.products.isEmpty {
            Text("Upgrade options aren't available right now. Please try again later.")
                .font(.svaraCallout)
                .multilineTextAlignment(.center)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
                .padding(.vertical)
        } else {
            VStack(spacing: SvaraTheme.Spacing.md) {
                ForEach(env.store.products, id: \.id) { product in
                    ProductRow(product: product, isSelected: selectedProduct?.id == product.id) {
                        selectedProduct = product
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var purchaseButton: some View {
        if env.isPremium {
            Label("You're a Plus member", systemImage: "checkmark.seal.fill")
                .font(.svaraHeadline)
                .foregroundStyle(SvaraTheme.Colors.success)
        } else {
            PrimaryButton(
                title: purchaseButtonTitle,
                isLoading: isPurchasing,
                isEnabled: selectedProduct != nil
            ) { Task { await purchase() } }
        }
    }

    private func purchase() async {
        guard let product = selectedProduct else { return }
        errorMessage = nil
        noticeMessage = nil
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            switch try await env.store.purchase(product) {
            case .verified:
                if env.store.isPlus { dismiss() }
            case .pending:
                noticeMessage = "Your purchase is pending approval. Access will unlock after Apple confirms it."
            case .cancelled:
                break
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func restorePurchases() async {
        errorMessage = nil
        noticeMessage = nil
        isRestoring = true
        defer { isRestoring = false }
        do {
            try await env.store.restorePurchases()
            if env.store.isPlus {
                dismiss()
            } else {
                noticeMessage = "No active purchases were found for this Apple ID."
            }
        } catch {
            errorMessage = "Purchases couldn't be restored. Please try again."
        }
    }

    private var purchaseButtonTitle: String {
        guard let selectedProduct else { return "Select an option" }
        if selectedProduct.type == .nonConsumable {
            return "Buy Lifetime Access — \(selectedProduct.displayPrice)"
        }
        return "Subscribe — \(selectedProduct.displayPrice)"
    }

    private var purchaseDisclosure: String {
        guard let selectedProduct else {
            return "Payment will be charged to your Apple ID after you select and confirm an option."
        }
        if selectedProduct.type == .nonConsumable {
            return "This is a one-time purchase charged to your Apple ID."
        }
        return "Payment is charged to your Apple ID. The subscription renews automatically unless cancelled at least 24 hours before the end of the period."
    }
}

private struct ProductRow: View {
    let product: Product
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(.svaraHeadline)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                    Text(product.description)
                        .font(.svaraCaption)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.accent)
            }
            .padding(SvaraTheme.Spacing.lg)
            .background(isSelected ? SvaraTheme.Colors.primary.opacity(0.1) : SvaraTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                    .strokeBorder(isSelected ? SvaraTheme.Colors.primary : SvaraTheme.Colors.separator, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView().environment(AppEnvironment.preview())
}
