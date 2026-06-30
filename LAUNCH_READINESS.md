# Svara — Launch Readiness (v1)

> Svara is a daily spiritual-wellness iOS app rooted in Hindu culture — "Headspace meets Duolingo" with a Hindu soul. It is for Indians aged 18–35, in India and across the diaspora, who want a gentle daily habit: a three-minute practice (morning mantra / midday breath / evening prayer / gratitude), bite-sized lessons that teach a sloka's meaning, the stories behind festivals, and deity tales organised by human themes. The core loop is: open **Today → run a timed guided practice → earn Svara Points → keep a gentle streak**, with **Learn**, **Festivals**, **Stories** and **Profile** as supporting surfaces.
>
> **Implementation maturity: working SwiftUI app + tests (Building).** The repo is a navigable iOS 17 SwiftUI/MVVM app (56 app Swift files + 5 test, ~5.0k non-blank LOC) that runs entirely offline on bundled JSON seed content. The Today and Learn loops are wired end-to-end (practice player, lesson player, points, streaks, achievements, persistence). StoreKit 2 is real but unconfigured in the run scheme; auth is a local mock; Firebase is a deliberate, un-wired seam. It is **not** yet TestFlight-ready: the test target is hosted (depends on `Bundle.main`) and has never been run in CI, the in-code seed fallback diverges from the shipped JSON, and several App Store / privacy / content-review items are open. See §7 and §8.

---

## 1. PRD / Launch Scope

### Problem & insight
Many young Indians — especially in the diaspora — grew up *around* mantras, festivals and stories but were never told what they mean. Existing options are either heavy religious apps, virtual-temple / "online puja" products (Primandir-style), or generic Western wellness apps that strip out the cultural soul. There is a gap for a **calm, modern, non-doctrinal daily habit** that explains the *why* and respects the tradition without simulating ritual or selling religion.

### Target user
- **Primary:** Indians aged 18–35 in India and the diaspora who want a light daily spiritual practice and to reconnect with cultural meaning, with no assumed fluency in Sanskrit, Hindi, or ritual.
- **Secondary:** The "curious, lapsed, or devout" (per `ProductGuardrails.md` §4) — anyone wanting bite-sized, respectful cultural learning, and parents who want a dignified way to share stories/festivals.

### Value proposition
*Three respectful minutes a day — a guided practice, a sloka you finally understand, and the story behind the festival you grew up with — without it ever becoming a temple simulator or a religion lecture.*

### Positioning / category & pitch
- **Category:** Health & Fitness (primary), Education (secondary) — per `AppStore/metadata.md`.
- **One-sentence pitch:** "Headspace meets Duolingo, with a Hindu spiritual soul" — a gentle, gamified daily companion for spiritual wellness rooted in Hindu culture.

### Platform & tech baseline (verified in repo)
- **iOS 17.0+**, iPhone + iPad (`TARGETED_DEVICE_FAMILY = 1,2`; iPhone portrait-only, iPad all orientations).
- **SwiftUI** UI, **MVVM** with the iOS 17 `@Observable` macro; single composition root `AppEnvironment` injected via `.environment(...)`.
- **StoreKit 2** for the freemium "Svara Plus" upgrade (`StoreService.swift`, `Svara.storekit`).
- **UserNotifications** for local daily reminders (`LocalNotificationService`).
- **Persistence:** Codable-over-`UserDefaults` (`UserDefaultsStore`). No SwiftData/CoreData.
- **No third-party SDKs.** Firebase Auth/Firestore are *seams only* (`FirebaseAuthService` throws `.notConfigured`; `FirestoreContentRepository` is a commented block). No `Package.resolved`, no SPM dependencies.
- Xcode 16 project using `PBXFileSystemSynchronizedRootGroup` (files added under `Svara/` are auto-included); `GENERATE_INFOPLIST_FILE = YES`; bundle id `com.svara.app`; `MARKETING_VERSION 1.0`.

### Business model (only what the repo supports)
- **Freemium.** Free tier is a fully useful daily practice + most content. **Svara Plus** unlocks premium content (currently: lesson `lesson.shanti.peace`, story `story.samudra.manthan`) and "smart reminders."
- StoreKit products defined: `com.svara.plus.monthly`, `com.svara.plus.yearly`, `com.svara.plus.lifetime` (a subscription group + a non-consumable), each with a 1-week free trial in the `.storekit` config.
- Guardrail (binding): premium "gates value, not guilt" — the free tier must stand on its own; basic daily practice and cultural access are never paywalled (`ProductGuardrails.md` §6).

### North-star / success signals (local-only / beta-observable; privacy-respecting)
- **North star:** Day-2 / Day-7 retained daily practice (a gentle, sustained streak).
- Observable locally without a backend: first-practice completion, practices/day, streak length distribution, lesson completion, reminder opt-in rate, paywall view→purchase. Note: there is **no analytics SDK** in the repo today, so these are not yet measured (see §7 NB-7).

---

## 2. MVP Feature List (with acceptance criteria)

Status legend: **Built** = implemented end-to-end and exercised in the UI; **Partial** = present but incomplete/unwired; **Not built** = seam/placeholder only.

### F1. Today — daily practice home & guided practice player — **Built**
`Features/Today/TodayView.swift`, `TodayViewModel.swift`, `Features/Today/PracticePlayerView.swift`.
- Given the app is open on Today, When it loads, Then it shows a time-aware greeting, the user's streak banner + total points, an ordered list of the 4 daily practices, and a deterministic "mantra of the day."
- Given the current time, When practices render, Then the practice whose `timeOfDay` matches the current bucket sorts first (`orderedPractices`).
- Given a practice card is tapped, When the player opens, Then it runs intro → timed active phase (breathing ring + rotating guidance lines) → completion, never shorter than 60s (`max(60, durationMinutes*60)`).
- Given a practice completes (timer hits 0 or "Finish now"), Then `completePractice` records a `PracticeSession`, awards `practice.points`, updates the streak, persists the profile, and the card shows a completed state for the rest of the calendar day (`hasCompletedPractice`).
- Given the mantra-of-day card is tapped, Then `MantraDetailView` opens with Sanskrit / transliteration / translation / meaning.

### F2. Learn — Duolingo-style lessons + player — **Built**
`Features/Learn/LearnView.swift`, `LearnViewModel.swift`, `LessonPlayerView.swift`.
- Given Learn loads, Then lessons render sorted by `level` ascending with a progress ring ("N of M lessons") and per-lesson step count + XP.
- Given a lesson is opened, When stepping through, Then `intro`/`listen`/`meaning` cards display and `multipleChoice`/`fillBlank` steps let the user pick an option, tap **Check**, and see the correct answer highlighted.
- Given a **wrong** answer, Then the correct option is shown kindly and the user can continue — **no life is lost and progress is never blocked** (guardrail §8.2). *(Acceptance for the "no lives" rule passes; the *gentle hint system* the guardrail also names is **not** implemented — see F2 caveat in §6 / KL-2.)*
- Given the last step is finished, Then `completeLesson` awards `lesson.xp` (idempotent — re-completing grants nothing), advances the streak, and the path marks the lesson complete.
- Given a premium lesson and a non-premium user, When tapped, Then the paywall opens instead of the lesson.

### F3. Festivals — calendar, countdown, story & "mark observed" — **Built**
`Features/Festivals/FestivalsView.swift`, `FestivalsViewModel.swift`, `FestivalDetailView.swift`.
- Given Festivals loads, Then festivals sort upcoming-first (today-or-later before past), with a "Up next" countdown card ("Today"/"Tomorrow"/"in N days").
- Given a festival is opened, Then it shows tagline, "Why it matters", the story, and "Mark the moment" activities.
- Given "Mark as observed" is tapped, Then `observeFestival` adds the id, awards 15 points (idempotent), and the row/detail shows an observed state.
- Guardrail check: **no festival is tied to any loot / streak-freeze gift** (§8.3) — the only reward is flat points + an "In the Spirit" achievement; verified in code.

### F4. Stories & Symbols — themed library + reader — **Built**
`Features/Stories/StoriesView.swift`, `StoriesViewModel.swift`, `StoryDetailView.swift`.
- Given Stories loads, Then story cards render in a 2-column grid with a horizontal theme filter ("All" + themes that actually appear).
- Given a theme chip is tapped, Then the grid filters to that theme; tapping again clears it.
- Given a story is opened, Then it shows the narrative, "What it means" (symbol meaning), and a "Carry this with you" takeaway.
- Given a premium story and a non-premium user, When the card is tapped, Then the paywall opens (no navigation to the locked story).

### F5. Profile, streaks, points & achievements — **Built**
`Features/Profile/ProfileView.swift`, `ProfileViewModel.swift`; `Core/Services/ProgressService.swift`; `App/MainTabView.swift` (toast).
- Given Profile loads, Then it shows avatar, "practising since" date, current streak / total points / best streak tiles, and an achievements grid (unlocked vs in-progress with a progress ring).
- Given a progress event crosses an achievement threshold, Then the achievement unlocks, awards its `bonusPoints`, and a celebratory toast appears for ~2.6s (`MainTabView` overlay).
- Given streak math: a 2nd practice same day leaves the streak unchanged; a practice the next calendar day increments; any longer gap resets to 1 (`StreakCalculator`). Language is encouraging, never punitive ("Keep the flame alive").

### F6. Onboarding — **Built**
`Features/Onboarding/OnboardingView.swift`.
- Given first launch, Then a 3-page paged intro shows; "Get Started"/"Skip" sets `hasCompletedOnboarding` (persisted) and routes onward. Subsequent launches skip it.

### F7. Auth (local mock + guest) — **Partial**
`Features/Auth/AuthView.swift`, `Core/Services/AuthService.swift` (`MockAuthService`), `FirebaseAuthService.swift` (seam).
- Given onboarding is complete and the user is unauthenticated, Then `AuthView` is shown (sign in / register / **Continue as Guest**).
- Given valid-looking input (email contains "@", password ≥ 4 chars), Then a local `UserProfile` is created/restored in `UserDefaults`; **no real authentication, no password storage, no server**. Guest creates an anonymous "Friend" profile.
- **Partial because:** the gate forces an auth screen before the app even though everything is local; the App Store description promises "No account required to start" which is only true via the easily-missed "Continue as Guest" button (see §7 LB-2). Firebase path throws `.notConfigured`.

### F8. Settings — reminders, account, sign-out — **Built (reminders Partial)**
`Features/Profile/SettingsView.swift`, `Core/Services/NotificationService.swift`.
- Given the reminders toggle is enabled, Then iOS notification authorization is requested; on grant, a morning + evening `UNCalendarNotificationTrigger` is scheduled at the chosen hours; on denial, the toggle reverts.
- Given account section, Then name/email/membership display; sign-out confirms, cancels reminders, and resets to guest.
- **Reminders Partial:** times are hour-granularity only; copy is fixed; the "smart/personalised reminders" promised on the paywall do **not** exist (KL-4). About links point to `svara.app/privacy` & `/terms` which are not live (see §7 LB-4).

### F9. Svara Plus paywall + StoreKit 2 entitlement — **Partial**
`Features/Profile/PaywallView.swift`, `Core/Services/StoreService.swift`, `Resources/Svara.storekit`.
- Given the paywall opens, Then it loads products via StoreKit 2, lists them sorted by price, supports purchase, restore, and reflects entitlement from `Transaction.currentEntitlements`.
- Given a successful purchase, Then `isPlus` becomes true, the local `isPremium` flag is set, and premium content unlocks.
- **Partial because:** the `.storekit` configuration is **not referenced in the run scheme**, so products won't load in a fresh simulator run without manual setup (§7 LB-5); pricing in `.storekit` ($3.99/$29.99/$79) **contradicts** `AppStore/metadata.md` ($0.99/$7.99/$19.99) (§7 LB-6); there is no server-side receipt validation (acceptable for v1, KL-7).

### F10. Content pipeline — JSON seed + validation + provenance — **Built**
`Core/Content/SeedContentProvider.swift`, `ContentValidation.swift`, `ShlokaSelector.swift`, `Resources/SeedData/*.json`, `Resources/SeedContent.swift`.
- Given the app loads content, Then it decodes bundled JSON (mantras, lessons, festivals, stories, shlokas, achievements) with an in-code `SeedContent` fallback; daily practices are in-code by design.
- Given a `date`, Then `ShlokaSelector` picks a deterministic shloka-of-day (fixed-day `dateKey` pin wins; else day-of-year rotation).
- Given content, Then `ContentValidation` enforces required fields, unique IDs, lesson ordering, parseable festival dates, present `isPremium` flags, and **forbidden Primandir-term scanning** on user-facing labels.
- Every content model carries optional provenance (`sourceName`, `sourceNote`, `traditionNote`, `reviewStatus`); shipped JSON marks items `humanReviewed`/`sourced`.
- **Caveat:** the JSON (10 mantras, 8 festivals, 10 stories, 10 shlokas) and the in-code fallback (6 mantras, 5 festivals, 6 stories, 10 shlokas) **diverge in ids and counts** — see §7 LB-1.

### F11. Design system & symbol system (no bell) — **Built**
`Core/DesignSystem/*`, `SvaraSymbol.swift`.
- Theme, typography, cards, buttons, progress ring, gradients are implemented and used across all screens.
- The canonical symbol set is **Lotus · Diya · Om · Dawn · Mandala · Sunrise** with **no bell** (guardrail §8.1); a unit test enforces no bell glyph. **Caveat:** all symbols are interim SF-Symbol placeholders pending bespoke art (KL-1).

### F12. Shloka deep-linking / routing — **Not built (model only)**
`Core/Models/ShlokaOfDay.swift` (`AppDeepLink`).
- `AppDeepLink.parse` maps strings like `mantra:mantra.om` to a `Destination`, and shlokas carry a `deepLinkTarget`. **However, no view consumes `Destination` to route** — the shloka-of-day is not surfaced/tappable in any screen, and deep-link routing is unwired. Parsing is unit-tested; navigation is not implemented.

### F13. Daily check-in (mood/intention) — **Not built (model only)**
`Core/Models/DailyCheckIn.swift`.
- Model + privacy contract exist (reflection text is local-only, never synced). No UI surfaces it. Listed as a v1 non-goal in §3.

---

## 3. Out of Scope (v1 non-goals)

Forbidden by `ProductGuardrails.md` (binding) — must **not** appear in v1 or ever:
- **Virtual temple / ritual simulator:** no virtual puja, darshan feeds/booking, temple live-streams, on-screen offerings/prasad, diya/bell/aarti tap-to-perform interactions. (Conch art may appear but must never be interactive.)
- **Religious marketplace / e-commerce:** no booking priests, ordering prasad, buying ritual items, or temple donations/transactions.
- **Public social network:** no community feed, public profiles, followers, comments, or public leaderboards.
- **Doctrinal authority:** no instruction on "correct belief," no absolutist religious claims, no sin/punishment framing. *(Recommended in the product thread: codify a "no doctrinal-authority / no user-to-user religious interaction" guardrail with a test — see §8.)*
- **Punitive gamification:** no "lives"/hearts in Learn, no festival-tied loot or streak-freeze gifts, no public ranking of devotion, no FOMO/dark patterns.
- **Bell symbol** in the brand/symbol system.

Deferred for capacity/scope reasons (not forbidden, just not v1):
- **Firebase Auth + Firestore / cloud sync** — seams only; local seed content carries the beta. (Thread recommendation: defer.)
- **Real audio playback** for mantras (`Mantra.audioFileName` exists but no audio assets ship; "listen" steps say "chant along" with no playback).
- **Daily mood check-in UI** (F13), **shloka-of-day surfacing + deep-link routing** (F12), **widgets / Live Activities** (display text is widget-ready but no widget extension exists).
- **Per-lesson resume / mastery UI** (`LessonProgress` model exists but isn't persisted/used; only a flat completed-lesson list is).
- **Grace days / streak freeze** kindness mechanic (named as "future" in guardrails; not built).
- **Analytics / crash reporting** (no SDK).
- **Localization** (English-only; `LOCALIZATION_PREFERS_STRING_CATALOGS = YES` is set but no catalogs exist).

Scope recommendation from the product thread (Codex↔Claude): **cut the beta surface to Today + one content tab (Learn)** to prove the core loop before shipping all five tabs. This doc documents all five as built, but §8 treats "beta = Today + Learn" as the recommended gating scope.

---

## 4. User Flows

Screen names below match the SwiftUI views in `Svara/Features/`.

### 4.1 First run / onboarding
1. Launch → `SvaraApp` builds `AppEnvironment.live()` and runs `bootstrap()` (restores any saved profile, warms StoreKit).
2. `RootView` sees `hasCompletedOnboarding == false` → shows **OnboardingView** (3 pages).
3. User taps **Get Started** (or **Skip**) → `completeOnboarding()` persists the flag.
4. `RootView` now sees `isAuthenticated == false` → shows **AuthView**.
5. User taps **Continue as Guest** (or signs in / registers) → a local `UserProfile` is created → `isAuthenticated == true`.
6. `RootView` shows **MainTabView** (Today selected).

### 4.2 Core loop (daily practice)
1. **TodayView** loads practices + mantra-of-day; current-time practice is first.
2. Tap a **PracticeCard** → **PracticePlayerView** (full-screen cover) → **Begin**.
3. Breathing ring counts down; guidance lines rotate; user can **Finish now**.
4. On completion → points awarded, streak updated, profile persisted; "Well done +N points" screen → **Done**.
5. Back on Today, the card shows completed for the day; streak banner reflects the new streak. If a threshold is crossed, an **AchievementToast** appears.

### 4.3 Learn loop
1. **LearnView** → tap a lesson → **LessonPlayerView** (full-screen cover).
2. Step through cards; on quiz steps pick an option → **Check** → see the correct answer → **Continue**.
3. **Finish** on the last step → XP awarded, streak advanced, "Lesson complete! +XP, X/Y correct" → **Done**.
4. Premium lesson + free user → **PaywallView** sheet instead.

### 4.4 Festivals / Stories (content reading)
1. **FestivalsView** → "Up next" countdown or list → **FestivalDetailView** → optionally **Mark as observed** (+15 pts).
2. **StoriesView** → filter by theme → **StoryDetailView** (premium gating routes free users to the paywall).

### 4.5 Settings / privacy / reminders
1. **ProfileView** → gear → **SettingsView**.
2. Toggle **Practice reminders** → iOS permission prompt → pick Morning/Evening hours → `scheduleDailyReminders`. Denial reverts the toggle.
3. Account section shows name/email/membership; **Sign Out** confirms → cancels reminders → resets to guest → back to **AuthView**.

### 4.6 Upgrade / purchase
1. **ProfileView** "Svara Plus" card or a locked-content tap → **PaywallView**.
2. Products load via StoreKit 2 → select plan → **Start free trial** → purchase → entitlement syncs → premium unlocks, sheet dismisses. **Restore Purchases** re-syncs entitlement.

### 4.7 Share / export
- **None in v1.** No share sheets, no export, no deep-link entry from outside the app. (Shloka deep links are internal-only and unwired — F12.)

---

## 5. Acceptance Criteria Summary

| Feature | Status | Launch gate (pass = ship) |
|---|---|---|
| F1 Today + practice player | Built | Player runs intro→timed→complete; points/streak persist; card shows completed for the day. |
| F2 Learn + lesson player | Built | Lessons ordered by level; quiz check shows correct answer with no life lost; XP awarded once. **Hint system absent (KL-2).** |
| F3 Festivals | Built | Upcoming-first sort + countdown; mark-observed idempotent (+15); no festival loot. |
| F4 Stories | Built | Theme filter works; premium stories gate to paywall. |
| F5 Profile/streaks/points/achievements | Built | Stats render; achievement unlock awards bonus + toast; streak math correct (same-day/next-day/gap). |
| F6 Onboarding | Built | 3 pages; completion persists; skipped on later launches. |
| F7 Auth (mock + guest) | Partial | Guest + local sign-in work. **"No account to start" friction (LB-2).** |
| F8 Settings/reminders | Built (reminders Partial) | Toggle schedules/cancels reminders; denial reverts. **Privacy/Terms links dead (LB-4).** |
| F9 Paywall + StoreKit | Partial | Purchase/restore/entitlement logic correct. **Scheme not wired (LB-5); pricing mismatch (LB-6).** |
| F10 Content pipeline + validation | Built | JSON decodes; validation/forbidden-term tests green. **JSON↔fallback divergence (LB-1).** |
| F11 Design + no-bell symbols | Built | No-bell test passes. **Placeholder art (KL-1).** |
| F12 Shloka deep-linking | Not built | Out of v1 scope; routing unwired. |
| F13 Daily check-in | Not built | Out of v1 scope (model only). |

---

## 6. Known Limitations

- **KL-1 — Placeholder iconography.** All `SvaraSymbol` glyphs and most feature icons are interim SF Symbols; bespoke brand art (lotus, om, mandala, sunrise) is deferred to Phase 2. The app looks generic-Apple in places.
- **KL-2 — Learn "gentle hint system" is not implemented.** Guardrail §8.2 and `LessonProgress.hintsUsed` call for a hint affordance on quiz steps; `LessonPlayerView` has no hint button. The "no lives / continue after wrong" half of the rule *is* satisfied.
- **KL-3 — No audio.** `Mantra.audioFileName` and "listen / chant along" steps imply audio, but no audio assets ship and there is no `AVAudioPlayer` wiring. "Listen" is text-only today.
- **KL-4 — Reminders are basic.** Hour-granularity, fixed copy, fixed morning+evening only. The paywall's "smart/personalised reminders" benefit does not exist yet.
- **KL-5 — Per-lesson progress not persisted.** Only a flat `completedLessonIDs` list is stored; `LessonProgress` (step-level, best score, resume) is modelled but unused. Quiz scores are shown at completion but not saved.
- **KL-6 — Local-only data, no sync/backup.** Profile, sessions and entitlement flag live in `UserDefaults`. Reinstalling the app loses all progress; there is no cloud backup (by design for v1, but worth stating to users).
- **KL-7 — No server receipt validation.** Entitlement derives from on-device `Transaction.currentEntitlements` only. Acceptable for v1 but means no cross-device entitlement and weaker fraud posture.
- **KL-8 — Festival dates are seed/illustrative.** Dates are hand-authored for 2026–2027 and will go stale; `traditionNote` rightly flags regional/calendar variation, but there is no live calendar source.
- **KL-9 — English only.** No localization despite an Indian/diaspora audience.
- **KL-10 — Content breadth is thin.** ~10 lessons/stories/mantras each. Shallow content in a sensitive category reads as disrespectful; depth matters before scale.
- **KL-11 — Shloka-of-day is computed but never shown.** The deterministic selector and widget-ready text exist but no screen displays a shloka-of-day, and the deep links it carries are unwired (F12).

---

## 7. Bug & Risk Triage

### Launch-blocking (must fix before TestFlight / App Store)

- **LB-1 — In-code seed fallback diverges from shipped JSON, and the test suite depends on the JSON.**
  `Resources/SeedContent.swift` (in-code fallback) and `Resources/SeedData/*.json` (authoring source) have different ids and counts: e.g. JSON has `mantra.om`, `mantra.vakratunda`, `mantra.saraswatiNamastubhyam`, `mantra.shiva`, `festival.holi`, `festival.navaratri`, `story.ganesha.beginnings`, `story.durga.innerstrength`; the in-code fallback has none of these. `SeedDecodingTests`/`ContentValidationTests` assert the JSON ids and use `Bundle.main`, so **if JSON ever fails to bundle/decode, the app silently serves a *different, smaller* catalogue** than QA tested, and tests written against JSON won't catch it. **Why blocking:** correctness + content integrity in a sensitive app. **Fix:** make the in-code fallback an exact mirror of the JSON (or generate one from the other) and add a test asserting parity.
- **LB-2 — Forced auth gate contradicts "no account required to start."**
  `RootView` shows `AuthView` after onboarding before any content; the App Store description and guardrails imply a frictionless, dignified start. The only no-account path is a secondary "Continue as Guest" button. **Why blocking:** first-run friction + a store-description mismatch (App Review rejects features that don't match the description), and it gates "basic access," which the guardrail forbids. **Fix:** default to guest (skip the gate) and offer sign-in as optional later, or make "Continue as Guest" the primary action.
- **LB-3 — No human cultural/theological sign-off gate on shipped content.**
  Content carries `reviewStatus` (`humanReviewed`/`sourced`) and `ContentValidation` is automated, but nothing *enforces* that every shipped item passed human review, and there's no recorded reviewer/date. The product thread explicitly requires **human cultural review as a blocking field before TestFlight**. **Why blocking:** a single mistranslation or doctrinal overstep is a serious harm in this category. **Fix:** add a validation rule that every user-facing content item must be `humanReviewed`/`sourced` (fail CI otherwise), and capture an off-repo sign-off record.
- **LB-4 — Dead Privacy Policy & Terms URLs; inconsistent support URL.**
  `SettingsView` links to `https://svara.app/privacy` and `/terms` (not live); `AppStore/metadata.md` Privacy Policy URL is "(create before submission)" and Support URL points at an unrelated repo (`github.com/pri8771/claude_app_dt`). **Why blocking:** App Store requires a working privacy policy URL; dead in-app legal links fail review and erode trust. **Fix:** publish a privacy policy + terms and point all three at the real URLs.
- **LB-5 — StoreKit configuration is not wired into the run scheme.**
  `Svara.storekit` exists but `Svara.xcscheme`'s `LaunchAction` has no StoreKit configuration reference, so a fresh simulator run loads **zero** products and the paywall shows the empty-state copy. **Why blocking:** the purchase flow can't be demonstrated/tested out of the box, and a beta tester sees a broken paywall. **Fix:** set the StoreKit configuration in the scheme (and configure products in App Store Connect for device builds).
- **LB-6 — Pricing mismatch between StoreKit config and store metadata.**
  `Svara.storekit`: Monthly $3.99 / Yearly $29.99 / Lifetime $79. `AppStore/metadata.md`: Monthly $0.99 / Yearly $7.99 / Lifetime $19.99. **Why blocking:** ambiguous pricing of record; the metadata/marketing and the actual products must agree before submission. **Fix:** pick the real prices and make `.storekit`, App Store Connect, and metadata identical.
- **LB-7 — Tests have never run in CI and are bundle-coupled.**
  No `.github/workflows`. The unit tests are a *hosted* target relying on `Bundle.main` to read seed JSON; they pass guardrails (forbidden terms, ordering, determinism) but are not gating anything. **Why blocking-ish for a guardrail-driven product:** the guardrails are only "executable" if they actually run. **Fix:** add a CI workflow running `xcodebuild test` on every PR; treat forbidden-term/validation failures as red.
- **LB-8 — Privacy manifest declares zero collected data while the app stores PII locally.**
  `PrivacyInfo.xcprivacy` has empty `NSPrivacyCollectedDataTypes`/`NSPrivacyAccessedAPITypes`. The app stores name/email locally and uses `UserDefaults` (a required-reason API). Even if nothing leaves the device, the App Store privacy "nutrition label" and required-reason API declarations must be completed accurately. **Why blocking:** inaccurate privacy declarations are a common rejection/compliance issue. **Fix:** complete the App Privacy answers (data is on-device, not linked/tracked) and add the `UserDefaults` required-reason API entry.

### Non-blocking (ship-with, fix later)

- **NB-1 — Shloka-of-day is computed but never surfaced; deep links unwired (F12).** No user impact today; finish when the shloka card/widget ships.
- **NB-2 — `LessonProgress` modelled but unused (KL-5).** Resume/mastery is a polish feature; the flat completed list works for v1.
- **NB-3 — "Smart reminders" oversells current behaviour (KL-4).** Soften the paywall copy or implement; not a correctness bug.
- **NB-4 — No audio despite "listen/chant along" framing (KL-3).** Manage expectations in copy until audio ships.
- **NB-5 — Placeholder icons (KL-1).** Cosmetic; replace with brand art in Phase 2.
- **NB-6 — Guardrail "no doctrinal-authority / no social" is documented but not test-enforced.** Add a forbidden-pattern/test per the thread recommendation; low risk today because no such features exist.
- **NB-7 — No analytics, so north-star signals aren't measured.** Acceptable for a privacy-first beta; add privacy-respecting, on-device or opt-in metrics later.
- **NB-8 — Festival dates will go stale (KL-8).** Refresh per release until a live source exists.
- **NB-9 — `StoreService.updatesTask` uses `nonisolated(unsafe)`.** Works, but review for strict-concurrency cleanliness when raising the Swift language mode.
- **NB-10 — English-only (KL-9) and thin content breadth (KL-10).** Grow deliberately; depth before scale.

---

## 8. Production-Readiness Assessment

### Current estimated readiness: **~60%**

Justification: the app is a genuinely working, navigable SwiftUI app with the two most important loops (Today practice, Learn lessons) wired end-to-end including points, streaks, achievements, persistence, and a real StoreKit 2 layer — that's well past "Building." But it is not TestFlight-ready: content integrity (LB-1, LB-3), first-run friction (LB-2), store/legal/privacy plumbing (LB-4/5/6/8), and the absence of CI (LB-7) are all open, and several promised features (audio, smart reminders, shloka surfacing) are not built. ~60% reflects "core loop runs, but launch hygiene and content governance are incomplete."

### Ordered checklist to reach 80–90% production-ready
1. **Reconcile content sources (LB-1).** Make the in-code fallback an exact mirror of the JSON; add a parity test (ids + counts). Audit shloka `deepLinkTarget`s resolve to real ids in *both* sources.
2. **Add a content-review gate (LB-3).** Require `reviewStatus ∈ {humanReviewed, sourced}` for every shipped item in `ContentValidation` (fail CI); record reviewer + date off-repo. Capture human cultural/theological sign-off before TestFlight.
3. **Fix the first-run gate (LB-2).** Default to guest; make sign-in optional; align with the "no account to start" promise.
4. **Wire StoreKit + fix pricing (LB-5, LB-6).** Reference `Svara.storekit` in the scheme; make `.storekit`, metadata, and App Store Connect prices identical; smoke-test purchase + restore.
5. **Legal & privacy (LB-4, LB-8).** Publish privacy policy + terms; point in-app and metadata links at them; complete App Privacy answers and the `UserDefaults` required-reason API entry in `PrivacyInfo.xcprivacy`.
6. **Stand up CI (LB-7).** `xcodebuild test` on every PR; guardrail/validation/forbidden-term failures are red. Run on a clean machine to confirm the hosted tests pass against the bundle.
7. **Cut/confirm beta scope.** Per the product thread, ship the beta as **Today + Learn** (hide or soft-launch Festivals/Stories) to prove the loop; keep the others behind a flag if content depth isn't ready.
8. **Soften or build over-promised features (NB-3, NB-4).** Either implement smart reminders + audio, or adjust paywall/onboarding copy so the app delivers exactly what it claims.
9. **Add the documented-but-untested guardrails (NB-6).** Forbidden-pattern test for "no social / no doctrinal-authority."
10. **Polish pass (KL-1, KL-2, KL-5).** Add the gentle hint system; persist `LessonProgress`; begin replacing placeholder iconography.
11. **Accessibility & QA matrix.** VoiceOver labels, Dynamic Type, notification permission denial path, purchase edge cases, offline behaviour.

Reaching items 1–6 (plus a clean CI test run) credibly moves readiness to ~85% and unblocks TestFlight.

### Test coverage summary
**What's tested (5 XCTest files, hosted target):**
- `SeedDecodingTests` — every seed JSON decodes into its model; specific ids present; `Achievement.Requirement` custom Codable shape; in-code Codable round-trips.
- `ContentValidationTests` — required-field detection, positive achievement targets, quiz `correctIndex` range, festival date sanity, duplicate-id detection, `isPremium` presence in JSON, shloka `dateKey` format, and **zero validation errors on shipped seed**.
- `LessonOrderingTests` — seed lessons are uniquely/ascending ordered; duplicate/non-positive levels flagged.
- `ShlokaSelectorTests` — deterministic same-day selection, stable across times, consecutive-day rotation, `dateKey` pin wins, empty catalogue → nil, and `AppDeepLink.parse` cases.
- `ForbiddenTermsTests` — case-insensitive forbidden-term detection, multi-term, **no forbidden terms in shipped seed**, injected-label flagging, and **symbol system excludes any bell**.

**What's NOT tested:** any view/view-model behaviour (Today/Learn/Festivals/Stories/Profile); `ProgressService` streak/points/achievement logic (`StreakCalculator` has no unit test despite being pure and critical); `StoreService` purchase/entitlement flow; `NotificationService` scheduling; auth flows; persistence; deep-link *routing* (only parsing is tested); and **content-source parity** (the LB-1 divergence is invisible to current tests). There is **no CI**, so even the existing tests don't gate merges.

---

## 9. Launch Checklist

**App Store / metadata**
- [ ] Reconcile IAP pricing across `.storekit`, `AppStore/metadata.md`, and App Store Connect (LB-6).
- [ ] Create IAP products in App Store Connect matching `SvaraProductID` (`com.svara.plus.monthly/yearly/lifetime`).
- [ ] Replace the support URL (`github.com/pri8771/claude_app_dt`) with a real Svara support URL.
- [ ] Screenshots, app preview, keywords, "What's New" finalized; confirm description matches actual behaviour (no-account start, no ads, no social feed) — see LB-2.
- [ ] Age rating: 4+ (no objectionable content); confirm against final content.
- [ ] Primary category Health & Fitness, secondary Education (confirm fit; "spiritual practice" sits at the Health & Fitness/Lifestyle boundary).

**Privacy & data**
- [ ] Publish Privacy Policy + Terms; wire `SettingsView` links and metadata URLs to them (LB-4).
- [ ] Complete `PrivacyInfo.xcprivacy`: declare on-device data, no tracking, and add the `UserDefaults` required-reason API entry (LB-8).
- [ ] Complete App Privacy "nutrition label" answers (name/email stored on-device, not linked, not tracked).
- [ ] Confirm `DailyCheckIn` reflection text stays local-only if/when that feature ships.

**Safety / permissions**
- [ ] Notification usage string is set (`INFOPLIST_KEY_NSUserNotificationsUsageDescription`) — verify final copy.
- [ ] Verify graceful behaviour when notification permission is denied (toggle reverts — already implemented; test on device).
- [ ] Confirm reminder copy is gentle and non-guilt-tripping (guardrail §6).

**Content review (BLOCKING — guardrail-driven)**
- [ ] Human cultural/theological sign-off recorded for every shipped mantra, lesson, festival, story, and shloka (LB-3).
- [ ] Enforce `reviewStatus ∈ {humanReviewed, sourced}` in validation/CI for all user-facing content.
- [ ] Re-run forbidden-term + no-bell tests; confirm green.
- [ ] Confirm no festival is tied to loot/streak-freeze gifts; no "lives" in Learn; copy uses humble, plural framing.

**Build / config**
- [ ] Wire `Svara.storekit` into the run scheme for simulator testing (LB-5).
- [ ] Reconcile in-code seed fallback with JSON + add a parity test (LB-1).
- [ ] Stand up CI (`xcodebuild test`) and confirm the hosted test target passes on a clean checkout (LB-7).
- [ ] Confirm code signing / `DEVELOPMENT_TEAM` (796XH483R4) and bundle id (`com.svara.app`) for distribution.
- [ ] Provide a real App Icon set (1024 present; confirm all sizes via asset catalog) and confirm accent color.

**Recommended pre-TestFlight scope gate**
- [ ] Decide beta surface: **Today + Learn** (recommended) vs all five tabs; hide/flag any tab whose content depth or review isn't ready.
