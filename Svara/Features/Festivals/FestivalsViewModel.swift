import Foundation

@Observable
@MainActor
final class FestivalsViewModel {
    private(set) var festivals: [Festival] = []
    private(set) var isLoading = true

    func load(content: ContentRepository) async {
        isLoading = true
        let all = await content.festivals()
        // Upcoming first (today or later), then by date; past ones trail.
        festivals = all.sorted { lhs, rhs in
            let l = lhs.daysUntil(), r = rhs.daysUntil()
            switch (l >= 0, r >= 0) {
            case (true, false): return true
            case (false, true): return false
            default: return lhs.date < rhs.date
            }
        }
        isLoading = false
    }

    var next: Festival? {
        festivals.first { $0.daysUntil() >= 0 }
    }
}
