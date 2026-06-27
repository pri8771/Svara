import Foundation

/// Picks the "shloka of the day" deterministically, so the same calendar day
/// always yields the same shloka (no randomness, stable across launches).
///
/// Selection order:
/// 1. If a shloka pins itself to today via `dateKey` ("MM-dd"), it wins.
/// 2. Otherwise, choose by day-of-year modulo the catalogue size.
enum ShlokaSelector {

    static func shloka(
        for date: Date,
        from shlokas: [ShlokaOfDay],
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> ShlokaOfDay? {
        guard !shlokas.isEmpty else { return nil }

        // 1) Honour an explicit fixed-day pin.
        let monthDay = DayKey.monthDay(from: date)
        if let pinned = shlokas.first(where: { $0.dateKey == monthDay }) {
            return pinned
        }

        // 2) Deterministic rotation by day-of-year.
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % shlokas.count
        return shlokas[index]
    }
}
