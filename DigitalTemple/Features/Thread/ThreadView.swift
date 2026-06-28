import SwiftUI
import SwiftData

/// The Thread: the woven, chronological record of the relationship — every
/// return (lamp, offering, reflection) and every preserved memory, newest
/// first. This is where remembering and preserving live. Not a feed: it grows
/// only from the person's own quiet acts.
struct ThreadView: View {
    let mandir: DigitalMandir
    /// Called after the person preserves a memory so the home can refresh.
    var onChanged: () -> Void = {}

    @Query private var returns: [MandirReturn]
    @Query private var memories: [Memory]
    @State private var showingNewMemory = false

    private let analytics = AnalyticsService.shared

    init(mandir: DigitalMandir, onChanged: @escaping () -> Void = {}) {
        self.mandir = mandir
        self.onChanged = onChanged
        let id = mandir.id
        _returns = Query(
            filter: #Predicate<MandirReturn> { $0.mandirId == id },
            sort: \MandirReturn.date, order: .reverse
        )
        _memories = Query(
            filter: #Predicate<Memory> { $0.mandirId == id },
            sort: \Memory.date, order: .reverse
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your thread")
                        .font(.sacredTitle)
                        .foregroundStyle(Theme.Palette.ink)
                    Text("Every time you have returned.")
                        .font(.sacredCaption)
                        .foregroundStyle(Theme.Palette.inkSecondary)
                }
                Spacer()
                Button { showingNewMemory = true } label: {
                    Label("Preserve", systemImage: "plus")
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.marigold)
                }
            }

            if entries.isEmpty {
                SacredCard {
                    QuietState(
                        glyph: "🧵",
                        message: "Your thread is bare.\nLight the lamp, place an offering, or leave a reflection — each becomes a thread to return to."
                    )
                }
            } else {
                ForEach(entries) { entry in
                    ThreadEntryRow(entry: entry)
                }
            }
        }
        .sheet(isPresented: $showingNewMemory, onDismiss: onChanged) {
            NavigationStack {
                NewMemoryView(mandir: mandir)
            }
        }
        .onAppear { analytics.log(.threadViewed) }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("thread.root")
    }

    // MARK: Unified timeline

    private var entries: [ThreadEntry] {
        let returnEntries = returns.map { ThreadEntry(from: $0) }
        let memoryEntries = memories.map { ThreadEntry(from: $0) }
        return (returnEntries + memoryEntries).sorted { $0.date > $1.date }
    }
}

/// One rendered item in the thread, normalised across returns and memories.
struct ThreadEntry: Identifiable {
    let id: UUID
    let date: Date
    let glyph: String
    let title: String
    let subtitle: String?

    init(from r: MandirReturn) {
        id = r.id
        date = r.date
        switch r.kind {
        case .lamp:
            glyph = "🪔"; title = "Lit the lamp"
            subtitle = r.note
        case .offering:
            let kind = r.offeringKind
            glyph = kind?.glyph ?? "🌼"
            title = "Offered \(kind?.title ?? "an offering")"
            subtitle = r.note ?? kind?.subtitle
        case .reflection:
            glyph = "🍃"; title = "A reflection"
            subtitle = r.note
        }
    }

    init(from m: Memory) {
        id = m.id
        date = m.date
        glyph = m.type.glyph
        title = m.title
        subtitle = m.content.isEmpty ? m.type.title : m.content
    }
}

private struct ThreadEntryRow: View {
    let entry: ThreadEntry

    var body: some View {
        SacredCard {
            HStack(alignment: .top, spacing: 14) {
                Text(entry.glyph).font(.title3)
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.sacredHeadline)
                        .foregroundStyle(Theme.Palette.ink)
                    if let subtitle = entry.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.sacredCaption)
                            .foregroundStyle(Theme.Palette.inkSecondary)
                            .lineLimit(3)
                    }
                    Text(entry.date.sacredShortString)
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.brass)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
