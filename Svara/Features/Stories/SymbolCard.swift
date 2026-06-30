import SwiftUI

/// A small symbol card showing a name, optional Sanskrit name, and a short
/// meaning excerpt. Tapping opens a sheet with the full meaning, the tradition
/// note, and associated deities.
struct SymbolCard: View {
    let symbol: SymbolEntry
    var tint: Color = SvaraTheme.Colors.accent

    @State private var showDetail = false

    var body: some View {
        Button { showDetail = true } label: {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.title3)
                    .foregroundStyle(tint)
                    .accessibilityHidden(true)
                Text(symbol.name)
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                if let sanskrit = symbol.sanskritName {
                    Text(sanskrit)
                        .font(.svaraCaption.italic())
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                }
                Text(symbol.meaning)
                    .font(.svaraCaption)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(SvaraTheme.Spacing.md)
            .frame(width: 200, alignment: .leading)
            .frame(minHeight: 120, alignment: .topLeading)
            .background(SvaraTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                    .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(symbol.name). \(symbol.meaning)")
        .accessibilityHint("Open full meaning")
        .sheet(isPresented: $showDetail) {
            SymbolDetailSheet(symbol: symbol, tint: tint)
        }
    }
}

private struct SymbolDetailSheet: View {
    let symbol: SymbolEntry
    var tint: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.lg) {
                    HStack(spacing: SvaraTheme.Spacing.md) {
                        ZStack {
                            Circle().fill(tint.opacity(0.15)).frame(width: 52, height: 52)
                            Image(systemName: "circle.hexagongrid.fill").foregroundStyle(tint)
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(symbol.name)
                                .font(.svaraTitle)
                                .foregroundStyle(SvaraTheme.Colors.textPrimary)
                            if let sanskrit = symbol.sanskritName {
                                Text(sanskrit)
                                    .font(.svaraCallout.italic())
                                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
                            }
                        }
                    }

                    Text(symbol.meaning)
                        .font(.svaraBody)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if !symbol.associatedDeities.isEmpty {
                        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xs) {
                            Text("Often associated with").svaraEyebrow()
                            Text(symbol.associatedDeities.joined(separator: ", "))
                                .font(.svaraCallout)
                                .foregroundStyle(SvaraTheme.Colors.textPrimary)
                        }
                    }

                    Text(symbol.traditionNote)
                        .font(.svaraCaption)
                        .italic()
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(SvaraTheme.Spacing.screenMargin)
            }
            .svaraScreenBackground()
            .navigationTitle("Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SymbolCard(symbol: SeedContent.storyLibrary[0].symbolism[0])
        .padding()
        .background(SvaraTheme.Colors.background)
}
