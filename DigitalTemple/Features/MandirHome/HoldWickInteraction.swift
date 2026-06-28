import SwiftUI

/// The wick of the diya. The person presses and holds it to light the lamp — a
/// small, deliberate act that marks their return to the altar. A ring fills as
/// they hold; completing it lights the flame.
///
/// Deliberately effortful: lighting the lamp should never be a careless tap.
struct HoldWickInteraction: View {
    let isLit: Bool
    let onLight: () -> Void

    /// Seconds the wick must be held.
    private let holdDuration: Double = 1.3

    @State private var progress: CGFloat = 0
    @State private var pressing = false

    var body: some View {
        ZStack {
            // The glow when lit.
            if isLit {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.Palette.flame.opacity(0.55), .clear],
                            center: .center, startRadius: 2, endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .transition(.opacity)
            }

            // Progress ring while holding (unlit only).
            if !isLit {
                Circle()
                    .stroke(Theme.Palette.hairline, lineWidth: 3)
                    .frame(width: 64, height: 64)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Theme.Palette.marigold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 64, height: 64)
            }

            // The flame / wick glyph.
            Text(isLit ? "🔥" : "🕯️")
                .font(.system(size: isLit ? 40 : 30))
                .scaleEffect(pressing && !isLit ? 1.12 : 1)
                .shadow(color: isLit ? Theme.Palette.flame.opacity(0.8) : .clear, radius: 12)
        }
        .frame(width: 150, height: 150)
        .contentShape(Circle())
        .accessibilityElement()
        .accessibilityIdentifier("altar.lightButton")
        .accessibilityLabel(isLit ? "The lamp is lit" : "Hold to light the lamp")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { if !isLit { onLight() } }
        .onLongPressGesture(
            minimumDuration: holdDuration,
            maximumDistance: 60,
            pressing: { isPressing in
                guard !isLit else { return }
                pressing = isPressing
                withAnimation(isPressing ? .linear(duration: holdDuration) : .easeOut(duration: 0.3)) {
                    progress = isPressing ? 1 : 0
                }
            },
            perform: {
                guard !isLit else { return }
                withAnimation(.easeOut(duration: 0.4)) { onLight() }
            }
        )
    }
}
