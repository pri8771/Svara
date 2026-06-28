import SwiftUI

/// The altar itself: a dim plinth holding a diya. Unlit until the person
/// returns and holds the wick; once lit, the flame glows and a quiet
/// acknowledgment appears. This is the emotional center of the app.
struct AltarStateView: View {
    let isLit: Bool
    let devataDevanagari: String?
    let onLight: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Presiding devata's name in Devanagari, hovering above the flame.
            if let devataDevanagari {
                Text(devataDevanagari)
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(Theme.Palette.brass)
                    .opacity(isLit ? 1 : 0.5)
                    .shadow(color: isLit ? Theme.Palette.flame.opacity(0.4) : .clear, radius: 10)
            }

            HoldWickInteraction(isLit: isLit, onLight: onLight)

            // The plinth.
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Theme.Palette.surfaceRaised, Theme.Palette.surface],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 180, height: 14)
                .overlay(Capsule().stroke(Theme.Palette.brass.opacity(0.35), lineWidth: 1))

            Text(isLit ? "The lamp is lit. You are here." : "Hold the wick to light your lamp.")
                .font(.sacredCaption)
                .foregroundStyle(isLit ? Theme.Palette.brass : Theme.Palette.inkSecondary)
                .multilineTextAlignment(.center)
                .animation(.easeInOut, value: isLit)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("altar.root")
    }
}
