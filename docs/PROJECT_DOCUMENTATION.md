# Svara — Project Documentation

_Updated 2026-06-30 to match the shipped product and launch scope. See LAUNCH_READINESS.md._

GitHub is the source of truth for this project documentation. Notion indexes this file in the Priyansh App Factory Command Center.

> **Correction note:** Earlier revisions of this file described Svara as an audio-first
> "daily practice / audio player / practice library" app with tabs like Today / Library /
> Player / Progress / Settings. That does **not** match the repository. The shipped app is a
> five-tab spiritual-wellness app (**Today, Learn, Festivals, Stories, Profile**) running on
> bundled JSON seed content, with timed (non-audio) guided practices, Duolingo-style lessons,
> a festival calendar, a stories library, gamification, and a StoreKit 2 freemium upgrade.
> This file has been rewritten to reflect that reality. The binding product contract is
> `ProductGuardrails.md`; the canonical launch artifact is `LAUNCH_READINESS.md`.

## 00. Executive Summary
Svara is a daily spiritual-wellness iOS app rooted in Hindu culture — "Headspace meets Duolingo" with a Hindu soul — for Indians aged 18–35 in India and the diaspora. It delivers short (~3-minute) guided daily practices, bite-sized mantra/sloka lessons, the stories behind festivals, and deity tales organised by human themes, wrapped in gentle gamification (streaks, Svara Points, achievements). It runs entirely offline on bundled seed content; Firebase and richer content are deliberate, un-wired seams. Implementation status: **working SwiftUI app + tests (Building)**, not yet TestFlight-ready.

## 01. Product
MVP surface (five SwiftUI tabs, MVVM):
- **Today** — daily practices (morning mantra, midday breath, evening prayer, gratitude), a timed guided practice player, streak banner, and a deterministic mantra-of-the-day.
- **Learn** — Duolingo-style lessons (intro / listen / meaning / multiple-choice / fill-blank) with XP; **no "lives"** mechanic (forgiving by design).
- **Festivals** — upcoming festivals with countdown, significance, story, activities, and "mark as observed."
- **Stories** — deity stories/symbols filterable by human theme (courage, wisdom, devotion…).
- **Profile** — streak, Svara Points, best streak, achievements grid, settings, and the Svara Plus upgrade.

Out of scope for v1 (and partly forbidden by guardrails): virtual temple / ritual simulator, religious marketplace, public social feed, doctrinal-authority content, punitive gamification, the bell symbol, real audio, cloud sync, widgets, and a daily mood check-in UI. See `LAUNCH_READINESS.md` §3.

## 02. Design
Warm, calm, restrained visual language: a saffron/dawn palette, soft cards, a breathing-ring practice player, and a curated symbol system (**Lotus · Diya · Om · Dawn · Mandala · Sunrise — no bell**). Icons are currently interim SF Symbols pending bespoke art. Tone is "a kind friend, not a guru" (`ProductGuardrails.md` §4–5).

## 03. Frontend Technical
SwiftUI, iOS 17+, MVVM with the `@Observable` macro. Single composition root `AppEnvironment` injected via `.environment(...)`, holding every service **by protocol** (`AuthService`, `ContentRepository`, `ProgressService`, `NotificationService`, `StoreService`, `KeyValueStore`). Navigation: Onboarding → Auth → MainTabView (Today / Learn / Festivals / Stories / Profile), with full-screen practice and lesson players. Progress (sessions, streaks, points, achievements) persists to `UserDefaults` via a Codable store. Practices are **timed and text-guided, not audio** in v1.

## 04. Backend Technical
No backend in v1 — all content is bundled JSON (`Resources/SeedData/*.json`) served through `LocalContentRepository`, with an in-code `SeedContent` fallback. Firebase Auth + Firestore are **seams only** (`FirebaseAuthService` throws `.notConfigured`; `FirestoreContentRepository` is commented). When cloud sync arrives, private reflection text (`DailyCheckIn`) stays on-device. Local notifications schedule gentle morning/evening reminders.

## 05. Business
Freemium. Free tier is a fully useful daily practice + most content; **Svara Plus** (StoreKit 2: monthly / yearly / lifetime, with a free trial) unlocks premium lessons/stories and richer reminders. Guardrail: premium gates depth/convenience, never basic dignity or cultural access. Note: pricing currently differs between `Svara.storekit` and `AppStore/metadata.md` — reconcile before launch (`LAUNCH_READINESS.md` §7 LB-6).

## 06. Marketing
Positioning: "a respectful three-minute daily practice, rooted in Hindu culture." Category Health & Fitness (secondary Education). Channels: festival-timed content, sloka explainers, gentle streak reminders, diaspora-focused storytelling. No ads, no social feed.

## 07. User Acquisition
Beta with community testers (young Indians / diaspora, meditation-curious). Recommended beta scope (per product review): **Today + Learn** to prove the core loop before the full five tabs. Observable signals (no analytics SDK yet, so currently unmeasured): first-practice completion, practices/day, streak length, lesson completion, reminder opt-in, paywall view→purchase.

## 08. Execution
Plan to TestFlight (see `LAUNCH_READINESS.md` §8): reconcile JSON↔in-code seed content + add a parity test; add a human content-review gate; fix the first-run auth gate; wire StoreKit into the scheme and align pricing; publish privacy/terms and complete the privacy manifest; stand up CI running the test suite; then polish (hint system, lesson-progress persistence, brand art, audio).

## 09. QA
Existing unit tests (hosted target): seed decoding/round-trips, content validation, lesson ordering, deterministic shloka selection, forbidden-term + no-bell checks. Gaps: no view/view-model tests, no `StreakCalculator`/`StoreService`/notification tests, and **no CI**. Manual QA matrix: practice timer + completion, streak math across day boundaries, achievement unlock/toast, premium gating + purchase/restore, notification permission denial, offline behaviour, Dynamic Type, and VoiceOver.

## 10. Legal / Compliance
Local-only data (name/email/progress in `UserDefaults`); no tracking, no third-party SDKs. Before submission: publish a Privacy Policy + Terms and wire them in-app and in metadata; complete `PrivacyInfo.xcprivacy` (on-device data + `UserDefaults` required-reason API) and the App Privacy answers. Content sources must be cited and human-reviewed; keep wellness claims modest (a breath "calms," it does not "cure").

## 11. Operations
Release process: content sign-off → automated validation/forbidden-term CI → internal QA → community beta → TestFlight. Post-launch roadmap: real audio for mantras, shloka-of-day surfacing + widgets, per-lesson resume/mastery, grace-day kindness mechanic, deeper content, and (deferred) Firebase sync.
