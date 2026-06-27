# My Mandir — Digital Temple (iOS v0)

**A sacred relationship system for Hindu life — not a content, mantra, or
meditation app.**

My Mandir gives a person a single, private *Digital Mandir*: a quiet living
altar. They make a **Sankalp** (a sacred intention or vow), and return to it
over time — lighting the lamp, placing offerings, leaving reflections, and
preserving memories. The home screen *is* the altar. There is no feed, no tab
bar, no streaks, and no noise.

> Built with SwiftUI (iOS 17+), MVVM, and SwiftData. Fully offline — the app
> makes **no network calls**, ever. All content lives in local seed JSON loaded
> once on first launch.

See **[`V0_SCREEN_CONTRACTS.md`](V0_SCREEN_CONTRACTS.md)** for the binding
doctrine of each screen.

---

## The v0 experience

1. **Onboarding (5 steps)** — Welcome → "Why are you here?" → Name your mandir →
   Choose your devatas → Make your first sankalp (optional but encouraged).
2. **The Altar (MandirHome)** — the anchor. A persistent altar (header, lamp,
   mode selector) with the presiding devata. **Hold the wick** to light the lamp
   — a deliberate act of returning, recorded as a `MandirReturn`. Beneath the
   altar, an in-place selector swaps between four modes:
   - **Altar** — simply be present; see the held intention and the next sacred day.
   - **Offer** — place a private offering: pushpa, jal, deep, or vachan.
   - **Reflect** — sit with the held sankalp, name a mood, leave words; fulfill it.
   - **Thread** — the woven record of every return and preserved memory.
3. **Fulfillment** — complete a sankalp with a closing acknowledgment; it is
   preserved forever as a memory.

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
│   └── AppRootView.swift        Onboarding vs. Altar home
├── Core/
│   ├── DesignSystem/        Theme (dark altar palette), Typography, Components, Color+Hex
│   ├── Extensions/          Date+Sacred (recurrence, relative phrases), View helpers
│   └── Constants/           AppConstants (keys, resource names)
├── Domain/
│   ├── Models/              Devata, Sankalp, Reflection, Memory, MandirReturn (+ enums)
│   ├── Mandir/              DigitalMandir + MandirRepository (central data access)
│   ├── DevotionalIdentity/  DevotionalIdentity
│   ├── SacredTime/          SacredDateEntry (+ Region) + SacredTimeRepository
│   └── Seed/                SeedLoader (first-launch JSON → SwiftData, idempotent)
├── Features/
│   ├── Onboarding/          5 step views + OnboardingViewModel
│   ├── MandirHome/          Altar shell — MandirHomeView + ViewModel + MandirRoute,
│   │                        AltarHeader, AltarStateView, HoldWickInteraction,
│   │                        MandirModeSelector, MandirMode, AltarSurface
│   ├── Offer/               OfferView (the Offer surface)
│   ├── Reflect/             ReflectView (the Reflect surface)
│   ├── Thread/              ThreadView (the Thread surface)
│   ├── Sankalp/             NewSankalpView, SankalpFulfillmentView
│   ├── Memory/              NewMemoryView (preserve a memory)
│   ├── SacredTime/          SacredTimeView, SacredDateCard
│   └── Settings/            SettingsView, DevotionalIdentityEditView
├── Analytics/               AnalyticsEvent enum + AnalyticsService (console, Firebase-ready)
├── FeatureFlags/            FeatureFlag enum (v0 on; v1 Family, v2 Temple-Connected off)
├── Localizable/             en.lproj + hi.lproj scaffold (see note below)
├── SeedData/                devatas.json, sacredDates.json
└── Resources/               Assets.xcassets, Preview Content
```

### Patterns

- **MVVM.** Views are declarative; `@Observable` view models hold state and
  intent (`OnboardingViewModel`, `MandirHomeViewModel`). Persistence lives
  behind `MandirRepository` / `SacredTimeRepository`, so future seams (family
  sync, etc.) don't ripple into feature code. Live lists use SwiftData `@Query`.
- **SwiftData.** Eight `@Model` types in one local store. Cross-references use
  `UUID`s (`mandirId`, `sankalpId`, `devataId`, `reflectionId`) rather than hard
  relationships, keeping v0 simple and migration-friendly.
- **Analytics.** Every devotional moment is an `AnalyticsEvent` with a stable
  snake_case `name` and a `parameters` dictionary. v0 logs to the console via
  `os.Logger`; a `FirebaseAnalyticsSink` can be added without touching call
  sites.
- **Feature flags.** `FeatureFlag` declares three horizons — **v0 · Private
  Mandir** (live), **v1 · Family**, **v2 · Temple-Connected** (declared but
  off). The expansion path is wired but inert; visible in a debug-only inspector
  in Settings.

### Feature horizons

| Horizon | Flags |
| --- | --- |
| **v0 · Private Mandir** (on) | onboarding, sankalp, reflections, memories, sacredTime, privateOfferings, returnThread |
| **v1 · Family** (off) | familyMandir, sharedSankalps, familyObservances, ancestorDates, familyMemories, privateFamilySync |
| **v2 · Temple-Connected** (off) | templeRelationships, templeVerification, templeRitualEvents, sevaParticipation, priestReviewedGuidance, templeAnnouncements |

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
| `MandirReturn` | `mandirId`, `sankalpId?`, `offeringKind?` (pushpa/jal/deep/vachan), `reflectionId?`, `note?`, `date` |
| `SacredDateEntry` | `name`, `nameDevanagari?`, `date`, `yearlyRecurring`, `devataAssociation?`, `significance`, `regionRelevance` ([Region]), `tradition?` (seeded) |

**8 Sankalp intentions:** healing, gratitude, grief, renewal, protection,
festivalObservance, personalVow, reconnection.

**4 Offering kinds:** pushpa (flower), jal (water), deep (lamp), vachan (a word).

**12 Devatas:** Ganesha, Shiva, Vishnu, Lakshmi, Durga, Hanuman, Krishna,
Saraswati, Rama, Parvati, Murugan, Kali.

---

## Acceptance criteria (v0) — status

- ✅ App works fully offline — no network calls.
- ✅ Onboarding builds a private mandir (name, presiding devata, identity).
- ✅ Altar-first home: hold the wick to light the lamp (a recorded return).
- ✅ Create a sankalp (during onboarding and from the altar).
- ✅ Place a private offering (pushpa/jal/deep/vachan).
- ✅ Leave a reflection (with mood) on the held sankalp.
- ✅ Fulfill a sankalp with a closing acknowledgment (preserved as a memory).
- ✅ Save / preserve a memory.
- ✅ Read the Thread — the woven record of returns and memories.
- ✅ View Sacred Time as an upcoming-dates list (not a calendar grid).
- ✅ No tab bar — the altar with an in-place mode selector; deeper screens push.

---

## Building

Open `DigitalTemple.xcodeproj` in Xcode 16+ and run the **DigitalTemple**
scheme on an iOS 17+ simulator or device. The project uses Xcode's synchronized
file groups, so files added under `DigitalTemple/` are picked up automatically.

> **Localization.** `en.lproj` / `hi.lproj` are an early **scaffold**, not
> production-grade localization: v0 copy is still inline in the views and the
> Hindi strings are a starting point to be reviewed by a fluent translator
> before any Hindi release.

> **Dates.** Lunar festival dates in `sacredDates.json` are seeded with their
> 2026 Gregorian dates and shown forward-looking. Precise multi-year panchang
> calculation is a planned enhancement.
