import Foundation

/// Drives the Stories & Symbols tab: the catalogue, the daily featured story,
/// and theme + search filtering. Loads from `StoriesService` (local/bundle).
@MainActor
final class StoriesViewModel: ObservableObject {
    @Published var selectedTheme: StoryTheme?
    @Published var searchText: String = ""
    @Published var stories: [Story] = []
    @Published var featuredStory: Story?

    private var service: StoriesService?

    func load(service: StoriesService) {
        self.service = service
        stories = service.allStories()
        featuredStory = service.featuredStory()
    }

    /// Stories after applying the theme filter and the search query.
    func filtered() -> [Story] {
        var result = stories
        if let selectedTheme {
            result = result.filter { $0.theme == selectedTheme }
        }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { $0.matches(search: query) }
        }
        return result
    }

    /// Themes that actually appear in the catalogue (for the filter row).
    var availableThemes: [StoryTheme] {
        StoryTheme.allCases.filter { theme in stories.contains { $0.theme == theme } }
    }
}
