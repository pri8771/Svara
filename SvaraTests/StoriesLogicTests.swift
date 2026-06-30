import XCTest
@testable import Svara

/// Covers Stories filtering, search, featured rotation, and content safety.
final class StoriesLogicTests: XCTestCase {

    private func story(
        _ id: String,
        theme: StoryTheme = .wisdom,
        deity: String = "Deity",
        title: String? = nil,
        tags: [String] = []
    ) -> Story {
        Story(
            id: id, deity: deity, title: title ?? id, theme: theme, durationMinutes: 4,
            bodyMarkdown: "Body.", moralOrMeaning: "One way to understand this.",
            symbolism: [], reflectionPrompt: "When did you feel this?",
            relatedMantraId: nil, relatedFestivalId: nil,
            traditionNote: "Stories vary by tradition, region, and family lineage.",
            sourceName: "Source", sourceNote: "Note", reviewStatus: "reviewed",
            region: ["pan-India"], tags: tags
        )
    }

    private func utcCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var c = DateComponents(); c.year = y; c.month = m; c.day = d; c.hour = 12
        return utcCalendar().date(from: c)!
    }

    // MARK: Theme filter

    func testThemeFilterReturnsSubset() {
        let svc = StoriesService(stories: [
            story("a", theme: .courage), story("b", theme: .wisdom), story("c", theme: .courage)
        ])
        XCTAssertEqual(Set(svc.stories(for: .courage).map(\.id)), ["a", "c"])
        XCTAssertEqual(svc.stories(for: .wisdom).map(\.id), ["b"])
        XCTAssertEqual(svc.stories(for: nil).count, 3, "nil theme returns all")
        XCTAssertTrue(svc.stories(for: .devotion).isEmpty)
    }

    // MARK: Search

    func testSearchMatchesTitleDeityAndTags() {
        let ganesha = story("g", deity: "Ganesha", title: "The Remover of Obstacles", tags: ["beginnings"])
        let durga = story("d", deity: "Durga", title: "The Fierce Protector", tags: ["strength", "courage"])

        XCTAssertTrue(ganesha.matches(search: "obstacle"), "title match")
        XCTAssertTrue(ganesha.matches(search: "ganesha"), "deity match")
        XCTAssertTrue(ganesha.matches(search: "BEGIN"), "tag match, case-insensitive")
        XCTAssertTrue(durga.matches(search: "courage"))
        XCTAssertFalse(ganesha.matches(search: "lakshmi"))
        XCTAssertTrue(ganesha.matches(search: "   "), "blank query matches everything")
    }

    @MainActor
    func testViewModelFilterCombinesThemeAndSearch() {
        let vm = StoriesViewModel()
        let svc = StoriesService(stories: [
            story("g", theme: .beginnings, deity: "Ganesha", title: "Obstacles", tags: ["beginnings"]),
            story("s", theme: .wisdom, deity: "Saraswati", title: "Knowledge", tags: ["wisdom"])
        ])
        vm.load(service: svc)
        vm.selectedTheme = .beginnings
        XCTAssertEqual(vm.filtered().map(\.id), ["g"])
        vm.searchText = "saraswati"
        XCTAssertTrue(vm.filtered().isEmpty, "theme + search both applied")
        vm.selectedTheme = nil
        XCTAssertEqual(vm.filtered().map(\.id), ["s"])
    }

    // MARK: Featured rotation

    func testFeaturedStoryIsDeterministicPerDay() {
        let svc = StoriesService(stories: [story("a"), story("b"), story("c")])
        let cal = utcCalendar()
        let day = date(2026, 6, 28)
        XCTAssertEqual(svc.featuredStory(for: day, calendar: cal)?.id,
                       svc.featuredStory(for: day, calendar: cal)?.id)
        // Consecutive UTC days rotate to a different story.
        let next = cal.date(byAdding: .day, value: 1, to: day)!
        XCTAssertNotEqual(svc.featuredStory(for: day, calendar: cal)?.id,
                          svc.featuredStory(for: next, calendar: cal)?.id)
    }

    func testFeaturedStoryNilWhenEmpty() {
        XCTAssertNil(StoriesService(stories: []).featuredStory())
    }

    // MARK: Bundled content safety

    func testBundledLibraryHasSevenStories() {
        let svc = StoriesService(bundle: .main)
        XCTAssertGreaterThanOrEqual(svc.allStories().count, 7)
    }

    func testBundledLibraryValidatesCleanly() {
        let issues = ContentValidation.validateStoryLibrary(StoriesService(bundle: .main).allStories())
        XCTAssertTrue(issues.isEmpty, issues.map(\.description).joined(separator: "\n"))
    }

    func testNoForbiddenTermsInStories() {
        let forbiddenWords: Set<String> = ["darshan", "karma", "failed", "fail", "wrong", "lives", "hearts", "puja", "offering", "offerings", "ritual"]
        let forbiddenPhrases = ["virtual puja", "karma points", "live darshan"]

        for story in StoriesService(bundle: .main).allStories() {
            let strings = [story.title, story.bodyMarkdown, story.moralOrMeaning,
                           story.reflectionPrompt, story.traditionNote]
                + story.symbolism.map(\.meaning)
            for text in strings {
                let lower = text.lowercased()
                for phrase in forbiddenPhrases {
                    XCTAssertFalse(lower.contains(phrase), "phrase '\(phrase)' in \(story.id): \(text)")
                }
                let tokens = Set(lower.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })
                let hits = tokens.intersection(forbiddenWords)
                XCTAssertTrue(hits.isEmpty, "forbidden word(s) \(hits) in \(story.id): \(text)")
            }
        }
    }
}
