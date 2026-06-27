import SwiftUI
import SwiftData

/// Completing a sankalp is a sacred act, not a checkbox. The person confirms,
/// the vow is marked fulfilled, and a quiet closing acknowledgment is offered
/// before they return to the mandir.
struct SankalpFulfillmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let sankalp: Sankalp
    private let analytics = AnalyticsService.shared

    @State private var isFulfilled = false
    /// An optional closing word the person leaves as the vow is completed.
    @State private var closingWord: String = ""

    var body: some View {
        ZStack {
            ScreenBackground()
            if isFulfilled {
                acknowledgment
            } else {
                confirmation
            }
        }
        .navigationTitle(isFulfilled ? "" : "Fulfill")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.4), value: isFulfilled)
    }

    // MARK: Confirmation

    private var confirmation: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Bring this sankalp to a close")
                        .font(.sacredTitle)
                        .foregroundStyle(Theme.Palette.ink)

                    SacredCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(sankalp.intentionType.title.uppercased())
                                .font(.sacredLabel)
                                .tracking(1)
                                .foregroundStyle(Theme.Palette.inkSecondary)
                            Text(sankalp.intention)
                                .font(.sacredHeadline)
                                .foregroundStyle(Theme.Palette.ink)
                            if let forWhom = sankalp.forWhom, !forWhom.isEmpty {
                                Text("For \(forWhom)")
                                    .font(.sacredCaption)
                                    .foregroundStyle(Theme.Palette.inkSecondary)
                            }
                        }
                    }

                    Text("A fulfilled sankalp is never lost — it is preserved among your memories.")
                        .font(.sacredCaption)
                        .foregroundStyle(Theme.Palette.inkSecondary)

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "A closing word (optional)")
                        TextField("What did this come to mean?", text: $closingWord, axis: .vertical)
                            .lineLimit(2...5)
                            .sacredField()
                    }
                }
                .screenPadding()
                .padding(.vertical, 16)
            }

            Button("Fulfill this sankalp", action: fulfill)
                .buttonStyle(.sacred)
                .screenPadding()
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
        }
    }

    // MARK: Acknowledgment

    private var acknowledgment: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("🙏")
                .font(.system(size: 64))
            VStack(spacing: 12) {
                Text("It is fulfilled")
                    .font(.mandirTitle)
                    .foregroundStyle(Theme.Palette.ink)
                Text("What you held has been honoured.\nMay it stay with you.")
                    .font(.sacredBody)
                    .foregroundStyle(Theme.Palette.inkSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .screenPadding()
            Spacer()
            Button("Return to your mandir") { dismiss() }
                .buttonStyle(.sacred)
                .screenPadding()
                .padding(.bottom, 24)
        }
    }

    // MARK: Actions

    private func fulfill() {
        let repo = MandirRepository(context: modelContext)
        repo.fulfill(sankalp)

        // Preserve the fulfilled vow as a memory so it is never lost.
        let trimmed = closingWord.trimmingCharacters(in: .whitespaces)
        let body = trimmed.isEmpty ? sankalp.intention : "\(sankalp.intention)\n\n\(trimmed)"
        repo.saveMemory(
            title: "A sankalp fulfilled",
            content: body,
            type: .offering,
            mandirId: sankalp.mandirId
        )

        analytics.log(.sankalpFulfilled(type: sankalp.intentionType.rawValue))
        analytics.log(.memorySaved(type: MemoryType.offering.rawValue))
        isFulfilled = true
    }
}
