import SwiftUI

/// Step 3 — name the mandir and (optionally) say how you wish to be known.
/// Naming the space is the first act of making it your own.
struct NameMandirView: View {
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var focused: Field?

    private enum Field { case mandir, name }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name your mandir")
                            .font(.sacredTitle)
                            .foregroundStyle(Theme.Palette.ink)
                        Text("A name makes the space yours. Many people name it for a person, a place, or simply “My Mandir.”")
                            .font(.sacredCaption)
                            .foregroundStyle(Theme.Palette.inkSecondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Mandir name")
                        TextField("My Mandir", text: $viewModel.mandirName)
                            .textInputAutocapitalization(.words)
                            .focused($focused, equals: .mandir)
                            .submitLabel(.next)
                            .onSubmit { focused = .name }
                            .sacredField()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "How you wish to be known")
                        TextField("Optional", text: $viewModel.displayName)
                            .textInputAutocapitalization(.words)
                            .focused($focused, equals: .name)
                            .submitLabel(.done)
                            .sacredField()
                    }
                }
                .screenPadding()
                .padding(.vertical, 16)
            }

            OnboardingFooter(
                primaryTitle: "Continue",
                primaryEnabled: viewModel.canName,
                onBack: viewModel.goBack,
                onPrimary: viewModel.advance
            )
        }
        .onAppear { focused = .mandir }
    }
}

extension View {
    /// A calm, bordered text field matching the sacred surface.
    func sacredField() -> some View {
        self
            .font(.sacredBody)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Theme.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Theme.Palette.hairline, lineWidth: 1)
            )
    }
}
