import XCTest
import UIKit

/// Broad, user-facing regression coverage for the shipped Svara 1.0 surface.
///
/// These tests intentionally use public accessibility labels instead of
/// implementation details. Each test starts from a fresh local profile. Known
/// product defects are marked with `XCTExpectFailure` so the remaining
/// workflows still execute and produce one complete result bundle.
final class ComprehensiveWorkflowUITests: XCTestCase {
    private enum LessonAction {
        case read
        case listen
        case option(String)
        case syllables([String])
    }

    private struct LessonScript {
        let title: String
        let steps: [(prompt: String, action: LessonAction)]
    }

    private let practiceTitles = [
        "Morning Mantra",
        "Midday Reset",
        "Evening Prayer",
        "Three Gratitudes"
    ]

    private let festivalNames = [
        "Guru Purnima",
        "Raksha Bandhan",
        "Krishna Janmashtami",
        "Ganesh Chaturthi",
        "Navaratri",
        "Diwali",
        "Makar Sankranti & Pongal",
        "Holi"
    ]

    private let festivalActivityStepCounts = [
        "Guru Purnima": 3,
        "Raksha Bandhan": 3,
        "Krishna Janmashtami": 3,
        "Ganesh Chaturthi": 4,
        "Navaratri": 4,
        "Diwali": 4,
        "Makar Sankranti & Pongal": 3,
        "Holi": 4
    ]

    private let storyTitles = [
        "The Remover of Obstacles",
        "The River of Knowledge",
        "The Devoted One",
        "Abundance That Flows",
        "The Still Point",
        "The Fierce Protector",
        "The Courage to Act"
    ]

    private let storySymbols: [String: [String]] = [
        "The Remover of Obstacles": ["Elephant Head", "Broken Tusk", "Modak"],
        "The River of Knowledge": ["Veena", "White Lotus", "Swan"],
        "The Devoted One": ["The Leap", "Mace", "The Mountain"],
        "Abundance That Flows": ["Lotus", "Flowing Coins", "Elephants"],
        "The Still Point": ["Crescent Moon", "Trishul", "Damaru"],
        "The Fierce Protector": ["Lion", "Many Arms", "The Calm Face"],
        "The Courage to Act": ["The Chariot", "The Lowered Bow", "Conch"]
    ]

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    private func freshApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-UITestResetState"] + arguments
        app.launch()
        return app
    }

    private func skipOnboarding(_ app: XCUIApplication) {
        let skip = app.buttons["Skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 8), "Skip should be available on onboarding")
        skip.tap()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 8), "The main tab bar should appear")
    }

    @discardableResult
    private func scrollTo(
        _ element: XCUIElement,
        in app: XCUIApplication,
        maxSwipes: Int = 10
    ) -> Bool {
        if element.exists && element.isHittable { return true }
        for _ in 0..<maxSwipes {
            app.swipeUp()
            if element.exists && element.isHittable { return true }
        }
        return element.exists
    }

    private func practiceButton(_ title: String, app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@ AND label CONTAINS[c] ' practice:'", title)
        ).firstMatch
    }

    private func tapPrimaryButton(_ title: String, app: XCUIApplication, timeout: TimeInterval = 6) {
        let button = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", title)
        ).firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: timeout), "\(title) should exist")
        XCTAssertTrue(button.isEnabled, "\(title) should be enabled")
        button.tap()
    }

    private func waitForHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true AND hittable == true"),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    private func closeNavigationDetail(_ app: XCUIApplication) {
        let back = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 5), "A navigation back button should exist")
        back.tap()
    }

    // MARK: Onboarding and shell

    func testOnboardingSkipFromEveryPageAndReturningLaunch() {
        for continueCount in 0...2 {
            let app = freshApp()
            for _ in 0..<continueCount {
                let button = app.buttons["Continue"]
                XCTAssertTrue(button.waitForExistence(timeout: 5))
                button.tap()
            }
            let skip = app.buttons["Skip"]
            XCTAssertTrue(skip.waitForExistence(timeout: 5), "Skip should remain available on page \(continueCount + 1)")
            skip.tap()
            XCTAssertTrue(app.staticTexts["Today's practices"].waitForExistence(timeout: 5))

            app.terminate()
            app.launchArguments = []
            app.launch()
            XCTAssertTrue(
                app.staticTexts["Today's practices"].waitForExistence(timeout: 5),
                "Onboarding completion should persist after relaunch"
            )
            XCTAssertFalse(app.buttons["Skip"].exists, "Returning users should not see onboarding")
            app.terminate()
        }
    }

    func testEveryPrimaryTabAndTodayReadingPath() {
        let app = freshApp()
        skipOnboarding(app)

        for tab in ["Today", "Learn", "Festivals", "Stories", "Profile"] {
            let tabButton = app.tabBars.buttons[tab]
            XCTAssertTrue(tabButton.waitForExistence(timeout: 5), "\(tab) should be a shipped primary tab")
            tabButton.tap()
        }

        app.tabBars.buttons["Today"].tap()
        let mantra = app.descendants(matching: .any).matching(
            NSPredicate(format: "label BEGINSWITH[c] 'Mantra of the day:'")
        ).firstMatch
        XCTAssertTrue(scrollTo(mantra, in: app), "Mantra of the day should render")
        mantra.tap()
        XCTAssertTrue(app.staticTexts["Sanskrit"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Transliteration"].exists)
        XCTAssertTrue(app.staticTexts["Translation"].exists)
        closeNavigationDetail(app)

        let shloka = app.descendants(matching: .any).matching(
            NSPredicate(format: "label BEGINSWITH[c] 'Shloka of the day.'")
        ).firstMatch
        XCTAssertTrue(scrollTo(shloka, in: app), "Shloka of the day should render")
        shloka.tap()
        XCTAssertFalse(app.alerts.firstMatch.waitForExistence(timeout: 3), "Shloka routing should not present an error alert")
    }

    // MARK: Practices and audio

    func testEveryDailyPracticeOpenAudioCancelAndComplete() {
        let app = freshApp()
        skipOnboarding(app)

        for title in practiceTitles {
            let card = practiceButton(title, app: app)
            XCTAssertTrue(scrollTo(card, in: app), "\(title) should appear on Today")
            card.tap()
            XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 5) || app.buttons["Close activity"].exists)

            let expectsAudio = title == "Morning Mantra" || title == "Evening Prayer"
            if expectsAudio {
                XCTAssertFalse(app.buttons["Play practice audio"].exists, "Audio should not be presented as an intro option")
            } else {
                XCTAssertFalse(app.buttons["Play practice audio"].exists, "\(title) should not invent an audio control")
            }

            tapPrimaryButton("Begin", app: app)
            XCTAssertTrue(app.buttons["Finish now"].waitForExistence(timeout: 5))
            if expectsAudio {
                let pauseAudio = app.buttons["Pause practice audio"]
                XCTAssertTrue(pauseAudio.waitForExistence(timeout: 3), "\(title) audio should start automatically")
                pauseAudio.tap()
                XCTAssertTrue(app.buttons["Play practice audio"].waitForExistence(timeout: 3))
            }
            app.buttons["Finish now"].tap()
            XCTAssertTrue(app.staticTexts["Well done"].waitForExistence(timeout: 5))
            tapPrimaryButton("Done", app: app)

            let completedCard = practiceButton(title, app: app)
            XCTAssertTrue(scrollTo(completedCard, in: app))
            XCTAssertEqual(completedCard.value as? String, "Completed today")
        }

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Achievements"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.descendants(matching: .any).matching(
                NSPredicate(format: "label BEGINSWITH[c] 'Day streak:'")
            ).firstMatch.exists
        )
    }

    func testRepeatPracticeDoesNotAwardTwice() {
        let app = freshApp()
        skipOnboarding(app)

        func finishMorningPractice() {
            let card = practiceButton("Morning Mantra", app: app)
            XCTAssertTrue(scrollTo(card, in: app))
            card.tap()
            tapPrimaryButton("Begin", app: app)
            XCTAssertTrue(app.buttons["Finish now"].waitForExistence(timeout: 5))
            app.buttons["Finish now"].tap()
            tapPrimaryButton("Done", app: app)
        }

        finishMorningPractice()
        app.tabBars.buttons["Profile"].tap()
        let pointsAfterFirst = app.descendants(matching: .any).matching(
            NSPredicate(format: "label BEGINSWITH[c] 'Svara Points:'")
        ).firstMatch.label

        app.tabBars.buttons["Today"].tap()
        finishMorningPractice()
        app.tabBars.buttons["Profile"].tap()
        let pointsAfterRepeat = app.descendants(matching: .any).matching(
            NSPredicate(format: "label BEGINSWITH[c] 'Svara Points:'")
        ).firstMatch.label

        XCTAssertEqual(pointsAfterRepeat, pointsAfterFirst, "Repeating the same completed practice should not re-award points")
    }

    // MARK: Lessons and access control

    func testLessonAudioHintWrongAnswerCompletionAndResult() {
        let app = freshApp()
        skipOnboarding(app)
        app.tabBars.buttons["Learn"].tap()

        let hero = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'The Sound of Om'")
        ).firstMatch
        XCTAssertTrue(hero.waitForExistence(timeout: 8))
        hero.tap()

        XCTAssertTrue(app.staticTexts["Meet Om"].waitForExistence(timeout: 5))
        tapPrimaryButton("Continue", app: app)

        let listen = app.buttons["Chant along softly"]
        XCTAssertTrue(listen.waitForExistence(timeout: 5))
        listen.tap()
        listen.tap()
        tapPrimaryButton("Continue", app: app)

        let check = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Check'")).firstMatch
        XCTAssertTrue(check.waitForExistence(timeout: 5))
        XCTAssertFalse(check.isEnabled, "Check should be disabled before an answer")

        let hint = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'hint'")).firstMatch
        XCTAssertTrue(hint.exists)
        hint.tap()
        XCTAssertTrue(
            app.descendants(matching: .any).matching(
                NSPredicate(format: "label BEGINSWITH[c] 'Hint:'")
            ).firstMatch.exists
        )

        app.buttons["A festival"].tap()
        XCTAssertTrue(check.isEnabled)
        check.tap()
        XCTAssertTrue(
            app.descendants(matching: .any).matching(
                NSPredicate(format: "label CONTAINS[c] 'Almost'")
            ).firstMatch.exists
        )
        tapPrimaryButton("Continue", app: app)
        tapPrimaryButton("Finish", app: app)

        XCTAssertTrue(app.staticTexts["Step complete"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.descendants(matching: .any).matching(
                NSPredicate(format: "label CONTAINS[c] 'Svara Points'")
            ).firstMatch.exists
        )
        tapPrimaryButton("Done", app: app)
    }

    func testInProgressLessonResumesAtSavedStep() {
        let app = freshApp()
        skipOnboarding(app)
        app.tabBars.buttons["Learn"].tap()

        let hero = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'The Sound of Om'")
        ).firstMatch
        XCTAssertTrue(hero.waitForExistence(timeout: 8))
        hero.tap()
        tapPrimaryButton("Continue", app: app)
        XCTAssertTrue(app.staticTexts["Om"].waitForExistence(timeout: 5))
        app.buttons["Close lesson"].tap()

        let reopenedLesson = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'The Sound of Om'")
        ).firstMatch
        XCTAssertTrue(reopenedLesson.waitForExistence(timeout: 5))
        reopenedLesson.tap()

        XCTAssertFalse(
            app.staticTexts["Meet Om"].waitForExistence(timeout: 3),
            "Continue should resume at the saved listen step instead of returning to the intro"
        )
    }

    func testLockedLessonCannotBeOpenedFromStoryCrossLink() {
        let app = freshApp()
        skipOnboarding(app)
        app.tabBars.buttons["Stories"].tap()

        let search = app.textFields["Search stories, deities, themes"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("The Remover of Obstacles")
        let story = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH[c] 'The Remover of Obstacles'")
        ).firstMatch
        XCTAssertTrue(story.waitForExistence(timeout: 5))
        story.tap()

        let relatedLesson = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Practice this in Aaroh' AND label CONTAINS[c] 'Meet Vakratunda'")
        ).firstMatch
        XCTAssertTrue(scrollTo(relatedLesson, in: app), "The related lesson link should render")
        relatedLesson.tap()

        XCTAssertFalse(app.buttons["Close lesson"].waitForExistence(timeout: 3), "A locked Day 3 lesson should not open")
        XCTAssertTrue(
            app.staticTexts["Complete the earlier Aaroh steps first"].waitForExistence(timeout: 5),
            "A locked story cross-link should explain how to unlock the lesson"
        )
    }

    func testEveryLessonAndStepKindThenFreeAccess() {
        let scripts = [
            LessonScript(title: "The Sound of Om", steps: [
                ("Meet Om", .read),
                ("Om", .listen),
                ("Om is best described as…", .option("A sound to gather attention")),
                ("A small pause", .read)
            ]),
            LessonScript(title: "Om & the Breath", steps: [
                ("Sound and breath", .read),
                ("Breathe out on Om", .listen),
                ("Om is easiest to say on the ______.", .option("out-breath")),
                ("Notice the after-quiet", .read)
            ]),
            LessonScript(title: "Meet Vakratunda", steps: [
                ("A line for fresh starts", .read),
                ("Vakratunda Mahakaya", .listen),
                ("People often say this line before…", .option("Starting something new")),
                ("Your own beginning", .read)
            ]),
            LessonScript(title: "What Vakratunda Means", steps: [
                ("Curved trunk, mighty form", .read),
                ("'Vakratunda' refers to the…", .option("Curved trunk")),
                ("The line asks for a path free of ______.", .option("obstacles")),
                ("Not an easy road, a clear mind", .read)
            ]),
            LessonScript(title: "Saying It Smoothly", steps: [
                ("Build it up", .read),
                ("Arrange: Vakratunda", .syllables(["vak", "ra", "tun", "da"])),
                ("Arrange: Mahakaya", .syllables(["ma", "ha", "ka", "ya"])),
                ("Say the whole line", .read)
            ]),
            LessonScript(title: "Meet Saraswati", steps: [
                ("A greeting before study", .read),
                ("Saraswati Namastubhyam", .listen),
                ("Saraswati is associated with…", .option("Knowledge and the arts")),
                ("Your own learning", .read)
            ]),
            LessonScript(title: "What Saraswati Namastubhyam Means", steps: [
                ("Namastubhyam — salutations to you", .read),
                ("'Namastubhyam' means salutations to ______.", .option("you")),
                ("Arrange: Namastubhyam", .syllables(["na", "mas", "tu", "bhyam"])),
                ("A calm way to begin", .read)
            ]),
            LessonScript(title: "The Gayatri Mantra", steps: [
                ("The dawn prayer", .read),
                ("Om bhur bhuvah svah…", .listen),
                ("What we ask for", .read),
                ("The Gayatri Mantra is a prayer for…", .option("A clear mind"))
            ])
        ]

        let app = freshApp()
        skipOnboarding(app)
        app.tabBars.buttons["Learn"].tap()

        for script in scripts {
            let entry = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] %@", script.title)
            ).firstMatch
            XCTAssertTrue(scrollTo(entry, in: app, maxSwipes: 16), "\(script.title) should be reachable")
            entry.tap()

            for (index, step) in script.steps.enumerated() {
                XCTAssertTrue(
                    app.staticTexts[step.prompt].waitForExistence(timeout: 6),
                    "\(script.title) should show step: \(step.prompt)"
                )
                switch step.action {
                case .read:
                    break
                case .listen:
                    let audio = app.buttons["Chant along softly"]
                    XCTAssertTrue(audio.waitForExistence(timeout: 5))
                    XCTAssertTrue(audio.isEnabled, "\(script.title) listen audio should be available")
                    audio.tap()
                    audio.tap()
                case .option(let answer):
                    let option = app.buttons[answer]
                    XCTAssertTrue(option.waitForExistence(timeout: 5))
                    option.tap()
                    XCTAssertTrue(app.buttons["Check"].isEnabled)
                    app.buttons["Check"].tap()
                case .syllables(let values):
                    for value in values {
                        let chip = app.buttons[value].firstMatch
                        XCTAssertTrue(chip.waitForExistence(timeout: 5), "Missing accessible syllable \(value)")
                        chip.tap()
                    }
                    XCTAssertTrue(app.buttons["Check"].isEnabled)
                    app.buttons["Check"].tap()
                }

                tapPrimaryButton(index == script.steps.count - 1 ? "Finish" : "Continue", app: app)
            }

            XCTAssertTrue(app.staticTexts["Step complete"].waitForExistence(timeout: 5))
            tapPrimaryButton("Done", app: app)
        }

        let previouslyPremium = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'A Prayer for All'")
        ).firstMatch
        XCTAssertTrue(scrollTo(previouslyPremium, in: app, maxSwipes: 16))
        previouslyPremium.tap()
        XCTAssertTrue(
            app.buttons["Close lesson"].waitForExistence(timeout: 8),
            "The testing build should open formerly premium lessons without a paywall"
        )
        XCTAssertFalse(app.navigationBars["Svara Plus"].exists)
        app.buttons["Close lesson"].tap()

        app.tabBars.buttons["Today"].tap()
        let todayRecommendation = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'A Prayer for All'")
        ).firstMatch
        XCTAssertTrue(scrollTo(todayRecommendation, in: app, maxSwipes: 16), "Today should recommend the remaining lesson")
        todayRecommendation.tap()
        XCTAssertTrue(
            app.buttons["Close lesson"].waitForExistence(timeout: 8),
            "Today should open the same free lesson without a paywall"
        )
        XCTAssertFalse(app.navigationBars["Svara Plus"].exists)
    }

    // MARK: Complete cultural corpus

    func testEveryFestivalDetailRegionSaveAndActivityWorkflow() {
        do {
            let app = freshApp()
            skipOnboarding(app)
            app.tabBars.buttons["Festivals"].tap()
            XCTAssertTrue(app.staticTexts["Festival Moments"].waitForExistence(timeout: 8))

            for region in ["All", "India", "Diaspora", "North India", "South India", "West India", "East India", "Global Hindu"] {
                let chip = app.buttons[region]
                if scrollTo(chip, in: app, maxSwipes: 2) {
                    chip.tap()
                    XCTAssertTrue(app.staticTexts["The year ahead"].exists || scrollTo(app.staticTexts["The year ahead"], in: app))
                }
            }
            app.terminate()
        }

        for name in festivalNames {
            // Each corpus item receives a clean process and navigation stack.
            // This prevents a previous full-screen cover or long ScrollView
            // history from contaminating the next independent workflow.
            let app = freshApp()
            skipOnboarding(app)
            app.tabBars.buttons["Festivals"].tap()
            XCTAssertTrue(app.staticTexts["Festival Moments"].waitForExistence(timeout: 8))

            let row = app.buttons.matching(
                NSPredicate(format: "label BEGINSWITH[c] %@", name)
            ).firstMatch
            XCTAssertTrue(scrollTo(row, in: app, maxSwipes: 16), "\(name) should be reachable")
            row.tap()
            XCTAssertTrue(app.navigationBars[name].waitForExistence(timeout: 5), "\(name) detail should open")
            XCTAssertTrue(app.staticTexts["Why it matters"].exists || scrollTo(app.staticTexts["Why it matters"], in: app, maxSwipes: 3))

            let begin = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] 'Begin the activity'")
            ).firstMatch
            XCTAssertTrue(scrollTo(begin, in: app, maxSwipes: 8), "\(name) should expose its activity")
            XCTAssertTrue(begin.waitForExistence(timeout: 5), "\(name) activity button should exist")
            XCTAssertTrue(begin.isHittable, "\(name) activity button should be hittable")
            begin.tap()
            if !app.buttons["Close activity"].waitForExistence(timeout: 8) {
                // A full-screen cover tap can be dropped while the detail
                // ScrollView finishes decelerating. Retrying the still-visible
                // source button distinguishes that harness race from an app
                // transition failure.
                XCTAssertTrue(scrollTo(begin, in: app, maxSwipes: 2), "\(name) activity button should remain retryable")
                XCTAssertTrue(waitForHittable(begin, timeout: 5), "\(name) activity button should become hittable again")
                begin.tap()
            }
            XCTAssertTrue(app.buttons["Close activity"].waitForExistence(timeout: 5), "\(name) activity cover should open")
            XCTAssertTrue(app.buttons["Begin"].waitForExistence(timeout: 5))
            app.buttons["Begin"].tap()
            let stepCount = festivalActivityStepCounts[name] ?? 0
            for _ in 1..<stepCount {
                XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 5))
                app.buttons["Continue"].tap()
            }
            XCTAssertTrue(app.buttons["Next"].waitForExistence(timeout: 5))
            app.buttons["Next"].tap()
            XCTAssertTrue(
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Complete'")).firstMatch.waitForExistence(timeout: 5),
                "\(name) activity should reach completion"
            )
            tapPrimaryButton("Complete", app: app)
            XCTAssertTrue(app.staticTexts["You marked the moment"].waitForExistence(timeout: 5))
            tapPrimaryButton("Done", app: app)

            let save = app.buttons["Save for yourself"]
            XCTAssertTrue(scrollTo(save, in: app, maxSwipes: 12))
            XCTAssertTrue(save.isHittable, "\(name) save button should be hittable")
            save.tap()
            XCTAssertTrue(app.buttons["Saved for yourself"].exists, "\(name) should persist its saved state")

            closeNavigationDetail(app)
            app.terminate()
        }
    }

    func testStorySearchDetailSymbolAndReflectionWorkflowsPartOne() {
        runStoryWorkflows(Array(storyTitles.prefix(4)), verifiesEmptyState: false)
    }

    func testStorySearchDetailSymbolWorkflowsPartTwo() {
        runStoryWorkflows(Array(storyTitles.suffix(3)), verifiesEmptyState: true)
    }

    private func runStoryWorkflows(_ titles: [String], verifiesEmptyState: Bool) {
        let app = freshApp()
        skipOnboarding(app)
        app.tabBars.buttons["Stories"].tap()

        for title in titles {
            let search = app.textFields["Search stories, deities, themes"]
            XCTAssertTrue(search.waitForExistence(timeout: 5))
            search.tap()
            search.typeText(title)

            let result = app.buttons.matching(
                NSPredicate(format: "label BEGINSWITH[c] %@", title)
            ).firstMatch
            XCTAssertTrue(result.waitForExistence(timeout: 5), "\(title) should be searchable")
            result.tap()
            XCTAssertTrue(
                app.descendants(matching: .any).matching(
                    NSPredicate(format: "label BEGINSWITH[c] %@", title)
                ).firstMatch.waitForExistence(timeout: 5),
                "\(title) detail should render"
            )

            for symbolName in storySymbols[title] ?? [] {
                let symbol = app.buttons.matching(
                    NSPredicate(format: "label BEGINSWITH[c] %@", "\(symbolName).")
                ).firstMatch
                XCTAssertTrue(scrollTo(symbol, in: app, maxSwipes: 8))
                symbol.tap()
                XCTAssertTrue(app.navigationBars["Symbol"].waitForExistence(timeout: 5))
                app.buttons["Done"].tap()
            }

            if title == "The Remover of Obstacles" {
                let reflection = app.buttons.matching(
                    NSPredicate(format: "label CONTAINS[c] 'reflection'")
                ).firstMatch
                XCTAssertTrue(scrollTo(reflection, in: app, maxSwipes: 8))
                reflection.tap()
                let editor = app.textViews["Your reflection"]
                XCTAssertTrue(editor.waitForExistence(timeout: 5))
                XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Save reflection'")).firstMatch.isEnabled)
                editor.tap()
                editor.typeText("A private UI-test reflection.")
                tapPrimaryButton("Save reflection", app: app)
                XCTAssertTrue(app.staticTexts["A private UI-test reflection."].waitForExistence(timeout: 5))
            }

            closeNavigationDetail(app)
            let clear = app.buttons["Clear search"]
            XCTAssertTrue(clear.waitForExistence(timeout: 5))
            clear.tap()
        }

        if verifiesEmptyState {
            let search = app.textFields["Search stories, deities, themes"]
            search.tap()
            search.typeText("definitely no matching story")
            XCTAssertEqual(
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'about'")).count,
                0,
                "A no-result search should not display unrelated story cards"
            )
            app.buttons["Clear search"].tap()
        }
    }

    // MARK: Profile, settings, reminders, and free-build UI

    func testProfileNameValidationPersistenceAndReminderDenial() {
        let app = freshApp()
        skipOnboarding(app)
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Achievements"].waitForExistence(timeout: 8))

        let settings = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(settings.exists)
        settings.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        app.buttons["Edit display name"].tap()
        let nameField = app.textFields["Your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 32))
        nameField.typeText("   ")
        tapPrimaryButton("Save Name", app: app)
        XCTAssertTrue(app.staticTexts["Enter a name before saving."].waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText("Svara Tester")
        tapPrimaryButton("Save Name", app: app)

        let reminder = app.switches["Practice reminders"]
        XCTAssertTrue(reminder.waitForExistence(timeout: 5))
        reminder.tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let deny = springboard.buttons["Don’t Allow"]
        if deny.waitForExistence(timeout: 5) {
            deny.tap()
            XCTAssertEqual(reminder.value as? String, "0", "Denied permission should turn reminders back off")
        }

        app.terminate()
        app.launchArguments = []
        app.launch()
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Svara Tester"].waitForExistence(timeout: 5), "Display name should survive relaunch")
    }

    func testFreeTestingBuildHasNoPlusSurface() {
        let app = freshApp()
        skipOnboarding(app)
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Achievements"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Svara Plus"].exists)
        XCTAssertFalse(
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Svara Plus'")).firstMatch.exists
        )

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Membership"].exists)
        XCTAssertFalse(app.staticTexts["Svara Plus"].exists)
    }

    func testDarkMaximumTextPrimaryActionsRemainReachable() {
        let app = freshApp(arguments: [
            "-AppleInterfaceStyle", "Dark",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge"
        ])
        skipOnboarding(app)

        for tab in ["Today", "Learn", "Festivals", "Stories", "Profile"] {
            let button = app.tabBars.buttons[tab]
            XCTAssertTrue(button.waitForExistence(timeout: 5), "\(tab) tab should remain reachable at maximum text")
            XCTAssertTrue(button.isHittable)
            button.tap()
        }

        app.tabBars.buttons["Today"].tap()
        let practice = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] ' practice:'")
        ).firstMatch
        XCTAssertTrue(scrollTo(practice, in: app), "A primary practice action should remain reachable at maximum text")
        practice.tap()
        XCTAssertTrue(
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Begin'")).firstMatch.waitForExistence(timeout: 5)
        )
    }
}
