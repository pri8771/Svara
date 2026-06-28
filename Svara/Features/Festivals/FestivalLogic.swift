import Foundation

/// Pure, testable logic for the Festivals tab: countdown copy, seasonal
/// grouping, and gentle region filtering. No UI, no persistence.

// MARK: - Countdown

enum FestivalCountdown {
    /// A warm countdown label for a number of days until a festival.
    static func label(daysUntil days: Int) -> String {
        switch days {
        case ..<0: return "Passed"
        case 0: return "Today"
        case 1: return "Tomorrow"
        case 2...6: return "in \(days) days"
        case 7...13: return "in 1 week"
        default: return "in \(days) days"
        }
    }

    /// Whether to show a "Today" badge.
    static func isToday(daysUntil days: Int) -> Bool { days == 0 }
}

// MARK: - Seasons

/// A coarse season derived from the (Northern-Hemisphere / Indian) calendar
/// month, used for the "This season" grouping.
enum FestivalSeason: String, CaseIterable {
    case winter, spring, summer, monsoon, autumn

    var label: String {
        switch self {
        case .winter: return "Winter"
        case .spring: return "Spring"
        case .summer: return "Summer"
        case .monsoon: return "Monsoon"
        case .autumn: return "Autumn"
        }
    }

    static func season(forMonth month: Int) -> FestivalSeason {
        switch month {
        case 12, 1, 2: return .winter
        case 3, 4: return .spring
        case 5, 6: return .summer
        case 7, 8, 9: return .monsoon
        default: return .autumn // 10, 11
        }
    }

    static func season(for date: Date, calendar: Calendar = .current) -> FestivalSeason {
        season(forMonth: calendar.component(.month, from: date))
    }
}

enum FestivalSeasonGrouping {
    /// Upcoming festivals within `windowDays` of `now` — "what's coming this
    /// stretch of the year". Sorted soonest-first.
    static func thisSeason(
        _ festivals: [Festival],
        now: Date = Date(),
        windowDays: Int = 92
    ) -> [Festival] {
        festivals
            .filter { (0...windowDays).contains($0.daysUntil(from: now)) }
            .sorted { $0.daysUntil(from: now) < $1.daysUntil(from: now) }
    }
}

// MARK: - Region filtering (gentle / non-blocking)

enum FestivalRegionFilter {
    /// Whether a festival is associated with `region`. A festival with no tags
    /// is considered universally relevant (matches any region).
    static func matches(_ festival: Festival, region: FestivalRegion) -> Bool {
        if festival.regionTags.isEmpty { return true }
        if festival.regionTags.contains(region.rawValue) { return true }
        // "India" and "Global Hindu" are broad: any India-tagged festival matches.
        switch region {
        case .india, .global:
            return festival.regionTags.contains { $0 != FestivalRegion.diaspora.rawValue }
        default:
            return false
        }
    }

    /// Orders festivals for the chosen region **without hiding any**: matching
    /// festivals float to the front (preserving relative order), the rest follow.
    /// When `region` is `nil`, the input order is returned unchanged.
    static func ordered(_ festivals: [Festival], for region: FestivalRegion?) -> [Festival] {
        guard let region else { return festivals }
        let matching = festivals.filter { matches($0, region: region) }
        let others = festivals.filter { !matches($0, region: region) }
        return matching + others
    }

    /// The subset that matches a region (used only for counts/badges, never to
    /// remove festivals from the list).
    static func matchingCount(_ festivals: [Festival], for region: FestivalRegion) -> Int {
        festivals.filter { matches($0, region: region) }.count
    }
}
