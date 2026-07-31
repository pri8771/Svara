# TF-015 — Run One-Owner Internal TestFlight Smoke

- **Status:** `blocked`
- **Blocker:** build 2 failed local physical-device audio evaluation; build 3
  must pass TF-009 and TF-011 before the owner installs it through TestFlight
  and repeats the bounded smoke
- **Gate:** active owner-only internal TestFlight milestone
- **Execution type:** hybrid; App Store Connect setup plus physical-device test
- **Owner:** product/release owner
- **Dependencies:** TF-011

## Objective

Install Apple’s processed external-eligible Svara build through TestFlight on the
owner’s iPhone and prove the bounded private smoke path works. This task does
not approve external distribution, commerce, cultural content, audio rights,
legal surfaces, accessibility coverage, or public App Store release.

## Task description

**Summary:** Deliver one processed Svara build to the sole owner through
internal TestFlight and record a focused installation and core-workflow smoke
test. **User story:** As the app owner, I want to install the real Apple-
processed package on my iPhone so I can evaluate the current app privately
without waiting for external-release work. We create a one-person internal
group, attach only the TF-011 build, install through TestFlight, and exercise
the smallest representative workflow. This is useful because it validates
signing, processing, packaging, installation, persistence, and bundled assets
while preserving every unresolved external gate. **Expected change:** The sole
owner can install the recorded build through TestFlight and complete the
bounded smoke with no crash or missing required asset. Follow the ordered
subtasks, record sanitized evidence, and stop before adding another tester,
enabling a public link, testing real commerce, or calling the build externally
ready.

## Subtask plan

### TF-015.1 — Verify the sole internal tester and group

**Description:** As the release owner, I need distribution constrained to my
authorized App Store Connect user. Confirm the owner has access to Svara and is
eligible as an internal tester, then create or reuse the exact internal group
recorded in DEC-005. Record the group name, tester count `1`, safe Apple role,
and public-link state without copying the owner’s email or Apple Account. Do
not add friends, clients, or external addresses. The expected change is one
private internal group containing only the owner; stop if the account lacks app
access or the group contains any unapproved tester.

### TF-015.2 — Attach the processed external-eligible build

**Description:** As the sole tester, I need the group to point to the exact
processed TF-011 artifact. Confirm the build’s bundle ID, marketing version,
build number, processing status `Complete`, and external eligibility;
attach it to the owner group and enter bounded What to Test instructions for
installation, onboarding, practice, lesson, audio, relaunch persistence, and
notification prompt behavior. Save and reload the group to verify the build is
attached. The expected change is one owner group linked to exactly one
processed build; stop on a mismatch, warning requiring action,
or second attached candidate.

### TF-015.3 — Install exclusively through TestFlight

**Description:** As the owner, I need proof that Apple’s distributed package,
not an Xcode installation, reaches the device. On one physical supported
iPhone, open TestFlight with the authorized account, accept or open the
internal build, install it, and launch it from the TestFlight/App icon. Record
device model, iOS version, TestFlight version, Svara version/build, install
timestamp, and observed launch result without recording account identifiers.
The expected change is a successful TestFlight installation and first launch
of the exact TF-011 build; stop on unavailable build, install failure, crash,
wrong version, or an unexpected login wall.

### TF-015.4 — Run the bounded owner smoke

**Description:** As the owner evaluating the private build, I need fast proof
that core packaged behavior survived distribution. From a fresh app state,
complete onboarding, open Today and Learn, finish one practice and one lesson,
play and pause at least one bundled recording, relaunch, confirm progress and
profile persistence, and exercise the notification permission prompt without
requiring actual scheduled delivery. Observe the paywall only for crash/error
reporting; product loading, purchase, restore, renewal, and entitlement
lifecycle are explicitly deferred to TF-005/TF-012 and are not pass/fail
criteria here. The expected change is a timestamped expected-versus-actual
smoke matrix with no crash, missing required audio/resource, lost core
progress, or blocked primary flow. File any failure against the exact build and
stop before broadening scope.

### TF-015.5 — Record issues and close the private milestone

**Description:** As the release coordinator, I need an honest private-build
result that cannot be mistaken for external approval. Reconcile every smoke row
and issue, record the build/device evidence, update TF-015 in this file and the
register, and update status/handoff/release checklist. Mark `done` only when
TF-015.1–TF-015.4 pass and no blocker prevents the owner from using the build.
Keep TF-005–TF-008, TF-010, and TF-012–TF-014 open, and explicitly state that
audio/content rights, cultural review, commerce, legal verification, full
device QA, and external review remain unresolved. The expected change is a
closed owner-only internal smoke record at
`quality/evidence/testflight/TF-015.md`; never label it external TestFlight or
App Store readiness.

## Inputs

- `docs/DECISIONS.md` (`DEC-005`)
- `quality/evidence/testflight/TF-011.md`
- `AppStore/metadata.md` (`What to Test`)
- `docs/BUGS.md`
- `docs/RISKS.md`
- `docs/TEST_PLAN.md`

## Procedure

1. Confirm TF-011 is `done` and Apple reports the exact build `Complete`.
2. Create or verify one internal group with only the owner’s authorized App
   Store Connect user.
3. Attach only the TF-011 build and save bounded What to Test instructions.
4. Install the build through TestFlight on one supported physical iPhone.
5. Execute the TF-015.4 matrix and record expected/actual results.
6. File reproducible issues with version/build/device/OS and screenshots or
   logs when safe.
7. Update repository evidence and status before any external mirror.

## Acceptance criteria

- [x] One internal group contains only the owner.
- [x] Exactly one processed TF-011 build is attached.
- [ ] The recorded build installs and launches through TestFlight.
- [ ] Onboarding, one practice, one lesson, one audio playback, relaunch
  persistence, and the notification permission path complete without a blocker.
- [x] Partial evidence exists at `quality/evidence/testflight/TF-015.md`.
- [x] Deferred external, rights, cultural, commerce, legal, and QA gates remain
  visibly open.

## Explicit exclusions

- No external tester, invitation, or public link.
- No claim that audio/content is rights-cleared or culturally approved.
- No required IAP product loading, purchase, restore, or lifecycle testing.
- No TestFlight App Review submission.
- No public App Store submission or release approval.

## Failure handling

Record the failure against the exact build. A binary or bundled-resource fix
requires a new build number and rerun of invalidated TF-009, TF-011, and TF-015
evidence. Apple-account/group configuration errors may be corrected without a
new binary, but must be reverified after save/reload.

## Apple source

- https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers/
