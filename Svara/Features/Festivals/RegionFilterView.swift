import SwiftUI

/// A gentle, horizontal region picker. Choosing a region personalises ordering
/// on the Festivals tab; it **never hides** festivals (see `FestivalRegionFilter`).
struct RegionFilterView: View {
    @Binding var selection: FestivalRegion?

    var body: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
            Text("Personalise · nothing is hidden").svaraEyebrow()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SvaraTheme.Spacing.sm) {
                    chip(title: "All", systemImage: "sparkles", isSelected: selection == nil) {
                        selection = nil
                    }
                    ForEach(FestivalRegion.allCases) { region in
                        chip(title: region.label, systemImage: region.systemImage, isSelected: selection == region) {
                            selection = (selection == region) ? nil : region
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private func chip(title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.svaraCaption.weight(.semibold))
            .foregroundStyle(isSelected ? Color.white : SvaraTheme.Colors.accent)
            .padding(.horizontal, SvaraTheme.Spacing.md)
            .padding(.vertical, SvaraTheme.Spacing.sm)
            .background(isSelected ? SvaraTheme.Colors.accent : SvaraTheme.Colors.surface)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(SvaraTheme.Colors.accent.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    StatefulPreviewWrapper(FestivalRegion?.none) { RegionFilterView(selection: $0) }
        .padding()
        .background(SvaraTheme.Colors.background)
}

/// A tiny helper to preview views that need a `Binding`.
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initial)
        self.content = content
    }

    var body: some View { content($value) }
}
