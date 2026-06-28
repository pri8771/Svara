import Foundation

/// Loads the production Stories & Symbols library from the bundled
/// `seed_story_library.json`, with an in-code fallback (`SeedContent.storyLibrary`).
///
/// (The legacy `StorySymbol` catalogue still loads from `seed_stories.json` via
/// `SeedContentProvider`; this service is the Phase 2D `Story` model and uses a
/// separate file so the existing seed/test contract is untouched.)
final class StoriesService {
    private let allStoriesValue: [Story]

    init(bundle: Bundle = .main) {
        let decoder = JSONDecoder()
        if let url = bundle.url(forResource: "seed_story_library", withExtension: "json", subdirectory: "SeedData")
            ?? bundle.url(forResource: "seed_story_library", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? decoder.decode([Story].self, from: data),
           !decoded.isEmpty {
            allStoriesValue = decoded
        } else {
            #if DEBUG
            print("⚠️ StoriesService: seed_story_library.json missing/invalid; using in-code fallback.")
            #endif
            allStoriesValue = SeedContent.storyLibrary
        }
        #if DEBUG
        for issue in ContentValidation.validateStoryLibrary(allStoriesValue) {
            print("⚠️ ContentValidation [story] \(issue.context): \(issue.message)")
        }
        #endif
    }

    /// Test/explicit initialiser from a fixed list.
    init(stories: [Story]) {
        allStoriesValue = stories
    }

    func allStories() -> [Story] { allStoriesValue }

    /// Stories for a theme; `nil` returns all.
    func stories(for theme: StoryTheme?) -> [Story] {
        guard let theme else { return allStoriesValue }
        return allStoriesValue.filter { $0.theme == theme }
    }

    func story(id: String) -> Story? {
        allStoriesValue.first { $0.id == id }
    }

    /// A featured story that rotates once per local day (deterministic).
    func featuredStory() -> Story? { featuredStory(for: Date()) }

    func featuredStory(for date: Date, calendar: Calendar = .current) -> Story? {
        guard !allStoriesValue.isEmpty else { return nil }
        let day = calendar.startOfDay(for: date).timeIntervalSince1970
        let index = Int((day / 86_400).rounded(.down)) % allStoriesValue.count
        let safe = (index % allStoriesValue.count + allStoriesValue.count) % allStoriesValue.count
        return allStoriesValue[safe]
    }
}
