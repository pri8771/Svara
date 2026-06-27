import SwiftUI
import SwiftData

/// Step 4 — choose the devatas who will reside in the mandir. A grid of the
/// twelve seeded devatas; multi-select, none required to be exclusive. The
/// first chosen becomes the presiding devata of the home screen.
struct ChooseDevataView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Query(sort: \Devata.name) private var devatas: [Devata]

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Who will you welcome?")
                            .font(.sacredTitle)
                            .foregroundStyle(Theme.Palette.ink)
                        Text("Choose one or more devatas to reside in your mandir. The first you choose will preside over your space.")
                            .font(.sacredCaption)
                            .foregroundStyle(Theme.Palette.inkSecondary)
                    }

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(devatas) { devata in
                            DevataTile(
                                devata: devata,
                                isSelected: viewModel.chosenDevataIds.contains(devata.id)
                            ) {
                                viewModel.toggleDevata(devata.id)
                            }
                        }
                    }
                }
                .screenPadding()
                .padding(.vertical, 16)
            }

            OnboardingFooter(
                primaryTitle: "Continue",
                primaryEnabled: viewModel.hasChosenDevata,
                onBack: viewModel.goBack,
                onPrimary: viewModel.advance
            )
        }
    }
}

private struct DevataTile: View {
    let devata: Devata
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(devata.nameDevanagari)
                        .font(.devanagari)
                        .foregroundStyle(Theme.Palette.brass)
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? Theme.Palette.accent : Theme.Palette.hairline)
                }
                Text(devata.name)
                    .font(.sacredHeadline)
                    .foregroundStyle(Theme.Palette.ink)
                Text(devata.summary)
                    .font(.sacredLabel)
                    .foregroundStyle(Theme.Palette.inkSecondary)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Theme.Palette.accent : Theme.Palette.hairline,
                            lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
