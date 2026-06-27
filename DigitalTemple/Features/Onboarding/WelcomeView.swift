import SwiftUI

/// Step 1 — a quiet welcome. Sets the tone: this is a sacred space, not an app
/// full of content. No sign-up, no promises of features.
struct WelcomeView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Text("🪔")
                    .font(.system(size: 72))
                    .accessibilityHidden(true)

                Text("My Mandir")
                    .font(.mandirTitle)
                    .foregroundStyle(Theme.Palette.ink)

                Text("A quiet place of your own —\nto hold an intention, to return,\nand to remember.")
                    .font(.sacredBody)
                    .foregroundStyle(Theme.Palette.inkSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .screenPadding()

            Spacer()

            VStack(spacing: 14) {
                Button("Begin") {
                    viewModel.advance()
                }
                .buttonStyle(.sacred)

                Text("Everything stays on your device.")
                    .font(.sacredLabel)
                    .foregroundStyle(Theme.Palette.inkSecondary)
            }
            .screenPadding()
            .padding(.bottom, 24)
        }
    }
}
