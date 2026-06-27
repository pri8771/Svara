import SwiftUI

// MARK: - Background

/// The dim room around the altar: warm near-black with a low marigold glow
/// rising from the base, like lamplight pooling on the floor.
struct ScreenBackground: View {
    var body: some View {
        ZStack {
            Theme.Palette.background.ignoresSafeArea()
            RadialGradient(
                colors: [Theme.Palette.flame.opacity(0.12), .clear],
                center: .bottom,
                startRadius: 0,
                endRadius: 480
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Card

/// A raised dark surface for a single sacred object.
struct SacredCard<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(Theme.Metrics.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Palette.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous)
                    .stroke(Theme.Palette.hairline, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Buttons

/// The weighty, devotional primary action — marigold with dark ink for contrast.
struct SacredButtonStyle: ButtonStyle {
    var prominent: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.sacredHeadline)
            .foregroundStyle(prominent ? Theme.Palette.background : Theme.Palette.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(prominent ? Theme.Palette.marigold : Theme.Palette.surfaceRaised)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(prominent ? .clear : Theme.Palette.hairline, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SacredButtonStyle {
    static var sacred: SacredButtonStyle { SacredButtonStyle(prominent: true) }
    static var sacredQuiet: SacredButtonStyle { SacredButtonStyle(prominent: false) }
}

// MARK: - Section header

/// A small, calm label that opens a section.
struct SectionHeader: View {
    let title: String
    var devanagari: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.sacredLabel)
                .textCase(.uppercase)
                .tracking(1.5)
                .foregroundStyle(Theme.Palette.inkSecondary)
            if let devanagari {
                Text(devanagari)
                    .font(.sacredCaption)
                    .foregroundStyle(Theme.Palette.brass)
            }
            Spacer()
        }
    }
}

// MARK: - Empty / quiet states

/// A gentle placeholder. Never urges; simply notes the space is waiting.
struct QuietState: View {
    let glyph: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Text(glyph)
                .font(.system(size: 34))
                .opacity(0.8)
            Text(message)
                .font(.sacredCaption)
                .foregroundStyle(Theme.Palette.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
