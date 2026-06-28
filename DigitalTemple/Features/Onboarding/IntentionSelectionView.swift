import SwiftUI

/// Step 2 — "Why are you here?" Six gentle reasons. The choice shapes the
/// suggested first sankalp but is never binding.
struct IntentionSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why are you here?")
                            .font(.sacredTitle)
                            .foregroundStyle(Theme.Palette.ink)
                        Text("There is no wrong answer. This simply helps your mandir meet you where you are.")
                            .font(.sacredCaption)
                            .foregroundStyle(Theme.Palette.inkSecondary)
                    }

                    VStack(spacing: 12) {
                        ForEach(OnboardingIntention.allCases) { intention in
                            IntentionRow(
                                intention: intention,
                                isSelected: viewModel.selectedIntention == intention
                            ) {
                                viewModel.selectIntention(intention)
                            }
                        }
                    }
                }
                .screenPadding()
                .padding(.vertical, 16)
            }

            OnboardingFooter(
                primaryTitle: "Continue",
                primaryEnabled: viewModel.selectedIntention != nil,
                onBack: viewModel.goBack,
                onPrimary: viewModel.advance
            )
        }
    }
}

private struct IntentionRow: View {
    let intention: OnboardingIntention
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(intention.glyph)
                    .font(.title2)
                Text(intention.title)
                    .font(.sacredHeadline)
                    .foregroundStyle(Theme.Palette.ink)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.Palette.accent)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
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

/// Shared bottom bar for onboarding steps: an optional Back, and a primary
/// action that can be disabled until the step is satisfied.
struct OnboardingFooter: View {
    let primaryTitle: String
    var primaryEnabled: Bool = true
    var onBack: (() -> Void)? = nil
    let onPrimary: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .frame(width: 52, height: 52)
                }
                .buttonStyle(.sacredQuiet)
                .frame(width: 60)
            }
            Button(primaryTitle, action: onPrimary)
                .buttonStyle(.sacred)
                .disabled(!primaryEnabled)
                .opacity(primaryEnabled ? 1 : 0.5)
                .accessibilityIdentifier("onboarding.continueButton")
        }
        .screenPadding()
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }
}
