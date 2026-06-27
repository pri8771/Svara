import Foundation

@Observable
@MainActor
final class StoriesViewModel {
    private(set) var stories: [StorySymbol] = []
    private(set) var isLoading = true
    var selectedTheme: SpiritualTheme?

    func load(content: ContentRepository) async {
        isLoading = true
        stories = await content.stories()
        isLoading = false
    }

    /// Themes that actually appear in the catalogue, for the filter row.
    var availableThemes: [SpiritualTheme] {
        var seen = Set<SpiritualTheme>()
        return stories.compactMap { seen.insert($0.theme).inserted ? $0.theme : nil }
    }

    var filteredStories: [StorySymbol] {
        guard let selectedTheme else { return stories }
        return stories.filter { $0.theme == selectedTheme }
    }
}
