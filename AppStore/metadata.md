# Svara — App Store Metadata

Repository source for `TF-008`. Copy this material to App Store Connect only
after `TF-001`, `TF-004`, `TF-006`, and `TF-007` are complete. If App Store
Connect differs, update and approve the repository first.

## Approved TestFlight Configuration

- Version/build: 1.0 (3)
- Bundle ID: `com.primandir.svara`
- Apple ID: `6785557134`
- Platform: iPhone, iOS 17+
- Primary language: English (U.S.)
- Existing immutable SKU: `SVARA001`
- Surface: full five-tab app
- Distribution: owner internal smoke, then invitation-only external group
  `Svara Close Friends`, initial limit 10; public link disabled
- Operator, QA/feedback owner, and stop authority: product owner
- Review contact: use the owner’s secure App Store Connect contact record
- Commerce: disabled under `DEC-006`; all content is free

Still required before inviting external testers: final age-rating and rights
answers, content/audio sign-off, live legal-page verification, physical-device
QA, TestFlight test information comparison, and Apple TestFlight App Review.

Copyright/legal seller text is not required for TestFlight App Review. It
remains deferred to the eventual public App Store version submission and must
use the real rights owner when that work begins.

## Name
Svara

## Subtitle
Daily Hindu spiritual practice

## Category
Primary: Health & Fitness
Secondary: Education

## Description
Svara is your daily spiritual companion, rooted in Hindu culture.

Three minutes a day. A morning mantra, a midday breath, an evening prayer. Svara guides you through tiny daily practices — the kind that compound quietly into a steadier life.

**Practice**
Start each day with a guided mantra practice. Choose your pace, follow the breathing ring, and earn your streak. Morning, midday, and evening practices adapt to your schedule.

**Learn**
Bite-sized lessons teach you slokas and their meaning — like a language app for your spiritual side. Understand *why* the Gayatri Mantra is recited at dawn, or what the Shanti Mantra is really wishing for.

**Festivals**
Never miss the story behind a celebration again. Guru Purnima, Janmashtami, Diwali — Svara explains the meaning, the rituals, and why they matter, right when the moment arrives.

**Stories**
The tales behind the deities, organised by the human themes they speak to — courage, devotion, wisdom, protection. Read the story. Understand the symbol. Carry the lesson.

No account required to start. No ads. No social feed. Just a quiet daily practice, yours.

## Keywords
mantra,prayer,meditation,yoga,gayatri,vedic,devotion,festival,sloka,Sanskrit,mindfulness,streaks

## Support URL
https://pri8771.github.io/Svara/

## Marketing URL
https://pri8771.github.io/Svara/

## Privacy Policy URL
https://pri8771.github.io/Svara/privacy.html

## Terms of Service (EULA) URL
https://pri8771.github.io/Svara/terms.html

> Hosting: the legal/support pages live in this repo under `docs/`. Enable
> GitHub Pages once (repo Settings → Pages → Deploy from a branch → branch =
> default, folder = `/docs`). A `.nojekyll` file is included so the static HTML
> serves as-is.

## Proposed Age Rating (Unverified)

Expected: 4+. This is not authoritative until `TF-008` completes Apple's
current questionnaire and records all calculated regional results.

## Pricing
Free. No in-app purchases are exposed in the current owner-only testing build.

## Deferred Future In-App Purchases
The dormant monthly, yearly, and lifetime Plus definitions are not part of this
testing build. They require explicit reactivation and completion of `TF-005`
and `TF-012` before they may appear in metadata or the app.

## App Privacy (App Store Connect "nutrition label")
This release stores data **on-device only** — no account, analytics, ads, backend,
no tracking. Answer the App Privacy questionnaire as:

- **Data used to track you:** None.
- **Data linked to you:** None. (The optional display name is stored on the
  device and is not transmitted to us, so it is not "collected" per Apple's
  definition.)
- **Data not linked to you:** None collected.
- **Does this app collect data?** No.

Required-reason API declared in `PrivacyInfo.xcprivacy`: UserDefaults (reason
`CA92.1` — accessed only for data accessible solely to this app).

## What's New (v1.0)
First release. Daily practices, guided lesson path, festival calendar, and stories library — all in three minutes a day.

## TestFlight Beta App Description
Svara is a local-first daily spiritual-wellness app rooted in Hindu culture.
This beta includes guided daily practices with bundled mantra audio, the Aaroh
learning path, festival moments, stories and symbols, local progress, gentle
reminders, and free access to all bundled content. No account is required, no
purchase flow is shown, and no user data leaves the device.

## What to Test

1. Complete onboarding and confirm the Today tab opens without sign-in.
2. Finish a practice and a lesson; relaunch and confirm points, streak, and
   progress remain. In Profile, confirm Svara Points explain that they unlock
   private 100/250/500-point badges and never lock content.
3. Play and pause mantra audio from a practice and a listening lesson.
4. Enable reminders, including the denied-permission path.
5. Confirm all lessons and content open without a paywall or membership prompt.
6. Review Festival and Stories content for clarity, respectful framing,
   truncation, Dynamic Type, dark mode, and VoiceOver.

Please report the device model, iOS version, screen, steps, and a screenshot
when possible.

## Beta Feedback Email
priyansh.chordia@gmail.com

## Beta App Review Notes

- No login is required. Complete onboarding to enter the app.
- The app is local-first and has no backend, analytics, ads, or tracking.
- All content is free in this testing build. Plus and StoreKit product loading
  are disabled.
- Notification permission is requested only after the tester enables practice
  reminders in Settings.
- Legal and support links are under Profile → Settings.

## Export Compliance
The app does not implement non-exempt encryption. The generated Info.plist sets
`ITSAppUsesNonExemptEncryption` to `NO`.
