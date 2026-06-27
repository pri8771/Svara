import SwiftUI
import SwiftData

/// The long thread of the mandir: everything the person has chosen to preserve.
/// A quiet chronological list, never a feed.
struct MemoriesView: View {
    let mandir: DigitalMandir
    private let analytics = AnalyticsService.shared

    @Query private var memories: [Memory]
    @State private var showingNew = false

    init(mandir: DigitalMandir) {
        self.mandir = mandir
        let id = mandir.id
        _memories = Query(
            filter: #Predicate<Memory> { $0.mandirId == id },
            sort: \Memory.date,
            order: .reverse
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if memories.isEmpty {
                    SacredCard {
                        QuietState(
                            glyph: "🌸",
                            message: "Nothing is preserved yet.\nA memory might be a moment, a tradition, or an offering."
                        )
                    }
                    .padding(.top, 24)
                } else {
                    ForEach(memories) { memory in
                        MemoryRow(memory: memory)
                    }
                }
            }
            .screenPadding()
            .padding(.vertical, 16)
        }
        .sacredScreen()
        .navigationTitle("Memories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingNew = true } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add a memory")
            }
        }
        .sheet(isPresented: $showingNew) {
            NavigationStack {
                NewMemoryView(mandir: mandir)
            }
        }
        .onAppear { analytics.log(.memoriesViewed) }
    }
}
