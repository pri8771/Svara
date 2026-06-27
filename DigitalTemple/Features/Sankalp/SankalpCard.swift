import SwiftUI

/// The card form of an active sankalp on the home screen. Shows the intention,
/// its kind, an optional dedication, and how long it has been held — with quiet
/// actions to reflect or to fulfill.
struct SankalpCard: View {
    let sankalp: Sankalp
    let devata: Devata?
    let onReflect: () -> Void
    let onFulfill: () -> Void

    var body: some View {
        SacredCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Text(sankalp.intentionType.glyph)
                        .font(.title3)
                    Text(sankalp.intentionType.title)
                        .font(.sacredLabel)
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundStyle(Theme.Palette.inkSecondary)
                    Spacer()
                }

                Text(sankalp.intention)
                    .font(.sacredHeadline)
                    .foregroundStyle(Theme.Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                if let forWhom = sankalp.forWhom, !forWhom.isEmpty {
                    Text("For \(forWhom)")
                        .font(.sacredCaption)
                        .foregroundStyle(Theme.Palette.inkSecondary)
                }

                HStack(spacing: 12) {
                    Label("Held since \(sankalp.startDate.sacredShortString)",
                          systemImage: "flame")
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.gold)
                    if let devata {
                        Text("· before \(devata.name)")
                            .font(.sacredLabel)
                            .foregroundStyle(Theme.Palette.inkSecondary)
                    }
                }

                Divider().background(Theme.Palette.hairline)

                HStack(spacing: 12) {
                    Button("Reflect", action: onReflect)
                        .buttonStyle(.sacredQuiet)
                    Button("Fulfill", action: onFulfill)
                        .buttonStyle(.sacred)
                }
            }
        }
    }
}
