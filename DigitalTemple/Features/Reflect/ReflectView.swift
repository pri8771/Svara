import SwiftUI
import SwiftData

/// The Reflect surface: a moment of return spent with the held sankalp. The
/// person names the inner weather and leaves a few words. Each reflection is a
/// return woven into the Thread. The held vow can also be fulfilled from here.
struct ReflectView: View {
    @Environment(\.modelContext) private var modelContext

    let mandir: DigitalMandir
    let heldSankalp: Sankalp?
    let onCommitted: () -> Void
    let onFulfill: (Sankalp) -> Void
    let onMakeSankalp: () -> Void

    private let analytics = AnalyticsService.shared

    @State private var content: String = ""
    @State private var mood: Mood = .quiet
    @State private var past: [Reflection] = []

    private var canSave: Bool {
        heldSankalp != nil && !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let sankalp = heldSankalp {
                heldHeader(sankalp)

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "How are you, here?")
                    moodPicker
                }

                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Your reflection")
                    TextField("Whatever you wish to leave…", text: $content, axis: .vertical)
                        .lineLimit(4...10)
                        .sacredField()
                }

                Button("Leave this reflection") { save(for: sankalp) }
                    .buttonStyle(.sacred)
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)

                Button("Fulfill this sankalp") { onFulfill(sankalp) }
                    .buttonStyle(.sacredQuiet)

                if !past.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Earlier returns")
                        ForEach(past) { reflection in
                            PastReflectionRow(reflection: reflection)
                        }
                    }
                    .padding(.top, 4)
                }
            } else {
                SacredCard {
                    QuietState(
                        glyph: "📿",
                        message: "No intention is held yet.\nMake a sankalp to begin returning to it."
                    )
                }
                Button("Make a sankalp", action: onMakeSankalp)
                    .buttonStyle(.sacred)
            }
        }
        .onAppear(perform: loadPast)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("reflect.root")
    }

    private func heldHeader(_ sankalp: Sankalp) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("You hold")
                .font(.sacredLabel)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Theme.Palette.inkSecondary)
            Text(sankalp.intention)
                .font(.sacredHeadline)
                .foregroundStyle(Theme.Palette.ink)
            if let forWhom = sankalp.forWhom, !forWhom.isEmpty {
                Text("For \(forWhom)")
                    .font(.sacredCaption)
                    .foregroundStyle(Theme.Palette.brass)
            }
        }
    }

    private var moodPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Mood.allCases) { m in
                    Button { mood = m } label: {
                        HStack(spacing: 6) {
                            Text(m.glyph)
                            Text(m.title).font(.sacredLabel)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .foregroundStyle(m == mood ? Theme.Palette.background : Theme.Palette.ink)
                        .background(m == mood ? Theme.Palette.calm : Theme.Palette.surfaceRaised)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(m == mood ? .clear : Theme.Palette.hairline, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func loadPast() {
        guard let sankalp = heldSankalp else { past = []; return }
        past = MandirRepository(context: modelContext).reflections(for: sankalp.id)
    }

    private func save(for sankalp: Sankalp) {
        let trimmed = content.trimmingCharacters(in: .whitespaces)
        let repo = MandirRepository(context: modelContext)
        let reflection = repo.addReflection(content: trimmed, mood: mood, sankalpId: sankalp.id)
        // Weave the reflection into the Thread as a return (copy the words so the
        // Thread can render without a join).
        repo.recordReturn(
            mandirId: mandir.id,
            sankalpId: sankalp.id,
            reflectionId: reflection.id,
            note: trimmed
        )
        analytics.log(.reflectionAdded(mood: mood.rawValue))
        content = ""
        loadPast()
        onCommitted()
    }
}

private struct PastReflectionRow: View {
    let reflection: Reflection

    var body: some View {
        SacredCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(reflection.mood.glyph) \(reflection.mood.title)")
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.calm)
                    Spacer()
                    Text(reflection.date.sacredShortString)
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.inkSecondary)
                }
                Text(reflection.content)
                    .font(.sacredCaption)
                    .foregroundStyle(Theme.Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
