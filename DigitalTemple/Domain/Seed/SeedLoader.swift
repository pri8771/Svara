import Foundation
import SwiftData

/// Loads bundled seed content (devatas, sacred dates) into SwiftData on first
/// launch. Idempotent: guarded by a UserDefaults flag and a safety check that
/// the stores are empty, so it never duplicates on subsequent launches.
///
/// All content is local JSON in the app bundle — the app makes no network
/// calls, ever.
@MainActor
enum SeedLoader {

    // MARK: Decodable shapes (match the JSON files)

    private struct DevataSeed: Decodable {
        let name: String
        let nameDevanagari: String
        let tradition: String
        let summary: String
        let symbolicNote: String
    }

    private struct SacredDateSeed: Decodable {
        let name: String
        let nameDevanagari: String?
        let month: Int
        let day: Int
        let year: Int?
        let yearlyRecurring: Bool
        let devataAssociation: String?
        let significance: String
        let regionRelevance: [String]
        let tradition: String?
    }

    // MARK: Entry point

    /// Seeds the store if needed. Safe to call on every launch.
    static func seedIfNeeded(context: ModelContext, defaults: UserDefaults = .standard) {
        let alreadySeeded = defaults.bool(forKey: AppConstants.DefaultsKey.hasSeededData)
        let storeIsEmpty = ((try? context.fetch(FetchDescriptor<Devata>()))?.isEmpty ?? true)
        guard !alreadySeeded || storeIsEmpty else { return }

        seedDevatas(context: context)
        seedSacredDates(context: context)

        do {
            try context.save()
            defaults.set(true, forKey: AppConstants.DefaultsKey.hasSeededData)
        } catch {
            print("⚠️ SeedLoader save failed: \(error)")
        }
    }

    // MARK: Devatas

    private static func seedDevatas(context: ModelContext) {
        guard ((try? context.fetch(FetchDescriptor<Devata>()))?.isEmpty ?? true) else { return }
        let seeds: [DevataSeed] = decode(AppConstants.SeedResource.devatas)
        for seed in seeds {
            context.insert(Devata(
                name: seed.name,
                nameDevanagari: seed.nameDevanagari,
                tradition: seed.tradition,
                summary: seed.summary,
                symbolicNote: seed.symbolicNote
            ))
        }
    }

    // MARK: Sacred dates

    private static func seedSacredDates(context: ModelContext) {
        guard ((try? context.fetch(FetchDescriptor<SacredDateEntry>()))?.isEmpty ?? true) else { return }
        let seeds: [SacredDateSeed] = decode(AppConstants.SeedResource.sacredDates)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kolkata") ?? .current

        for seed in seeds {
            var comps = DateComponents()
            comps.year = seed.year ?? 2026
            comps.month = seed.month
            comps.day = seed.day
            let date = calendar.date(from: comps) ?? Date()

            let regions = seed.regionRelevance.compactMap { Region(rawValue: $0) }

            context.insert(SacredDateEntry(
                name: seed.name,
                nameDevanagari: seed.nameDevanagari,
                date: date,
                yearlyRecurring: seed.yearlyRecurring,
                devataAssociation: seed.devataAssociation,
                significance: seed.significance,
                regionRelevance: regions.isEmpty ? [.panIndia] : regions,
                tradition: seed.tradition
            ))
        }
    }

    // MARK: JSON decoding

    private static func decode<T: Decodable>(_ resource: String) -> [T] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            print("⚠️ SeedLoader: missing bundled resource \(resource).json")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("⚠️ SeedLoader: failed to decode \(resource).json — \(error)")
            return []
        }
    }
}
