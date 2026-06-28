import XCTest

/// V0 screen-walk: launches My Mandir, walks through onboarding into the altar,
/// then visits each ritual surface (Offer / Reflect / Thread) and Settings,
/// capturing a screenshot at every step as a CI artifact.
///
/// Existence checks only — no behavioral assertions beyond the V0 contract
/// guardrails (no tab bar, no streak/badge UI). The app is fully offline; the
/// test never touches the network.
final class MyMandirV0WalkUITests: XCTestCase {

    private let timeout: TimeInterval = 20

    override func setUp() {
        super.setUp()
        // Capture as many screenshots as possible even if one step regresses.
        continueAfterFailure = true
    }

    func testV0ScreenWalk() {
        let app = XCUIApplication()
        // Honored only if the app chooses to support it; otherwise we tap through.
        app.launchEnvironment["XCTEST_SKIP_ONBOARDING"] = "1"
        app.launch()

        completeOnboardingIfPresent(app)

        // 1 — Altar (unlit)
        let altar = element(app, "altar.root")
        XCTAssertTrue(altar.waitForExistence(timeout: timeout), "altar.root did not appear")
        attach(app, "01-altar")

        // 2 — Altar (lit): hold the wick (a deliberate, non-tap gesture)
        let wick = element(app, "altar.lightButton")
        if wick.waitForExistence(timeout: 5) {
            wick.press(forDuration: 1.6)
            sleep(2)
        }
        attach(app, "02-altar-lit")

        // 3 — Offer
        tapMode(app, "mandir.mode.offer")
        XCTAssertTrue(element(app, "offer.root").waitForExistence(timeout: timeout), "offer.root did not appear")
        attach(app, "03-offer")
        tapMode(app, "mandir.mode.altar")

        // 4 — Reflect
        tapMode(app, "mandir.mode.reflect")
        XCTAssertTrue(element(app, "reflect.root").waitForExistence(timeout: timeout), "reflect.root did not appear")
        attach(app, "04-reflect")
        tapMode(app, "mandir.mode.altar")

        // 5 — Thread
        tapMode(app, "mandir.mode.thread")
        XCTAssertTrue(element(app, "thread.root").waitForExistence(timeout: timeout), "thread.root did not appear")
        attach(app, "05-thread")
        tapMode(app, "mandir.mode.altar")

        // 6 — Settings (pushed via the gear)
        let gear = app.buttons["Settings"]
        if gear.waitForExistence(timeout: timeout) { gear.tap() }
        XCTAssertTrue(element(app, "settings.root").waitForExistence(timeout: timeout), "settings.root did not appear")
        attach(app, "06-settings")

        // V0 contract guardrails
        XCTAssertEqual(app.tabBars.count, 0, "V0 must not have a tab bar")
        XCTAssertFalse(hasText(app, "streak"), "V0 must not surface streaks")
        XCTAssertFalse(hasText(app, "badge"), "V0 must not surface badges")
    }

    // MARK: - Onboarding walk

    private func completeOnboardingIfPresent(_ app: XCUIApplication) {
        let begin = app.buttons["Begin"]
        guard begin.waitForExistence(timeout: 10) else { return } // already inside the mandir
        attach(app, "00-onboarding")
        begin.tap()

        let cont = app.buttons["onboarding.continueButton"]

        // Step 2 — pick the first intention, then Continue.
        let firstIntention = app.scrollViews.buttons.element(boundBy: 0)
        if firstIntention.waitForExistence(timeout: timeout) { firstIntention.tap() }
        tapIfHittable(cont)

        // Step 3 — name the mandir, then Continue.
        let nameField = app.textFields["My Mandir"]
        if nameField.waitForExistence(timeout: timeout) {
            nameField.tap()
            nameField.typeText("Test Mandir")
        }
        tapIfHittable(cont)

        // Step 4 — choose the first seeded devata, then Continue.
        let firstDevata = app.scrollViews.buttons.element(boundBy: 0)
        if firstDevata.waitForExistence(timeout: timeout) { firstDevata.tap() }
        tapIfHittable(cont)

        // Step 5 — enter the mandir without making a first sankalp.
        let enter = app.buttons["Enter my mandir"]
        if enter.waitForExistence(timeout: timeout) { enter.tap() }
    }

    // MARK: - Helpers

    /// Match by accessibility identifier across any element type (containers
    /// surface as `.other`, buttons as `.button`, etc.).
    private func element(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    private func tapMode(_ app: XCUIApplication, _ id: String) {
        let btn = app.buttons[id]
        if btn.waitForExistence(timeout: timeout) { btn.tap() }
    }

    private func tapIfHittable(_ element: XCUIElement) {
        if element.waitForExistence(timeout: timeout) && element.isHittable {
            element.tap()
        }
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
