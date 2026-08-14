# Project Status

## Lifecycle status

`verification_pending`

## Current objective

Replace Svara 1.0 (build 2) with build 3 after the owner found that Apple's
audio stack could not decode the bundled MP3 recordings, then run the owner
TestFlight smoke followed by an invitation-only close-friends external beta
under App Factory standard 0.4.0. The public App Store release and monetization
remain deferred. The replacement build must remain external-eligible and must
not be marked TestFlight Internal Only.
Per `DEC-006`, this testing build makes every content item free and exposes no
Svara Plus or purchase UI.

## Website marketing track

`docs/MARKETING_LANDING_PAGE_TASKS.md` now owns the parallel Svara landing-page,
three-concept/three-icon design review, real screenshot capture, HubSpot
waitlist, privacy/consent, website handoff, verification, and publication
tasks. The five-app Claude Design package is prepared, but no generated concept,
icon, screenshot set, waitlist, or page is approved. ProductGuardrails,
content/audio sign-off, and TestFlight gates continue to control claims.

## Code complete

- Local-first onboarding and profile with no account wall.
- Today, Learn, Festivals, Stories, Profile, reminders, audio, and local progress.
- Dormant StoreKit 2 purchase/restore implementation retained behind the
  disabled `plusTierEnabled` flag for a future monetized build.
- Privacy manifest, hosted legal/support pages, App Store metadata, CI, unit
  tests, and UI smoke tests.

## Verified locally

- Exact build 3 candidate `ed29548`: locked Factory verification and repository
  checks pass; the complete clean-simulator action passes 159/159 with zero
  failures/skips; Release analysis passes; remote CI run `30647389027` is
  green; and a fresh 1.0 (3) archive passes bundle, privacy, audio, exclusion,
  architecture, and matching-dSYM inspection.
- Build 3 audio remediation: all nine AAC-in-M4A exports decode to non-silent
  PCM; 138/138 unit tests pass, including the new bundle/decode regression; the
  focused Today auto-start/pause UI workflow passes; and an unsigned Release
  build succeeds with exactly nine M4A files, no MP3 files, and build number 3.
- Free/points clarification: Plus remains disabled and all content remains
  available without payment or points. The complete unit suite passes 143/143;
  focused UI tests pass for the Profile explanation/next-unlock card and
  absence of Plus at default and maximum Dynamic Type, while service tests
  cover 100/250/500-point milestones, existing-profile reconciliation, and
  same-transaction bonus unlocking. An unsigned Release build also passes.
- App Factory registration verifier: passed at standard 0.4.0.
- Exact build 2 candidate gate: 153 passed, 0 failed, 0 skipped, and 0 expected
  failures on iPhone 17 Pro, iOS 26.4.1 Simulator
  (`/private/tmp/SvaraTF-Build2-Gate.xcresult`). The oversized story corpus was
  split into two bounded tests after the simulator test runner terminated one
  five-minute method; both bounded tests and the subsequent complete run pass.
- Release static analysis: passed.
- Signed generic iOS Release archive and cloud-managed App Store export:
  passed.
- Archive: arm64, iOS 17.0 minimum, matching dSYM, privacy manifest embedded,
  `Svara.storekit` absent, 1024×1024 source icon without alpha.
- Apple account/upload scope, signing path, and the existing App Store Connect
  record are verified. The record is Apple ID `6785557134`, immutable SKU
  `SVARA001`, English (U.S.), and bundle `com.primandir.svara`.
- App Store Connect accepted external-eligible Svara 1.0 (2) at 2026-07-30
  18:51 EDT. Processing completed; TestFlight reports `Ready to Submit` and
  binary state `Validated` with the expected bundle, team, iPhone/arm64,
  minimum iOS 17.0, symbols, entitlements, and export status.
- App Store Connect accepted external-eligible Svara 1.0 (3) at 2026-07-31
  15:03 EDT. Processing completed to `Ready to Submit`/`Ready to Test`.
- GitHub CI run `30589193485` passed the complete simulator action, Release
  analysis, and unsigned Release archive inspection for canonical commit
  `a4b57ac`; TestResults and ReleaseArchiveInspection artifacts are retained.
- Per `DEC-010`, all prior TestFlight groups were intentionally removed on
  2026-08-02 while App Store Connect users were preserved. Per `DEC-011`, four
  empty replacements now exist: internal `internal_family` and
  `internal_family_and_friends`, plus external `external_family` and
  `external_family_and_friends`. The internal groups use manual distribution.
  No group has a tester or build; builds 1.0 (2) and 1.0 (3) remain unassigned;
  no public link is enabled; and no external review submission was made. The
  approved friend's Svara-only Marketing invitation remains pending acceptance.
  See `../quality/evidence/testflight/GROUP-CREATION-2026-08-02.md`.
- Comprehensive simulator UI audit: all app-owned workflow families traversed;
  13-test consolidated run passed with 8 ordinary passes, 4 expected product
  failures, one StoreKit environment skip, and no unexpected failures. Small
  iPhone dark/maximum-text coverage passed. Separate corpus runs passed all
  eight festival workflows, all seven stories, and all 21 symbol sheets. See
  `../quality/evidence/UI-WORKFLOW-AUDIT-2026-07-30.md`.
- Free-mode focused verification: 8/8 tests passed for the feature-flag
  invariant, all lesson variants, formerly paid lesson access from Learn and
  Today, absence of Plus from Profile/Settings, and dark/maximum-text
  navigation on iPhone 17 Pro iOS 26.4.1 Simulator
  (`/private/tmp/SvaraFreeMode-20260730.xcresult`). The complete unit suite
  passed 134/134 (`/private/tmp/SvaraFreeMode-UnitTests-20260730.xcresult`).

## Verification pending

- Owner legal approval, physical in-app link verification, and App
  Store/TestFlight metadata completion (`TF-006`, `TF-008`) before
  close-friends invitations. The corrected Pages deployment is live.
- Explicit owner approval of group membership and build allocation; designation
  of one existing internal group as the owner-only TF-015 group; attachment of
  build 3 only; and the owner TestFlight installation and smoke (`TF-015`).
- Acceptance of the pending Svara-only App Store Connect invitation. Do not add
  that user to any TestFlight group until the replacement cohort design is
  recorded and approved.
- StoreKit setup/validation (`TF-005`, `TF-012`) is deferred while Plus is
  disabled. Beta operations and external rollout (`TF-013`, `TF-014`) are active.
- Physical-device matrix, StoreKit sandbox, VoiceOver, and maximum Dynamic Type.
- Physical-device verification of `UI-006`, `UI-007`, and hardened `UI-014`.
  Commerce-only `UI-004`, `UI-011`, and `UI-012` remain deferred while Plus is
  disabled.
- `UI-015` build 3 device verification: install the replacement through
  TestFlight and confirm audible output on the owner iPhone. Build 2 must not
  be used to close TF-015.

## Human review required before external distribution

- Cultural/theological sign-off for all shipped content.
- Provenance, performer consent, and distribution rights for every audio asset.

## Blockers

See `docs/BUGS.md` and `docs/RELEASE_CHECKLIST.md`.

## Canonical execution state

The complete dependency-ordered state is in `docs/TESTFLIGHT_TASKS.md`.
Detailed, lower-model-safe instructions are under `docs/tasks/testflight/`.
Jira and Notion are non-authoritative mirrors.

## Next action

Record the membership and build-allocation decision, designate one existing
internal group as owner-only, add only the owner, attach build 3 only, install
it through TestFlight, and run the TF-015 onboarding, practice, lesson, audio,
relaunch, notification, and legal-link smoke.
Before inviting close friends, finish the human content/audio sign-off, live
legal-page check, physical-device accessibility/audio/notification matrix, and
TestFlight App Review.
