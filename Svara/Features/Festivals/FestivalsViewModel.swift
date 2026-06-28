import Foundation

@Observable
@MainActor
final class FestivalsViewModel {
    private(set) var festivals: [Festival] = []
    private(set) var isLoading = true

    /// The chosen regional lens. `nil` = no lens (everything shown as-is).
    /// Filtering is gentle: it re-orders but never hides festivals.
    var selectedRegion: FestivalRegion?

    private var now = Date()

    func load(content: ContentRepository, now: Date = Date()) async {
        isLoading = true
        self.now = now
        let all = await content.festivals()
        // Upcoming first (today or later) by soonest date; past ones trail.
        festivals = all.sorted { lhs, rhs in
            let l = lhs.daysUntil(from: now), r = rhs.daysUntil(from: now)
            switch (l >= 0, r >= 0) {
            case (true, false): return true
            case (false, true): return false
            default: return lhs.date < rhs.date
            }
        }
        isLoading = false
    }

    /// The soonest upcoming festival — the hero.
    var next: Festival? {
        festivals.first { $0.isUpcoming(from: now) }
    }

    /// Upcoming festivals after the hero (for the "Coming soon" rail).
    func comingSoon(limit: Int = 5) -> [Festival] {
        let upcoming = festivals.filter { $0.isUpcoming(from: now) }
        return Array(upcoming.dropFirst()).prefix(limit).map { $0 }
    }

    /// Upcoming festivals within the current season window.
    var thisSeason: [Festival] {
        FestivalSeasonGrouping.thisSeason(festivals, now: now)
    }

    var currentSeason: FestivalSeason {
        FestivalSeason.season(for: now)
    }

    /// The full list ordered for the chosen region (no festival is ever hidden).
    var yearAhead: [Festival] {
        FestivalRegionFilter.ordered(festivals, for: selectedRegion)
    }

    /// Whether a festival matches the chosen region (for a gentle highlight).
    func matchesSelectedRegion(_ festival: Festival) -> Bool {
        guard let selectedRegion else { return true }
        return FestivalRegionFilter.matches(festival, region: selectedRegion)
    }

    func daysUntil(_ festival: Festival) -> Int {
        festival.daysUntil(from: now)
    }
}
