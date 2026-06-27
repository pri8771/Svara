import Foundation
import SwiftData

/// Read access to Sacred Time. v0 presents sacred dates as a forward-looking
/// list of upcoming observances — never a calendar grid.
@MainActor
struct SacredTimeRepository {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allEntries() -> [SacredDateEntry] {
        (try? context.fetch(FetchDescriptor<SacredDateEntry>())) ?? []
    }

    /// Upcoming observances, soonest first, with recurrence normalised forward.
    func upcoming(limit: Int? = nil) -> [SacredDateEntry] {
        let sorted = allEntries().sorted { $0.nextOccurrence < $1.nextOccurrence }
        if let limit { return Array(sorted.prefix(limit)) }
        return sorted
    }

    /// The single next sacred date, for the home screen.
    func next() -> SacredDateEntry? {
        upcoming(limit: 1).first
    }
}
