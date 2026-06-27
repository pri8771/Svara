import SwiftUI

/// The primary call-to-action button: saffron, full-width, rounded.
struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SvaraTheme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(SvaraTheme.Colors.textOnPrimary)
                } else {
                    if let systemImage {
                        Image(systemName: systemImage)
                    }
                    Text(title)
                }
            }
            .font(.svaraHeadline)
            .foregroundStyle(SvaraTheme.Colors.textOnPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(SvaraTheme.Gradients.saffron)
            .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
            .shadow(color: SvaraTheme.Palette.saffronDeep.opacity(0.35), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

/// A lighter, secondary action used for less prominent choices.
struct SecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SvaraTheme.Spacing.sm) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .font(.svaraHeadline)
            .foregroundStyle(SvaraTheme.Colors.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(SvaraTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                    .strokeBorder(SvaraTheme.Colors.accent.opacity(0.25), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Begin Practice", systemImage: "play.fill") {}
        PrimaryButton(title: "Loading", isLoading: true) {}
        SecondaryButton(title: "Maybe Later") {}
    }
    .padding()
    .background(SvaraTheme.Colors.background)
}
