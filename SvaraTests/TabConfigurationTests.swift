import XCTest
@testable import Svara

/// Strategy lock (Codex↔Claude): the focused beta is Today + Learn primary, with
/// Festivals/Stories staged out of primary navigation. These tests are the
/// executable invariant — they fail if a staged tab ever reappears as a primary
/// beta surface, or if the core (Today/Learn) is ever droppable.
final class TabConfigurationTests: XCTestCase {

    func testTodayAndLearnAreAlwaysCoreAndFirst() {
        for flags in [FeatureFlags.full, .betaScope] {
            let tabs = flags.primaryTabs
            XCTAssertEqual(Array(tabs.prefix(2)), [.today, .learn],
                           "Today and Learn must always be the first two primary tabs.")
            XCTAssertTrue(tabs.contains(.today) && tabs.contains(.learn))
        }
        XCTAssertTrue(MainTab.today.isCore)
        XCTAssertTrue(MainTab.learn.isCore)
        XCTAssertFalse(MainTab.festivals.isCore)
        XCTAssertFalse(MainTab.stories.isCore)
        XCTAssertFalse(MainTab.profile.isCore)
    }

    func testBetaScopeStagesOutFestivalsAndStories() {
        let tabs = FeatureFlags.betaScope.primaryTabs
        XCTAssertEqual(tabs, [.today, .learn, .profile],
                       "Beta scope must be exactly Today + Learn (+ Profile).")
        XCTAssertFalse(tabs.contains(.festivals), "Festivals must be staged out of the beta primary surface.")
        XCTAssertFalse(tabs.contains(.stories), "Stories must be staged out of the beta primary surface.")
    }

    func testFullProductExposesAllSurfaces() {
        let tabs = FeatureFlags.full.primaryTabs
        XCTAssertEqual(tabs, [.today, .learn, .festivals, .stories, .profile])
    }

    func testFlagsActuallyControlOptionalTabs() {
        let onlyFestivals = FeatureFlags(festivalsTab: true, storiesTab: false, contentSharing: false)
        XCTAssertEqual(onlyFestivals.primaryTabs, [.today, .learn, .festivals, .profile])
        let onlyStories = FeatureFlags(festivalsTab: false, storiesTab: true, contentSharing: false)
        XCTAssertEqual(onlyStories.primaryTabs, [.today, .learn, .stories, .profile])
    }

    /// No-social invariant: the entire primary-surface universe is the fixed,
    /// non-social set. There is no feed/community/followers/comments/leaderboard
    /// surface anywhere in the navigation registry ("private, not a feed").
    func testNoSocialSurfaceInNavigationRegistry() {
        XCTAssertEqual(Set(MainTab.allCases), [.today, .learn, .festivals, .stories, .profile])
        let forbidden = ["feed", "community", "follow", "followers", "comment", "comments",
                         "leaderboard", "social", "friends", "chat", "messages", "groups"]
        for tab in MainTab.allCases {
            for word in forbidden {
                XCTAssertNotEqual(tab.rawValue.lowercased(), word,
                                  "Navigation must contain no social surface; found '\(tab.rawValue)'.")
            }
        }
    }
}
