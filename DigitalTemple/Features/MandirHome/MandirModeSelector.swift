import SwiftUI

/// The in-place selector for the four ways of being at the altar. A single
/// segmented control of glyphed pills — not a tab bar, and never persistent
/// chrome; it sits inline beneath the altar.
struct MandirModeSelector: View {
    @Binding var selection: MandirMode
    var onSelect: (MandirMode) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MandirMode.allCases) { mode in
                let isSelected = mode == selection
                Button {
                    guard mode != selection else { return }
                    withAnimation(.easeInOut(duration: 0.25)) { selection = mode }
                    onSelect(mode)
                } label: {
                    VStack(spacing: 4) {
                        Text(mode.glyph)
                            .font(.body)
                        Text(mode.title)
                            .font(.sacredLabel)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(isSelected ? Theme.Palette.background : Theme.Palette.ink)
                    .background(isSelected ? Theme.Palette.marigold : Theme.Palette.surfaceRaised)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? .clear : Theme.Palette.hairline, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mode.title)
                .accessibilityAddTraits(.isButton)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}
