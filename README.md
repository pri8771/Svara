# My Mandir — Digital Temple (iOS v0)

**A sacred relationship system for Hindu life — not a content, mantra, or
meditation app.**

My Mandir gives a person a single, private *Digital Mandir*: a quiet living
sacred space. They make a **Sankalp** (a sacred intention or vow), and return
to it over time — to reflect, to remember, and to preserve. The home screen
*is* the mandir. There is no feed, no tab bar, no streaks, and no noise.

> Built with SwiftUI (iOS 17+), MVVM, and SwiftData. Fully offline — the app
> makes **no network calls**, ever. All content lives in local seed JSON loaded
> once on first launch.

---

## The v0 experience

1. **Onboarding (5 steps)** — Welcome → "Why are you here?" → Name your mandir →
   Choose your devatas → Make your first sankalp (optional but encouraged).
2. **The Mandir home** — the anchor. Shows the presiding devata, the active
   sankalp, the next sacred date, a gentle *return* action, and recent
   memories. Everything else is a push onto this `NavigationStack`.
3. **Hold and return** — reflect on a sankalp (with a quiet mood), fulfill it
   with a closing acknowledgment (preserved forever as a memory), browse Sacred
   Time, and save memories.

### What v0 deliberately does **not** include

No donations/payments, no content feed / daily darshan / mantra library /
temple list, no AI chat or guru, no gamification (no streaks, points, or
achievements), and no social/sharing. These omissions are the product.

---

## Architecture

```
DigitalTemple/
├── App/                     App entry + root routing
│   ├── DigitalTempleApp.swift   @main, builds the SwiftData container, seeds on launch
│   └── AppRootView.swift        Onboarding vs. Mandir home
├── Core/
│   ├── DesignSystem/        Theme (palette/metrics), Typography, Components, Color+Hex
│   ├── Extensions/          Date+Sacred (recurrence, relative phrases), View helpers
│   └── Constants/           AppConstants (keys, resource names)
├── Domain/
│   ├── Models/              Devata, Sankalp, Reflection, Memory (+ their enums)
│   ├── Mandir/              DigitalMandir + MandirRepository (central data access)
│   ├── DevotionalIdentity/  DevotionalIdentity
│   ├── SacredTime/          SacredDateEntry (+ Region) + SacredTimeRepository
│   └── Seed/                SeedLoader (first-launch JSON → SwiftData, idempotent)
├── Features/
│   ├── Onboarding/          5 step views + OnboardingViewModel
│   ├── MandirHome/          MandirHomeView + MandirHomeViewModel + MandirRoute
│   ├── Sankalp/             SankalpCard, NewSankalpView, ReflectionEntryView,
│   │                        SankalpFulfillmentView
│   ├── Memory/              MemoriesView, NewMemoryView, MemoryRow
│   ├── SacredTime/          SacredTimeView, SacredDateCard
│   └── Settings/            SettingsView, DevotionalIdentityEditView
├── Analytics/               AnalyticsEvent enum + AnalyticsService (console, Firebase-ready)
├── FeatureFlags/            FeatureFlag enum (v1/v2 features declared but off)
├── Localizable/             en.lproj + hi.lproj stubs
├── SeedData/                devatas.json, sacredDates.json
└── Resources/               Assets.xcassets, Preview Content
```

### Patterns

- **MVVM.** Views are declarative; `@Observable` view models hold state and
  intent (`OnboardingViewModel`, `MandirHomeViewModel`). Persistence lives
  behind `MandirRepository` / `SacredTimeRepository`, so future seams (iCloud
  sync, etc.) don't ripple into feature code. Live lists use SwiftData `@Query`.
- **SwiftData.** Seven `@Model` types in one local store. Cross-references use
  `UUID`s (`mandirId`, `sankalpId`, `devataId`) rather than hard relationships,
  keeping v0 simple and migration-friendly.
- **Analytics.** Every devotional moment is an `AnalyticsEvent` with a stable
  snake_case `name` and a `parameters` dictionary. v0 logs to the console via
  `os.Logger`; a `FirebaseAnalyticsSink` can be added without touching call
  sites.
- **Feature flags.** `FeatureFlag` declares the planned v1/v2 surface (daily
  darshan, reminders, iCloud sync, shared mandir, …) all flagged **off**, so the
  expansion path is wired but inert. Visible in a debug-only inspector in
  Settings.

---

## Domain model

| Model | Key fields |
| --- | --- |
| `DigitalMandir` | `name`, `primaryDevataId?`, `createdDate` |
| `DevotionalIdentity` | `displayName`, `onboardingIntention`, `traditionLeaning?`, `mandirId` |
| `Devata` | `name`, `nameDevanagari`, `tradition`, `summary`, `symbolicNote`, `isChosen` (seeded; 12) |
| `Sankalp` | `intention`, `forWhom?`, `intentionType` (8), `devataId?`, `startDate`, `dueDate?`, `status` (active/fulfilled/preserved/dormant), `mandirId` |
| `Reflection` | `sankalpId`, `content`, `mood` (quiet/grateful/hopeful/heavy/at_peace), `date` |
| `Memory` | `title`, `content`, `date`, `type` (reflection/moment/tradition/offering), `mandirId` |
| `SacredDateEntry` | `name`, `nameDevanagari?`, `date`, `yearlyRecurring`, `devataAssociation?`, `significance`, `regionRelevance` ([Region]), `tradition?` (seeded) |

**8 Sankalp intentions:** healing, gratitude, grief, renewal, protection,
festivalObservance, personalVow, reconnection.

**12 Devatas:** Ganesha, Shiva, Vishnu, Lakshmi, Durga, Hanuman, Krishna,
Saraswati, Rama, Parvati, Murugan, Kali.

---

## Acceptance criteria (v0) — status

- ✅ App works fully offline — no network calls.
- ✅ Onboarding builds a private mandir (name, presiding devata, identity).
- ✅ Create a sankalp (during onboarding and from the home).
- ✅ Add a reflection (with mood) to a sankalp.
- ✅ Fulfill a sankalp with a closing acknowledgment screen (preserved as a memory).
- ✅ Save a memory.
- ✅ View Sacred Time as an upcoming-dates list (not a calendar grid).
- ✅ No tab bar — navigation is `NavigationStack` pushes from the mandir home.

---

## Building

Open `DigitalTemple.xcodeproj` in Xcode 16+ and run the **DigitalTemple**
scheme on an iOS 17+ simulator or device. The project uses Xcode's synchronized
file groups, so files added under `DigitalTemple/` are picked up automatically.

> Note on dates: lunar festival dates in `sacredDates.json` are seeded with
> their 2026 Gregorian dates and shown forward-looking. Precise multi-year
> panchang calculation is a planned enhancement (see `FeatureFlag`).
