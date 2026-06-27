import SwiftUI

/// A soft, rounded container that is the visual building block across Svara.
/// Wraps arbitrary content in a padded, shadowed surface.
struct SvaraCard<Content: View>: View {
    var background: Color = SvaraTheme.Colors.surface
    var padding: CGFloat = SvaraTheme.Spacing.lg
    var cornerRadius: CGFloat = SvaraTheme.Radius.lg
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
            )
            .shadow(
                color: SvaraTheme.Shadow.card.color,
                radius: SvaraTheme.Shadow.card.radius,
                x: SvaraTheme.Shadow.card.x,
                y: SvaraTheme.Shadow.card.y
            )
    }
}

#Preview {
    ZStack {
        SvaraTheme.Colors.background.ignoresSafeArea()
        SvaraCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Ananda").font(.svaraTitle)
                Text("A calm, rounded surface used everywhere.")
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
        }
        .padding()
    }
}
