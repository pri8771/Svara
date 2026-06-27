import SwiftUI
import SwiftData

/// Preserve a memory in the mandir: a moment, a tradition, an offering, or a
/// reflection worth keeping.
struct NewMemoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mandir: DigitalMandir
    private let analytics = AnalyticsService.shared

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var type: MemoryType = .moment
    @FocusState private var titleFocused: Bool

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "What kind of memory")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(MemoryType.allCases) { t in
                                    Button {
                                        type = t
                                    } label: {
                                        HStack(spacing: 6) {
                                            Text(t.glyph)
                                            Text(t.title).font(.sacredLabel)
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 9)
                                        .foregroundStyle(t == type ? .white : Theme.Palette.ink)
                                        .background(t == type ? Theme.Palette.accent : Theme.Palette.surface)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(t == type ? .clear : Theme.Palette.hairline, lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Title")
                        TextField("A few words", text: $title)
                            .focused($titleFocused)
                            .sacredField()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "What you wish to remember")
                        TextField("Optional", text: $content, axis: .vertical)
                            .lineLimit(4...10)
                            .sacredField()
                    }
                }
                .screenPadding()
                .padding(.vertical, 16)
            }

            Button("Preserve this memory", action: save)
                .buttonStyle(.sacred)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
                .screenPadding()
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
        }
        .sacredScreen()
        .navigationTitle("New Memory")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { dismiss() }
                    .foregroundStyle(Theme.Palette.inkSecondary)
            }
        }
        .onAppear { titleFocused = true }
    }

    private func save() {
        let repo = MandirRepository(context: modelContext)
        repo.saveMemory(
            title: title.trimmingCharacters(in: .whitespaces),
            content: content.trimmingCharacters(in: .whitespaces),
            type: type,
            mandirId: mandir.id
        )
        analytics.log(.memorySaved(type: type.rawValue))
        dismiss()
    }
}
