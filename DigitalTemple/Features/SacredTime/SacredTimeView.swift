import SwiftUI
import SwiftData

/// Sacred Time — upcoming observances as a forward-looking list, soonest first.
/// Deliberately not a calendar grid: the mandir is about returning, not
/// scheduling.
struct SacredTimeView: View {
    @Query private var entries: [SacredDateEntry]
    private let analytics = AnalyticsService.shared

    /// Sorted by the next occurrence (recurrence normalised forward).
    private var upcoming: [SacredDateEntry] {
        entries.sorted { $0.nextOccurrence < $1.nextOccurrence }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("The sacred dates ahead. Let them find you when they come.")
                    .font(.sacredCaption)
                    .foregroundStyle(Theme.Palette.inkSecondary)
                    .padding(.bottom, 4)

                if upcoming.isEmpty {
                    SacredCard { QuietState(glyph: "🗓️", message: "No dates to show.") }
                } else {
                    ForEach(upcoming) { entry in
                        SacredDateRow(entry: entry)
                    }
                }
            }
            .screenPadding()
            .padding(.vertical, 16)
        }
        .sacredScreen()
        .navigationTitle("Sacred Time")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { analytics.log(.sacredTimeViewed) }
    }
}
