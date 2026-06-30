# Svara

**A daily spiritual wellness app rooted in Hindu culture.**
Think *Headspace meets Duolingo* with a Hindu spiritual soul — a warm, gamified
daily companion for Indians aged 18–35, in India and across the diaspora.

Svara is **not** a virtual temple and **not** a religion-heavy app. It's a gentle,
modern daily habit: three-minute practices, bite-sized lessons, the stories behind
the festivals you grew up with, and the symbols behind the deities.

> Built with SwiftUI, iOS 17+, MVVM. This repository contains the Phase 1
> foundation: a fully navigable app running on local seed content, with every
> backend dependency hidden behind a protocol so Firebase and StoreKit can be
> switched on without touching feature code.

> _Updated 2026-06-30 to match the shipped product and launch scope. See
> [`LAUNCH_READINESS.md`](LAUNCH_READINESS.md) for the canonical PRD, MVP feature
> status (Built/Partial/Not built), bug & risk triage, and the path to TestFlight.
> Implementation status: working SwiftUI app + tests (Building) — not yet
> launch-ready._

---

## Features (MVP)

| Tab | What it does |
| --- | --- |
| **Today** | Daily 3-minute practices (morning mantra, evening prayer, midday breath, gratitude), a streak banner, and a mantra of the day. Guided, timed practice player that awards Svara Points. |
| **Learn** | Duolingo-style lessons that teach mantras/slokas step by step — intro, listen, meaning, and interactive quizzes — with XP and progress. |
| **Festivals** | Upcoming festival moments with a countdown, the story, why it matters, and small activities to mark the day. |
| **Stories** | Stories & Symbols organised by human themes (courage, wisdom, devotion…), each with the tale, its meaning, and a takeaway. |
| **Profile** | Streak, Svara Points, best streak, achievements grid, settings, and the Svara Plus upgrade. |

Gamification: **streaks**, **Svara Points**, and **achievements** that unlock with a
celebratory toast.

Not in MVP: community feed.

---

## Architecture

```
Svara/
├── App/                     App entry, DI container, root navigation
│   ├── SvaraApp.swift        @main, appearance, Firebase seam
│   ├── AppEnvironment.swift  Composition root: owns services + session state (@Observable)
│   ├── RootView.swift        Onboarding → Auth → Main routing
│   └── MainTabView.swift     The 5-tab spine + achievement toast
├── Core/
│   ├── Models/              UserProfile, DailyPractice, Mantra, Lesson,
│   │                        Festival, StorySymbol, PracticeSession, Achievement
│   ├── Services/            Protocol-based services + local implementations
│   │   ├── AuthService            (+ MockAuthService, FirebaseAuthService seam)
│   │   ├── ContentRepository      (+ LocalContentRepository, Firestore seam)
│   │   ├── ProgressService        (+ LocalProgressService, StreakCalculator)
│   │   ├── NotificationService    (+ LocalNotificationService)
│   │   ├── StoreService           (StoreKit 2, freemium)
│   │   └── Persistence            (KeyValueStore over UserDefaults)
│   └── DesignSystem/        SvaraTheme (colors/spacing/gradients), typography,
│                            SvaraCard, PracticeCard, PrimaryButton, common UI
├── Features/                One folder per surface, MVVM
│   ├── Onboarding / Auth
│   ├── Today  (TodayViewModel, TodayView, PracticePlayerView)
│   ├── Learn  (LearnViewModel, LearnView, LessonPlayerView)
│   ├── Festivals / Stories / Profile
│   └── Shared (MantraDetailView)
└── Resources/               Assets, seed content, StoreKit config
    ├── SeedContent.swift     6 mantras, 4 practices, 4 lessons, 5 festivals, 6 stories, 10 achievements
    └── Svara.storekit
```

### Patterns

- **MVVM** — each feature has an `@Observable` view model; views are declarative.
- **Dependency injection** — `AppEnvironment` is the single composition root,
  injected via SwiftUI's `.environment(...)`. It holds every service *by protocol*.
- **Observation** — uses the iOS 17 `@Observable` macro throughout.
- **Protocol seams** — no feature code references Firebase, Firestore, UserDefaults
  or a concrete backend directly.

---

## Backend integration (production seams)

Everything runs offline today on bundled seed content. To go live:

### Firebase Auth + Firestore
1. Add the `firebase-ios-sdk` Swift Package (FirebaseAuth, FirebaseFirestore).
2. Drop `GoogleService-Info.plist` into the app target (it's git-ignored).
3. Uncomment `FirebaseApp.configure()` in `SvaraApp.init`.
4. Swap `MockAuthService` → `FirebaseAuthService` and `LocalContentRepository`
   → `FirestoreContentRepository` in `AppEnvironment.live()`.

See `FirebaseAuthService.swift` and the commented `FirestoreContentRepository`
in `ContentRepository.swift` — both already conform to the protocols.

### StoreKit 2 (freemium "Svara Plus")
`StoreService.swift` is real StoreKit 2: it loads products, processes purchases,
listens for transaction updates, and derives entitlement from
`Transaction.currentEntitlements`. Product IDs live in `SvaraProductID`. The
`Svara.storekit` configuration lets you test purchases in the simulator —
select it under *Scheme → Run → Options → StoreKit Configuration*.

### Local notifications
`NotificationService` schedules gentle morning/evening reminders via
`UserNotifications`, wired to the toggles in Settings.

---

## Getting started

1. Open `Svara.xcodeproj` in Xcode 16+.
2. Select the **Svara** scheme and an iOS 17+ simulator.
3. Run. No package resolution or signing is required for the local build.

The project uses Xcode's file-system-synchronized groups, so new files added
under `Svara/` are picked up automatically — no `.pbxproj` surgery needed.

---

## Content & guardrails (Phase 2A)

- **`ProductGuardrails.md`** (repo root) is the binding source of truth for what
  Svara is and is not (anti-Primandir constraints, tone, gamification ethics,
  content sensitivity). Read it before adding features or content.
- **Seed content loads from JSON** in `Svara/Resources/SeedData/`
  (`seed_mantras`, `seed_lessons`, `seed_festivals`, `seed_stories`,
  `seed_shlokas`, `seed_achievements`) via `SeedContentProvider`, with the
  in-code `SeedContent` arrays as an offline fallback.
- **`ContentValidation`** checks required fields, lesson ordering, parseable
  festival dates, present premium flags, and forbidden Primandir-style terms in
  user-facing labels.
- **Shared content models** added: `ShlokaOfDay` (widget-ready display text +
  deep links), `LessonProgress`, `DailyCheckIn`. All carry optional provenance
  (`sourceName`, `sourceNote`, `traditionNote`, `reviewStatus`) and are
  documented for later Firebase mapping. Private reflection text in
  `DailyCheckIn` is **local-only** (never synced in Phase 2A).

## Testing

Unit tests live in `SvaraTests/` (a hosted test target — `Bundle.main` is the
app bundle, so bundled seed JSON is reachable):

- `SeedDecodingTests` — JSON decoding + Codable round-trips for every model
- `ContentValidationTests` — required fields, targets, premium-flag presence
- `LessonOrderingTests` — valid, unique lesson ordering
- `ShlokaSelectorTests` — deterministic shloka-of-day selection + deep-link parsing
- `ForbiddenTermsTests` — forbidden-term detection and a bell-free symbol system

Run with `⌘U` in Xcode, or `xcodebuild test -scheme Svara -destination 'platform=iOS Simulator,name=iPhone 15'`.

## Roadmap

- Phase 1 ✅ — foundation: navigation, models, design system, services, seed content
- Phase 2A ✅ — product guardrails, JSON seed content, validation, shared models, tests
- Phase 2 — Firebase wiring, real audio for mantras, content authoring
- Phase 3 — personalised daily plan, richer streaks, widgets & Live Activities
