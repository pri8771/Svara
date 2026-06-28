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

---

## Features (MVP)

| Tab | What it does |
| --- | --- |
| **Today** | Daily 3-minute practices (morning mantra, evening prayer, midday breath, gratitude), a streak banner, and a mantra of the day. Guided, timed practice player that awards Svara Points. |
| **Learn** | A guided **Aaroh Path**: a 7-day beginner journey (Om → Vakratunda → Saraswati Namastubhyam) of 60–120s lessons. Your next step is obvious on open; each lesson unlocks one piece of meaning and gently unlocks the next. |
| **Festivals** | Seasonal cultural **moments**, not a calendar: an upcoming hero with a countdown, a "Coming soon" rail, a "This season" section, a gentle regional lens, and per-festival pages with the story, symbols, a tiny 2–5 min activity, and a family conversation prompt. |
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
│   ├── Learn  (LearnViewModel, LearnView, LessonPlayerView, LessonResultView,
│   │          MantraCourseView, + pure logic: LessonEvaluator, AarohPath,
│   │          DailyRecommender, LearnCopy)
│   ├── Festivals / Stories / Profile
│   └── Shared (MantraDetailView)
└── Resources/               Assets, seed content, StoreKit config
    ├── SeedContent.swift     in-code fallback mirroring the JSON seed
    ├── SeedData/*.json       authoring source of truth (mantras, lessons, …)
    └── Svara.storekit
```

---

## Festival Moments (Festivals)

The Festivals tab is built around one idea: **"Know what's coming, understand
why it matters, and do one tiny meaningful thing."** It's seasonal cultural
moments for young Indians and the diaspora — not a calendar or a Wikipedia page,
and explicitly **not** a virtual temple, puja simulator, or booking app.

**Home (`FestivalsView`).** Header "Festival Moments" → a gentle region picker →
an **Up next** hero card (countdown, name, short context, Explore) → a
horizontal **Coming soon** rail (`FestivalMomentCard`) → a **This season**
section → **The year ahead**. A warm empty state shows when nothing is imminent.

**Detail (`FestivalDetailView`).** Illustrated hero, date + region tags ("Dates
can vary by region and tradition"), Why it matters, The story, Symbols, a tiny
2–5 min activity, a family conversation prompt ("Ask someone in your family how
they celebrated this growing up"), a related mantra/practice when available, and
a personal Save/Share (no public feed).

**Activity flow (`FestivalActivityView`).** Intro → a few gentle steps → an
optional reflection → completion. Reflection text is **local-only** — never
stored or sent anywhere. These are reflective, real-world prompts; there is no
on-screen ritual to perform.

**Region lens (`RegionFilterView` + `FestivalRegionFilter`).** Filters (India,
Diaspora, North/South/West/East India, Global Hindu) **personalise ordering but
never hide festivals** — a matching festival floats to the front; the rest
remain, gently dimmed. Untagged festivals are treated as universally relevant.

**Progress.** Completing a festival's tiny activity awards its points **exactly
once** via `ProgressService.completeFestivalActivity` (idempotent on the
`observedFestivalIDs` ledger, which also drives the `festivalsObserved`
achievement). No streak-freeze gifts are ever tied to a festival.

**Content & provenance.** Seven festivals ship with rich content — Diwali, Holi,
Navaratri, Ganesh Chaturthi, Janmashtami, Raksha Bandhan, Makar Sankranti /
Pongal (plus Guru Purnima). Each carries `shortDescription`, `whyItMatters`,
`story`, `symbols`, `activities`, a `tinyActivity` (steps + reflection),
`familyPrompt`, `regionTags`, optional `relatedMantraID`/`relatedPracticeID`,
`isDateApproximate`, and provenance (`sourceName`/`sourceNote`/`traditionNote`/
`reviewStatus`). Stories use humble framing — "Traditions vary — here's one
common story." Dates are illustrative 2026/2027 and explicitly marked approximate.

**What's mocked.** Content loads from `seed_festivals.json` via
`SeedContentProvider` (Firestore later, behind `ContentRepository`). Completion
persists locally via `KeyValueStore`. The hero illustration is a themed gradient
placeholder; Save/Share are personal-only; there is no WidgetKit in this phase.

---

## The Aaroh Path (Learn)

The Learn tab is a **guided path**, not a static content library. "Aaroh" (the
ascent of notes) names the idea: one gentle step at a time.

**Concept.** A first **7-day beginner path** teaches three mantras in sequence —
**Om** (Days 1–2) → **Vakratunda** (Days 3–5) → **Saraswati Namastubhyam**
(Days 6–7). Each day is a 60–120-second lesson. The path is grouped into
per-mantra *chapters* (`MantraCourseView`). Lessons beyond the path
(Gayatri, Shanti) sit under "Beyond the path".

**Lesson flow.** A lesson is a few cards: `intro` → `listen` → a quiz step →
`reflection`, ending on a result screen that **unlocks one piece of meaning**
("You unlocked: What Vakratunda means") and previews the next step.

**Supported step types** (`LessonStep.Kind`):

| Kind | Interaction |
| --- | --- |
| `intro` / `listen` / `meaning` / `reflection` | Reading / chanting cards — never "wrong" |
| `multipleChoice` / `matchMeaning` | Pick the option that matches |
| `fillBlank` | Pick the option *or* a free-text accepted answer (case/space-insensitive) |
| `syllableOrder` | Tap syllables into the correct order |

Answer checking is pure and forgiving (`LessonEvaluator`): a non-match is never
"wrong" — the correct answer is shown kindly with an encouraging line, and the
learner always continues. **No lives, hearts, or failure states** (ProductGuardrails §8.2).

**Progress rules** (unified in `ProgressService`):
- **Points/Light awarded once** per lesson (idempotent on `completedLessonIDs`).
- **Streak increments at most once per local day** (`StreakCalculator`).
- **Step-level progress** (`LessonProgress`) tracks resume state, best score, and
  hints used — points are never awarded by step or hint.
- **Unlock** is linear: the first lesson is always open; each next lesson opens
  when the one before it is completed (`AarohPath`).
- **Daily recommendation** priority (`DailyRecommender`): continue in-progress →
  next unlocked → first beginner → review completed → shloka of the day. Surfaced
  on both the Today "continue Aaroh" card and the Learn hero.

**Content provenance.** Every path lesson carries `meaningOverview`,
`pronunciationTip`, an `insightTitle`/`insightBody`, and optional
`sourceName`/`sourceNote`/`traditionNote`/`reviewStatus`. Interpretive meaning
uses humble, plural framing — "One common translation…", "One way to understand
this…", "Traditions vary by family and region." (ProductGuardrails §7).

**What's mocked / local.** Content loads from bundled JSON via
`SeedContentProvider` (Firestore later, behind `ContentRepository`). Lesson and
streak progress persist locally via `KeyValueStore` over `UserDefaults` (behind
the protocol; Firestore subcollections later). There is **no audio** for mantras
yet and **no WidgetKit** in this phase. SwiftUI previews run entirely on
mock/local data — Firebase stays behind protocols and is optional for local dev.

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
- `LessonEvaluatorTests` — answer validation for matchMeaning / fillBlank / syllableOrder
- `AarohPathTests` — unlock logic, node states, and the 7-day seed path shape
- `DailyRecommenderTests` — daily recommendation priority
- `ProgressDeduplicationTests` — points-once, streak-once-per-day, best-score tracking
- `LearnCopyTests` — no punitive/forbidden copy in Learn strings; gentle phrasings present
- `FestivalLogicTests` — countdown, season mapping, and gentle region filtering (no hiding)
- `FestivalProgressTests` — festival activity completion awards points once (no double-award)
- `FestivalContentTests` — all 7 festivals richly authored; no forbidden/ritual-simulation copy

Run with `⌘U` in Xcode, or `xcodebuild test -scheme Svara -destination 'platform=iOS Simulator,name=iPhone 15'`.

## Roadmap

- Phase 1 ✅ — foundation: navigation, models, design system, services, seed content
- Phase 2A ✅ — product guardrails, JSON seed content, validation, shared models, tests
- Phase 2B ✅ — Aaroh Path retention engine: 7-day beginner path, expanded lesson
  player (matchMeaning / fillBlank / syllableOrder) with gentle feedback,
  meaning unlocks, lesson-progress persistence, daily recommendation, Today
  "continue Aaroh" card, and tests for lesson logic + point dedup
- Phase 2C ✅ — Festivals tab as seasonal moments: enriched festival model
  (symbols, tiny activities, family prompts, region tags, provenance), home with
  hero/coming-soon/this-season, rich detail pages, a 2–5 min activity flow with
  once-only points, a gentle non-blocking region lens, and tests for countdown,
  region filtering, and activity deduplication
- Phase 2 — Firebase wiring, real audio for mantras, content authoring
- Phase 3 — personalised daily plan, richer streaks, widgets & Live Activities
