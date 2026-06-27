import Foundation

extension Date {
    /// "14 January 2026" — a calm, full date for sacred moments.
    var sacredLongString: String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f.string(from: self)
    }

    /// "14 Jan" — compact form for list rows.
    var sacredShortString: String {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("d MMM")
        return f.string(from: self)
    }

    /// Whole days from now until this date (negative if in the past).
    var daysFromNow: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.startOfDay(for: self)
        return cal.dateComponents([.day], from: start, to: end).day ?? 0
    }

    /// A soft relative phrase: "Today", "Tomorrow", "in 9 days".
    var sacredRelativePhrase: String {
        let days = daysFromNow
        switch days {
        case 0: return "Today"
        case 1: return "Tomorrow"
        case let d where d > 1: return "in \(d) days"
        case -1: return "Yesterday"
        default: return "\(-days) days ago"
        }
    }

    /// For a yearly-recurring date, the next occurrence on or after today,
    /// preserving month and day.
    func nextYearlyOccurrence(from reference: Date = Date()) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.month, .day], from: self)
        let refYear = cal.component(.year, from: reference)

        var candidate = DateComponents()
        candidate.year = refYear
        candidate.month = comps.month
        candidate.day = comps.day

        let today = cal.startOfDay(for: reference)
        if let thisYear = cal.date(from: candidate), cal.startOfDay(for: thisYear) >= today {
            return thisYear
        }
        candidate.year = refYear + 1
        return cal.date(from: candidate) ?? self
    }
}
