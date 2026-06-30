import SwiftUI

/// A sheet for writing a private reflection in response to a story's prompt.
/// Reflections are saved only on the device and are never shared (see
/// `ReflectionStore`).
struct ReflectionPromptView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    let story: Story
    /// Called after a successful save so the caller can refresh.
    var onSaved: () -> Void = {}

    @State private var text: String = ""

    private let maxChars = 500

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.lg) {
                    privacyNote

                    VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xs) {
                        Text("Reflect on").svaraEyebrow()
                        Text(story.reflectionPrompt)
                            .font(.svaraTitle)
                            .foregroundStyle(SvaraTheme.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    TextEditor(text: $text)
                        .frame(minHeight: 160)
                        .padding(SvaraTheme.Spacing.sm)
                        .scrollContentBackground(.hidden)
                        .background(SvaraTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                                .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
                        )
                        .onChange(of: text) { _, newValue in
                            if newValue.count > maxChars { text = String(newValue.prefix(maxChars)) }
                        }
                        .accessibilityLabel("Your reflection")

                    HStack {
                        Spacer()
                        Text("\(text.count)/\(maxChars)")
                            .font(.svaraCaption)
                            .foregroundStyle(text.count >= maxChars ? SvaraTheme.Colors.primaryDeep : SvaraTheme.Colors.textSecondary)
                    }

                    PrimaryButton(title: "Save reflection", isEnabled: !trimmed.isEmpty) { save() }
                }
                .padding(SvaraTheme.Spacing.screenMargin)
            }
            .svaraScreenBackground()
            .navigationTitle("Add a reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: SvaraTheme.Spacing.sm) {
            Image(systemName: "lock.fill")
                .foregroundStyle(SvaraTheme.Colors.success)
                .accessibilityHidden(true)
            Text("Your reflection is saved only on this device and is never shared.")
                .font(.svaraCaption)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SvaraTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SvaraTheme.Colors.success.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.sm, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Private. Your reflection is saved only on this device and is never shared.")
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        let entry = ReflectionEntry(storyId: story.id, text: trimmed)
        env.reflections.save(entry)
        onSaved()
        dismiss()
    }
}

#Preview {
    ReflectionPromptView(story: SeedContent.storyLibrary[0])
        .environment(AppEnvironment.preview())
}
