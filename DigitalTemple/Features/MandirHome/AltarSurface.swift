import SwiftUI

/// The "Altar" mode content: simply being present. Shows the intention held
/// before the altar (or an invitation to hold one) and the next sacred day,
/// woven in quietly — not as dashboard sections.
struct AltarSurface: View {
    let heldSankalp: Sankalp?
    let nextSacredDate: SacredDateEntry?
    let onMakeSankalp: () -> Void
    let onReflect: () -> Void
    let onOpenSacredTime: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Metrics.sectionSpacing) {
            heldIntention

            if let date = nextSacredDate {
                VStack(alignment: .leading, spacing: 10) {
                    Text("The next sacred day")
                        .font(.sacredLabel)
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .foregroundStyle(Theme.Palette.inkSecondary)
                    Button(action: onOpenSacredTime) {
                        NextSacredDateCard(entry: date)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var heldIntention: some View {
        if let sankalp = heldSankalp {
            Button(action: onReflect) {
                SacredCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(sankalp.intentionType.glyph)
                            Text("You hold")
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
                                .foregroundStyle(Theme.Palette.brass)
                        }
                        Text("Held since \(sankalp.startDate.sacredShortString) · return to it in Reflect")
                            .font(.sacredLabel)
                            .foregroundStyle(Theme.Palette.inkSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
        } else {
            VStack(spacing: 14) {
                SacredCard {
                    QuietState(
                        glyph: "📿",
                        message: "No intention is held here yet.\nA sankalp is a sacred vow you return to."
                    )
                }
                Button("Hold an intention", action: onMakeSankalp)
                    .buttonStyle(.sacred)
            }
        }
    }
}
