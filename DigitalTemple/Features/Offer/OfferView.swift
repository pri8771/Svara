import SwiftUI
import SwiftData

/// The Offer surface: a small, wordless act of devotion placed before the
/// altar. Choose a kind of offering, optionally a word with it, and place it.
/// Each offering becomes a return woven into the Thread.
struct OfferView: View {
    @Environment(\.modelContext) private var modelContext

    let mandir: DigitalMandir
    let heldSankalp: Sankalp?
    /// Called after an offering is placed so the home can refresh.
    let onCommitted: () -> Void

    private let analytics = AnalyticsService.shared

    @State private var kind: OfferingKind = .pushpa
    @State private var note: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Place an offering")
                    .font(.sacredTitle)
                    .foregroundStyle(Theme.Palette.ink)
                Text("A flower, water, a lamp, or a word. Small and quiet — given, not counted.")
                    .font(.sacredCaption)
                    .foregroundStyle(Theme.Palette.inkSecondary)
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(OfferingKind.allCases) { k in
                    OfferingTile(kind: k, isSelected: k == kind) { kind = k }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: kind == .vachan ? "Your word" : "A word with it (optional)")
                TextField(kind == .vachan ? "Speak it here" : "Optional", text: $note, axis: .vertical)
                    .lineLimit(2...5)
                    .sacredField()
            }

            if let heldSankalp {
                Text("Offered while holding: \(heldSankalp.intention)")
                    .font(.sacredLabel)
                    .foregroundStyle(Theme.Palette.brass)
            }

            Button("Place this offering", action: place)
                .buttonStyle(.sacred)
                .disabled(kind == .vachan && note.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(kind == .vachan && note.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
        }
    }

    private func place() {
        let trimmed = note.trimmingCharacters(in: .whitespaces)
        let repo = MandirRepository(context: modelContext)
        repo.recordReturn(
            mandirId: mandir.id,
            sankalpId: heldSankalp?.id,
            offeringKind: kind,
            note: trimmed.isEmpty ? nil : trimmed
        )
        analytics.log(.offeringMade(kind: kind.rawValue))
        note = ""
        onCommitted()
    }
}

private struct OfferingTile: View {
    let kind: OfferingKind
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(kind.glyph).font(.largeTitle)
                Text(kind.title)
                    .font(.sacredHeadline)
                    .foregroundStyle(Theme.Palette.ink)
                Text(kind.subtitle)
                    .font(.sacredLabel)
                    .foregroundStyle(Theme.Palette.inkSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.Palette.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Theme.Palette.marigold : Theme.Palette.hairline,
                            lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
