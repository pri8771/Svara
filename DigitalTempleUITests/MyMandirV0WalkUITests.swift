import XCTest

/// V0 screen-walk: launches My Mandir, walks through onboarding into the altar,
/// then visits each ritual surface (Offer / Reflect / Thread) and Settings,
/// capturing a screenshot at every step as a CI artifact.
///
/// Navigation is driven by visible button labels (robust across SwiftUI
/// versions); each screen is confirmed by an accessibility identifier OR a
/// unique on-screen text. Existence checks only, plus the V0 contract
/// guardrails (no tab bar, no streak/badge UI). The app is fully offline.
final class MyMandirV0WalkUITests: XCTestCase {

    private let timeout: TimeInterval = 15

    override func setUp() {
        super.setUp()
        continueAfterFailure = true   // capture as many screenshots as possible
    }

    func testV0ScreenWalk() {
        let app = XCUIApplication()
        app.launch()

        completeOnboardingIfPresent(app)

        // 1 — Altar (unlit)
        XCTAssertTrue(waitScreen(app, id: "altar.root", textContains: "Hold the wick"),
                      "Altar did not appear")
        attach(app, "01-altar")

        // 2 — Altar (lit): hold the wick (a deliberate, non-tap gesture)
        let wick = match(app, id: "altar.lightButton", label: "Hold to light the lamp")
        if wick.waitForExistence(timeout: 5) {
            wick.press(forDuration: 1.6)
            sleep(2)
        }
        attach(app, "02-altar-lit")

        // 3 — Offer
        tapButton(app, "Offer")
        XCTAssertTrue(waitScreen(app, id: "offer.root", textContains: "Place an offering"),
                      "Offer did not appear")
        attach(app, "03-offer")
        tapButton(app, "Altar")

        // 4 — Reflect
        tapButton(app, "Reflect")
        XCTAssertTrue(waitScreen(app, id: "reflect.root", textContains: "intention"),
                      "Reflect did not appear")
        attach(app, "04-reflect")
        tapButton(app, "Altar")

        // 5 — Thread
        tapButton(app, "Thread")
        XCTAssertTrue(waitScreen(app, id: "thread.root", textContains: "returned"),
                      "Thread did not appear")
        attach(app, "05-thread")
        tapButton(app, "Altar")

        // 6 — Settings (pushed via the gear)
        tapButton(app, "Settings")
        XCTAssertTrue(waitScreen(app, id: "settings.root", textContains: "devotional identity"),
                      "Settings did not appear")
        attach(app, "06-settings")

        // V0 contract guardrails
        XCTAssertEqual(app.tabBars.count, 0, "V0 must not have a tab bar")
        XCTAssertFalse(hasText(app, "streak"), "V0 must not surface streaks")
        XCTAssertFalse(hasText(app, "badge"), "V0 must not surface badges")
    }

    // MARK: - Onboarding walk (by visible labels)

    private func completeOnboardingIfPresent(_ app: XCUIApplication) {
        let begin = app.buttons["Begin"]
        guard begin.waitForExistence(timeout: 12) else { return } // already inside the mandir
        attach(app, "00-onboarding")
        begin.tap()

        // Step 2 — pick the first intention, then Continue.
        let firstIntention = app.scrollViews.buttons.element(boundBy: 0)
        if firstIntention.waitForExistence(timeout: timeout) { firstIntention.tap() }
        tapButton(app, "Continue")

        // Step 3 — name the mandir (keyboard up; Continue floats above it), then Continue.
        let nameField = app.textFields["My Mandir"]
        if nameField.waitForExistence(timeout: timeout) {
            nameField.tap()
            nameField.typeText("Test Mandir")
        }
        tapButton(app, "Continue")

        // Step 4 — choose the first seeded devata, then Continue.
        let firstDevata = app.scrollViews.buttons.element(boundBy: 0)
        if firstDevata.waitForExistence(timeout: timeout) { firstDevata.tap() }
        tapButton(app, "Continue")

        // Step 5 — enter the mandir without making a first sankalp.
        tapButton(app, "Enter my mandir")
    }

    // MARK: - Helpers

    /// Tap a button by its (accessibility) label, with a coordinate fallback in
    /// case the keyboard makes the element report as not hittable.
    private func tapButton(_ app: XCUIApplication, _ label: String) {
        let button = app.buttons[label]
        guard button.waitForExistence(timeout: timeout) else { return }
        if button.isHittable {
            button.tap()
        } else {
            button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }

    /// Match an element by accessibility identifier OR exact label.
    private func match(_ app: XCUIApplication, id: String, label: String) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier == %@ OR label == %@", id, label)
        return app.descendants(matching: .any).matching(predicate).firstMatch
    }

    /// Wait for a screen identified by its root identifier OR a unique on-screen text.
    private func waitScreen(_ app: XCUIApplication, id: String, textContains: String) -> Bool {
        let predicate = NSPredicate(format: "identifier == %@ OR label CONTAINS[c] %@", id, textContains)
        return app.descendants(matching: .any).matching(predicate).firstMatch.waitForExistence(timeout: timeout)
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func hasText(_ app: XCUIApplication, _ substring: String) -> Bool {
        let needle = substring.lowercased()
        return app.staticTexts.allElementsBoundByIndex.contains {
            $0.label.lowercased().contains(needle)
        }
    }
}
