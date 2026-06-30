import XCTest
@testable import Svara

/// F12: `AppDeepLink` is now routable, not parse-only. These tests pin the
/// contract that the shloka-of-the-day (and any future widget/notification) deep
/// link resolves to the right tab + pending item.
@MainActor
final class NavigationCoordinatorTests: XCTestCase {

    func testTabTargetsSwitchTab() {
        let nav = NavigationCoordinator()
        nav.route(deepLink: "stories")
        XCTAssertEqual(nav.selection, .stories)
        nav.route(deepLink: "learn")
        XCTAssertEqual(nav.selection, .learn)
        nav.route(deepLink: "profile")
        XCTAssertEqual(nav.selection, .profile)
        nav.route(deepLink: "today")
        XCTAssertEqual(nav.selection, .today)
    }

    func testMantraTargetPresentsOnToday() {
        let nav = NavigationCoordinator()
        nav.selection = .stories
        nav.route(deepLink: "mantra:mantra.om")
        XCTAssertEqual(nav.selection, .today, "Mantra deep links present on Today.")
        XCTAssertEqual(nav.todayMantraID, "mantra.om")
    }

    func testLessonTargetSwitchesToLearnWithPendingID() {
        let nav = NavigationCoordinator()
        nav.route(deepLink: "lesson:lesson.saraswati.meaning")
        XCTAssertEqual(nav.selection, .learn)
        XCTAssertEqual(nav.learnLessonID, "lesson.saraswati.meaning")
    }

    func testStoryTargetSwitchesToStoriesWithPendingID() {
        let nav = NavigationCoordinator()
        nav.route(deepLink: "story:story.ganesha.beginnings")
        XCTAssertEqual(nav.selection, .stories)
        XCTAssertEqual(nav.storyID, "story.ganesha.beginnings")
    }

    func testUnknownTargetIsANoOp() {
        let nav = NavigationCoordinator()
        nav.selection = .learn
        nav.route(deepLink: "definitely-not-a-link::weird")
        XCTAssertEqual(nav.selection, .learn, "Unknown deep links must not change navigation.")
        XCTAssertNil(nav.todayMantraID)
    }

    /// Every shipped shloka deep link must resolve to a concrete, valid route.
    func testEveryShippedShlokaDeepLinkResolves() throws {
        let provider = SeedContentProvider(bundle: .main)
        let shlokas = try provider.decode([ShlokaOfDay].self, from: "seed_shlokas")
        XCTAssertFalse(shlokas.isEmpty)
        for shloka in shlokas {
            let nav = NavigationCoordinator()
            nav.route(deepLink: shloka.deepLinkTarget)
            // A valid shloka link always lands on a real tab (never .unknown/no-op
            // from a malformed target).
            switch AppDeepLink.parse(shloka.deepLinkTarget) {
            case .unknown:
                XCTFail("shloka \(shloka.id) has an unroutable deepLinkTarget '\(shloka.deepLinkTarget)'")
            default:
                break
            }
        }
    }
}
