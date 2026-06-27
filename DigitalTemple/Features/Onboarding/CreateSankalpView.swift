import SwiftUI

/// Step 5 — the first sankalp. Strongly encouraged but never forced: the person
/// can make their vow now or enter their mandir and make it later.
struct CreateSankalpView: View {
    @Bindable var viewModel: OnboardingViewModel
    /// Called with whether the person chose to make the sankalp.
    let onFinish: (_ createSankalp: Bool) -> Void

    @FocusState private var intentionFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Make your sankalp")
                            .font(.sacredTitle)
                            .foregroundStyle(Theme.Palette.ink)
                        Text("A sankalp is a sacred intention held before the divine. Name what you carry — you can return to it whenever you wish.")
                            .font(.sacredCaption)
                            .foregroundStyle(Theme.Palette.inkSecondary)
                    }

                    SankalpFormFields(
                        intention: $viewModel.sankalpIntentionText,
                        forWhom: $viewModel.sankalpForWhom,
                        type: $viewModel.sankalpType,
                        intentionFocused: $intentionFocused
                    )
                }
                .screenPadding()
                .padding(.vertical, 16)
            }

            VStack(spacing: 12) {
                Button("Make this sankalp") { onFinish(true) }
                    .buttonStyle(.sacred)
                    .disabled(!viewModel.hasSankalpText)
                    .opacity(viewModel.hasSankalpText ? 1 : 0.5)

                Button("Enter my mandir") { onFinish(false) }
                    .buttonStyle(.sacredQuiet)
            }
            .screenPadding()
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
        }
    }
}

/// The shared fields for composing a sankalp — reused by both the onboarding
/// first sankalp and the in-app "new sankalp" screen.
struct SankalpFormFields: View {
    @Binding var intention: String
    @Binding var forWhom: String
    @Binding var type: IntentionType
    var intentionFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "The kind of intention")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(IntentionType.allCases) { t in
                            IntentionChip(type: t, isSelected: t == type) { type = t }
                        }
                    }
                    .padding(.horizontal, 2)
                }
                Text(type.prompt)
                    .font(.sacredLabel)
                    .foregroundStyle(Theme.Palette.inkSecondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "Your intention")
                TextField("What do you wish to hold?", text: $intention, axis: .vertical)
                    .lineLimit(3...6)
                    .focused(intentionFocused)
                    .sacredField()
            }

            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "For whom (optional)")
                TextField("A name, or leave empty", text: $forWhom)
                    .textInputAutocapitalization(.words)
                    .sacredField()
            }
        }
    }
}

struct IntentionChip: View {
    let type: IntentionType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(type.glyph)
                Text(type.title)
                    .font(.sacredLabel)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .foregroundStyle(isSelected ? Theme.Palette.background : Theme.Palette.ink)
            .background(isSelected ? Theme.Palette.accent : Theme.Palette.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? .clear : Theme.Palette.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
