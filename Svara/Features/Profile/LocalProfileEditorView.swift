import SwiftUI
/// Edits the name on the local profile. Svara does not present an account or
/// credential form until a real authentication backend exists.
struct LocalProfileEditorView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: SvaraTheme.Spacing.xl) {
                header
                form
                actions
            }
            .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
            .padding(.vertical, SvaraTheme.Spacing.xxl)
        }
        .svaraScreenBackground()
        .onAppear { name = env.profile.displayName }
    }

    private var header: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(SvaraTheme.Gradients.dawn)
                    .frame(width: 96, height: 96)
                Image("SvaraMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .accessibilityHidden(true)
            }
            Text("Svara")
                .font(.svaraDisplay)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
            Text("Choose how Svara greets you")
                .font(.svaraBody)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
        .padding(.top, SvaraTheme.Spacing.xl)
    }

    private var form: some View {
        SvaraCard {
            VStack(spacing: SvaraTheme.Spacing.md) {
                HStack(spacing: SvaraTheme.Spacing.md) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                        .frame(width: 22)
                    TextField("Your name", text: $name)
                        .textContentType(.name)
                        .font(.svaraBody)
                }
                .padding(.vertical, SvaraTheme.Spacing.md)
                .padding(.horizontal, SvaraTheme.Spacing.md)
                .background(SvaraTheme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.sm, style: .continuous))

                if let errorMessage {
                    Text(errorMessage)
                        .font(.svaraCaption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var actions: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            PrimaryButton(title: "Save Name") {
                save()
            }
            SecondaryButton(title: "Cancel", systemImage: "xmark") {
                dismiss()
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Enter a name before saving."
            return
        }
        env.updateDisplayName(trimmed)
        dismiss()
    }
}

#Preview {
    LocalProfileEditorView().environment(AppEnvironment.preview())
}
