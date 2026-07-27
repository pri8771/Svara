import XCTest

/// End-to-end coverage of Svara's core loop, driven through the real UI:
/// onboarding -> start a practice -> complete it -> streak updates -> browse
/// Festivals and Stories.
///
/// Every test launches with `-UITestResetState`, which `AppEnvironment.live()`
/// (see `Svara/App/AppEnvironment.swift`) uses to wipe persisted UserDefaults
/// state before the app boots, so each run starts from a fresh install: the
/// onboarding carousel and a 0-day streak, regardless of what a prior run left
/// on this simulator.
final class SvaraUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-UITestResetState"]
        app.launch()
        return app
    }

    /// The Today streak banner is collapsed via `.accessibilityElement(children:
    /// .combine)` with a custom label of the form "<n> day streak. <n> Svara
    /// points." (see `TodayView.streakBanner`). Because the whole card becomes
    /// one accessibility element (not a plain `StaticText`), match it with a
    /// type-agnostic descendant query rather than `app.staticTexts[...]`.
    private func streakElement(_ app: XCUIApplication, days: Int) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "\(days) day streak"))
            .firstMatch
    }

    /// Dismisses the first-run onboarding carousel via its "Skip" action, which
    /// is the fastest deterministic path past it (see `OnboardingView.swift`).
    private func skipOnboarding(_ app: XCUIApplication) {
        let skip = app.buttons["Skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 5), "Onboarding's Skip button should appear on first launch")
        skip.tap()
    }

    // MARK: - Core loop

    /// Onboarding -> pick a practice on Today -> complete it -> streak updates
    /// -> Festivals -> Stories. This is Svara's entire daily habit loop in one
    /// pass.
    func testOnboardingThroughPracticeCompletionUpdatesStreakThenBrowseFestivalsAndStories() throws {
        let app = launchApp()
        skipOnboarding(app)

        // Land on Today with a fresh 0-day streak.
        let streakBanner = streakElement(app, days: 0)
        XCTAssertTrue(streakBanner.waitForExistence(timeout: 5), "Fresh state should start at a 0-day streak")

        // Today's practice cards carry a rich accessibility label starting
        // "<time of day> practice: <title>." (see PracticeCard.swift). Grab the
        // first one rather than assuming a specific title, since practices are
        // ordered relative to the current time of day.
        let practiceButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] ' practice:'")
        ).firstMatch
        XCTAssertTrue(practiceButton.waitForExistence(timeout: 5), "Today should list at least one practice")
        practiceButton.tap()

        // The practice player opens on its intro phase with a "Begin" button.
        // (PrimaryButton pairs the title with a systemImage, so match by
        // containment rather than assuming the label is exactly "Begin".)
        let beginButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Begin'")).firstMatch
        XCTAssertTrue(beginButton.waitForExistence(timeout: 5), "Practice player should open on the intro phase")
        beginButton.tap()

        // Skip the guided timer via "Finish now" rather than waiting out the
        // full practice duration.
        let finishNowButton = app.buttons["Finish now"]
        XCTAssertTrue(finishNowButton.waitForExistence(timeout: 5), "Active phase should offer Finish now")
        finishNowButton.tap()

        // Completion screen: "Well done", points earned, streak, and a Done button.
        let wellDone = app.staticTexts["Well done"]
        XCTAssertTrue(wellDone.waitForExistence(timeout: 5), "Completing a practice should reach the Well done screen")
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 2))
        doneButton.tap()

        // Back on Today, the streak has advanced from 0 to 1 day.
        let updatedStreak = streakElement(app, days: 1)
        XCTAssertTrue(updatedStreak.waitForExistence(timeout: 5), "Completing a practice should advance the streak to 1 day")

        // Navigate to Festivals and confirm real content renders.
        let festivalsTab = app.tabBars.buttons["Festivals"]
        XCTAssertTrue(festivalsTab.waitForExistence(timeout: 5))
        festivalsTab.tap()
        let festivalMoments = app.staticTexts["Festival Moments"]
        XCTAssertTrue(festivalMoments.waitForExistence(timeout: 5), "Festivals tab should load its header")

        // Navigate to Stories and confirm its header renders too.
        let storiesTab = app.tabBars.buttons["Stories"]
        XCTAssertTrue(storiesTab.waitForExistence(timeout: 5))
        storiesTab.tap()
        let storiesHeader = app.staticTexts["Stories"]
        XCTAssertTrue(storiesHeader.waitForExistence(timeout: 5), "Stories tab should load its header")
    }

    /// A narrower regression check: the onboarding carousel itself is
    /// navigable via "Continue" through all three pages to "Get Started".
    func testOnboardingCarouselAdvancesThroughAllPagesToGetStarted() throws {
        let app = launchApp()

        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5))
        continueButton.tap() // page 1 -> 2
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5))
        continueButton.tap() // page 2 -> 3

        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 5), "Final onboarding page should offer Get Started")
        getStarted.tap()

        // Landed on Today.
        XCTAssertTrue(app.staticTexts["Today's practices"].waitForExistence(timeout: 5))
    }
}
