import XCTest
@testable import Svara

/// Guards the Festivals content: all required festivals are present and richly
/// authored, with respectful, non-prescriptive, non-ritual-simulation copy.
final class FestivalContentTests: XCTestCase {

    private var provider: SeedContentProvider!
    private let required = [
        "festival.diwali", "festival.holi", "festival.navaratri",
        "festival.ganeshchaturthi", "festival.janmashtami",
        "festival.rakshabandhan", "festival.makarsankranti"
    ]

    override func setUp() {
        super.setUp()
        provider = SeedContentProvider(bundle: .main)
    }

    func testAllRequiredFestivalsPresent() {
        let ids = Set(provider.festivals.map(\.id))
        for id in required {
            XCTAssertTrue(ids.contains(id), "missing required festival: \(id)")
        }
    }

    func testRequiredFestivalsAreRichlyAuthored() {
        for id in required {
            guard let f = provider.festivals.first(where: { $0.id == id }) else {
                XCTFail("missing \(id)"); continue
            }
            XCTAssertNotNil(f.shortDescription, "\(id) missing shortDescription")
            XCTAssertFalse(f.whyItMattersText.isEmpty, "\(id) missing whyItMatters/significance")
            XCTAssertFalse(f.story.isEmpty, "\(id) missing story")
            XCTAssertFalse(f.symbols.isEmpty, "\(id) missing symbols")
            XCTAssertNotNil(f.familyPrompt, "\(id) missing familyPrompt")
            XCTAssertFalse(f.regionTags.isEmpty, "\(id) missing regionTags")
            XCTAssertNotNil(f.reviewStatus, "\(id) missing reviewStatus")
            // At least one tiny activity with real steps.
            let activity = try? XCTUnwrap(f.tinyActivity)
            XCTAssertNotNil(activity, "\(id) missing tinyActivity")
            XCTAssertGreaterThanOrEqual(activity?.steps.count ?? 0, 2, "\(id) activity needs steps")
            XCTAssertGreaterThan(activity?.points ?? 0, 0, "\(id) activity needs points")
            // Region tags must be valid regions.
            for tag in f.regionTags {
                XCTAssertNotNil(FestivalRegion(rawValue: tag), "\(id) has invalid region tag '\(tag)'")
            }
        }
    }

    func testFestivalsAcknowledgeVariation() {
        // Respectful, non-absolutist framing: dates/customs can vary.
        for id in required {
            guard let f = provider.festivals.first(where: { $0.id == id }) else { continue }
            let combined = ((f.traditionNote ?? "") + " " + f.story).lowercased()
            XCTAssertTrue(combined.contains("vary"), "\(id) should acknowledge regional variation")
            XCTAssertTrue(f.isDateApproximate, "\(id) dates should be marked approximate")
        }
    }

    func testNoForbiddenPrimandirTermsInFestivals() {
        let issues = ContentValidation.scanForbiddenTerms(
            mantras: [], lessons: [], festivals: provider.festivals,
            stories: [], shlokas: [], achievements: []
        )
        XCTAssertTrue(issues.isEmpty, "Forbidden terms in festivals:\n" + issues.map(\.description).joined(separator: "\n"))
    }

    func testNoRitualSimulationCopy() {
        let ritualSim = [
            "virtual puja", "online puja", "live darshan", "darshan booking",
            "temple marketplace", "priest booking", "book a priest",
            "tap to ring", "tap to light", "ring the bell", "blow the conch",
            "wave the diya", "prasad delivery"
        ]
        for festival in provider.festivals {
            for string in userFacingStrings(festival) {
                let lower = string.lowercased()
                for phrase in ritualSim {
                    XCTAssertFalse(lower.contains(phrase),
                                   "Ritual-simulation phrase \"\(phrase)\" found in \(festival.id): \"\(string)\"")
                }
            }
        }
    }

    private func userFacingStrings(_ f: Festival) -> [String] {
        var strings = [f.name, f.tagline, f.significance, f.story, f.whyItMattersText]
        strings += [f.shortDescription, f.familyPrompt].compactMap { $0 }
        strings += f.activities
        strings += f.symbols.flatMap { [$0.name, $0.meaning] }
        if let a = f.tinyActivity {
            strings += [a.title] + a.steps + [a.reflectionPrompt].compactMap { $0 }
        }
        return strings
    }
}
