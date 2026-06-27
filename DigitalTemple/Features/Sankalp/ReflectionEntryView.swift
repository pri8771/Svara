import SwiftUI
import SwiftData

/// A moment of return: the person writes a short reflection on a sankalp and
/// names the inner weather of the moment. Past reflections are shown beneath,
/// so returning feels like leafing through a quiet journal.
struct ReflectionEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let sankalp: Sankalp
    private let analytics = AnalyticsService.shared

    @State private var content: String = ""
    @State private var mood: Mood = .quiet
    @State private var past: [Reflection] = []
    @FocusState private var focused: Bool

    private var canSave: Bool {
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Return to this sankalp")
                            .font(.sacredTitle)
                            .foregroundStyle(Theme.Palette.ink)
                        Text(sankalp.intention)
                            .font(.sacredCaption)
                            .foregroundStyle(Theme.Palette.inkSecondary)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "How are you, here?")
                        moodPicker
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Your reflection")
                        TextField("Whatever you wish to leave…", text: $content, axis: .vertical)
                            .lineLimit(4...10)
                            .focused($focused)
                            .sacredField()
                    }

                    if !past.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Earlier returns")
                            ForEach(past) { reflection in
                                PastReflectionRow(reflection: reflection)
                            }
                        }
                    }
                }
                .screenPadding()
                .padding(.vertical, 16)
            }

            Button("Leave this reflection", action: save)
                .buttonStyle(.sacred)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
                .screenPadding()
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
        }
        .sacredScreen()
        .navigationTitle("Reflect")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadPast() }
    }

    private var moodPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Mood.allCases) { m in
                    Button {
                        mood = m
                    } label: {
                        HStack(spacing: 6) {
                            Text(m.glyph)
                            Text(m.title).font(.sacredLabel)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .foregroundStyle(m == mood ? .white : Theme.Palette.ink)
                        .background(m == mood ? Theme.Palette.calm : Theme.Palette.surface)
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
        past = MandirRepository(context: modelContext).reflections(for: sankalp.id)
    }

    private func save() {
        let repo = MandirRepository(context: modelContext)
        repo.addReflection(
            content: content.trimmingCharacters(in: .whitespaces),
            mood: mood,
            sankalpId: sankalp.id
        )
        analytics.log(.reflectionAdded(mood: mood.rawValue))
        dismiss()
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
