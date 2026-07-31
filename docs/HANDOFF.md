# Handoff

## What the project is

Svara is a local-first iPhone app for brief Hindu spiritual-wellness practice,
learning, festival context, stories, and gentle progress.

## Current state

The implementation is targeting an external-eligible build 3 replacement, owner
TestFlight smoke, and invitation-only close-friends beta after Apple review.
Factory registration and current quality state live in `.factory/`,
`quality/`, `docs/STATUS.md`, and the canonical
`docs/TESTFLIGHT_TASKS.md`. Apple account scope, cloud-managed signing, and
the existing record (Apple ID `6785557134`) are verified. Build 1.0 (2) was
uploaded as external-eligible and processed, but its bundled MP3 encoding
failed physical-device audio evaluation. Build 3 replaces those recordings
with AAC-in-M4A and changes Today audio to start on Begin. Per
`DEC-006`, every content item is free
and Plus/paywall/membership UI is hidden in the current testing configuration.
Current build 3 source also explains Svara Points in Today/Profile: points unlock
private 100/250/500-point achievement badges and never gate content.
Dormant StoreKit commerce is deferred. Deployed legal pages, content review,
audio rights, and full physical-device QA remain required before friend
invitations, although the owner may complete TF-015 first.

The 2026-07-30 comprehensive simulator UI audit traversed the shipped workflow
families. Its active product findings were remediated; new build 3 evidence
and remaining human audio/notification/accessibility checks govern release
status. Read `quality/evidence/UI-WORKFLOW-AUDIT-2026-07-30.md`.

## Build and run

Open `Svara.xcodeproj` in Xcode 16+ and select the shared `Svara` scheme. The
scheme retains a dormant `Svara/Resources/Svara.storekit` reference for future
purchase testing; `FeatureFlags.current.plusTierEnabled` is currently `false`.
No package installation or backend setup is required.

## Important constraints

- iOS 17+, iPhone target.
- Local-first; no backend, analytics, ads, or tracking.
- No third-party dependencies.
- All content is free in the current owner-testing configuration.
- If Plus is later re-enabled, StoreKit is the only premium entitlement authority.
- `ProductGuardrails.md` is binding for content and product behavior.
- Jira and Notion are copies only. Update the repository task, evidence, status,
  and commit reference first.

## Known issues

See `docs/BUGS.md`.

## Next recommended task

Complete build 3 TF-009/TF-011, replace the owner-group build, then install it
through TestFlight and run the remaining TF-015 smoke. Close friends remain gated
by TF-006–TF-008,
TF-010, TF-013, and TF-014.
