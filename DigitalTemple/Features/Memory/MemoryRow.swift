import SwiftUI

/// A single preserved memory, shown as a calm row.
struct MemoryRow: View {
    let memory: Memory

    var body: some View {
        SacredCard {
            HStack(alignment: .top, spacing: 14) {
                Text(memory.type.glyph)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title)
                        .font(.sacredHeadline)
                        .foregroundStyle(Theme.Palette.ink)
                    if !memory.content.isEmpty {
                        Text(memory.content)
                            .font(.sacredCaption)
                            .foregroundStyle(Theme.Palette.inkSecondary)
                            .lineLimit(2)
                    }
                    Text("\(memory.type.title) · \(memory.date.sacredShortString)")
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.gold)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
