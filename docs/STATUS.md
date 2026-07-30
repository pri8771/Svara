# Project Status

## Lifecycle status

`verification_pending`

## Current objective

Prepare Svara 1.0 (build 2) for an owner TestFlight smoke followed by an
invitation-only close-friends external beta under App Factory standard 0.4.0.
The public App Store release and monetization remain deferred. Build 2 is
external-eligible and must not be marked TestFlight Internal Only.
Per `DEC-006`, this testing build makes every content item free and exposes no
Svara Plus or purchase UI.

## Code complete

- Local-first onboarding and profile with no account wall.
- Today, Learn, Festivals, Stories, Profile, reminders, audio, and local progress.
- Dormant StoreKit 2 purchase/restore implementation retained behind the
  disabled `plusTierEnabled` flag for a future monetized build.
- Privacy manifest, hosted legal/support pages, App Store metadata, CI, unit
  tests, and UI smoke tests.

## Verified locally

- App Factory registration verifier: passed at standard 0.4.0.
- Exact build 2 candidate gate: 153 passed, 0 failed, 0 skipped, and 0 expected
  failures on iPhone 17 Pro, iOS 26.4.1 Simulator
  (`/private/tmp/SvaraTF-Build2-Gate.xcresult`). The oversized story corpus was
  split into two bounded tests after the simulator test runner terminated one
  five-minute method; both bounded tests and the subsequent complete run pass.
- Release static analysis: passed.
- Unsigned generic iOS Release archive: passed with product validation.
- Archive: arm64, iOS 17.0 minimum, matching dSYM, privacy manifest embedded,
  `Svara.storekit` absent, 1024×1024 source icon without alpha.
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

- Apple membership/roles, signing, and App Store record (`TF-002`–`TF-004`).
- Deployment of legal/support pages and App Store/TestFlight metadata
  (`TF-006`, `TF-008`) before close-friends invitations.
- Final gates on the exact release commit and signed upload
  (`TF-009`, `TF-011`).
- Owner-only TestFlight installation and smoke (`TF-015`).
- StoreKit setup/validation (`TF-005`, `TF-012`) is deferred while Plus is
  disabled. Beta operations and external rollout (`TF-013`, `TF-014`) are active.
- Signed distribution archive and App Store Connect upload.
- Physical-device matrix, StoreKit sandbox, VoiceOver, and maximum Dynamic Type.
- Physical-device verification of `UI-006`, `UI-007`, and hardened `UI-014`.
  Commerce-only `UI-004`, `UI-011`, and `UI-012` remain deferred while Plus is
  disabled.

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

Complete the final full simulator run, Release analysis, signed archive, and
App Store Connect upload for build 2. Then run the owner’s TestFlight smoke.
Before inviting close friends, finish the human content/audio sign-off, live
legal-page check, physical-device accessibility/audio/notification matrix, and
TestFlight App Review.
