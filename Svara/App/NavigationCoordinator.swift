import SwiftUI

/// Central, observable navigation state so content (e.g. a shloka-of-the-day)
/// can deep-link into the app. `AppDeepLink.Destination` is parsed from a
/// content string and turned into a real navigation: switch the primary tab and,
/// where applicable, ask the destination tab to open a specific item.
///
/// This is what makes `AppDeepLink` *routable* rather than parse-only, and it is
/// also the seam a future Home-Screen widget or notification would use.
@Observable
@MainActor
final class NavigationCoordinator {
    /// The selected primary tab. Bound by `MainTabView`.
    var selection: MainTab = .today

    /// Pending item ids each tab consumes (then clears) to open a specific
    /// screen on arrival.
    var todayMantraID: String?
    var learnLessonID: String?
    var storyID: String?

    /// Routes a raw deep-link string (e.g. "mantra:mantra.om", "stories").
    func route(deepLink raw: String) {
        route(AppDeepLink.parse(raw))
    }

    func route(_ destination: AppDeepLink.Destination) {
        switch destination {
        case .tab(let link):
            selection = NavigationCoordinator.tab(for: link)
        case .mantra(let id):
            selection = .today
            todayMantraID = id
        case .lesson(let id):
            selection = .learn
            learnLessonID = id
        case .story(let id):
            selection = .stories
            storyID = id
        case .festival:
            selection = .festivals
        case .unknown:
            break
        }
    }

    static func tab(for link: AppDeepLink) -> MainTab {
        switch link {
        case .today: return .today
        case .learn: return .learn
        case .festivals: return .festivals
        case .stories: return .stories
        case .profile: return .profile
        }
    }
}
