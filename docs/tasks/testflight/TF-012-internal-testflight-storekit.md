# TF-012 — Run Internal TestFlight and Live StoreKit Sandbox Validation

> **Current applicability:** deferred under `DEC-006`. Execute only for a
> future build that deliberately re-enables Plus after TF-005.

- **Status:** `deferred`
- **Blocker:** TF-005, TF-006, TF-007, TF-008, TF-010, and an
  external-eligible TF-011 run are not complete
- **Gate:** external TestFlight submission
- **Execution type:** hybrid
- **Owner:** QA/release owner
- **Dependencies:** TF-005, TF-006, TF-007, TF-008, TF-010, TF-011

## Objective

Install Apple's processed/thinned build through TestFlight on real devices and
validate the production App Store Connect product configuration before external
review.

## Task description

**Summary:** Validate Apple’s distributed build and live StoreKit sandbox
configuration with a controlled internal cohort. **User story:** As an external
beta candidate owner, I want internal testers to prove installation, core
workflows, prices, purchases, restore, and entitlement loss before exposing
outsiders. We configure the approved internal group, install through TestFlight,
exercise product and lifecycle scenarios, and make a documented go/no-go. This
is distinct from local StoreKit testing because Apple’s processed binary and
App Store Connect catalog are part of the system.
**Expected change:** Internal TestFlight installs, core workflows, live product
loading, purchase, cancellation/pending, restore, and entitlement lifecycle all
pass on Apple’s distributed build.

## Subtask plan

### TF-012.1 — Configure internal group and testers

**Description:** As the beta operator, I need a controlled group of authorized
App Store Connect users. Create or verify the TF-001 group name, decide
automatic/manual distribution, add only approved users with Svara access, attach
the exact TF-011 build, and enter canonical What to Test. Do not create a public
link. Record group name, sanitized tester count/roles, build, and distribution
mode. The expected change is an internal group whose members can receive the correct
build.

### TF-012.2 — Install and run distributed-build smoke

**Description:** As an internal tester, I need to prove the App Store processed
package installs and contains expected resources. Accept the invitation and
install/update through the TestFlight app, never Xcode. Record device/OS/build,
then run fresh onboarding, relaunch persistence, practice, lesson, audio,
notification, legal links, and paywall product loading. The expected change is at least
one complete smoke pass. Crash, missing assets, login prompt, or blank product
catalog blocks external progression.

### TF-012.3 — Verify live product catalog and prices

**Description:** As a purchaser, I need the three intended products with
Apple-localized terms. On the TestFlight build with network available, open the
paywall and record monthly/yearly/lifetime presence, localized display names,
prices, durations, trial disclosures/eligibility behavior, selection state, and
legal copy. Compare to TF-005/App Store Connect, not hard-coded USD assumptions.
Wrong, missing, duplicated, or stale products block the task. The expected change is a
three-product localized catalog comparison.

### TF-012.4 — Verify successful purchases

**Description:** As a tester buying each option, I need verified transactions
to unlock Plus and survive relaunch. Establish a clean transaction state or
separate sandbox accounts as needed, purchase monthly, yearly, and lifetime
independently, confirm Apple sheet/product identity, wait for verified result,
check entitlement-gated content, relaunch, and confirm transaction completion.
Never create real charges or expose account credentials. The expected change is a pass
for all three products with transaction identifiers stored only where safe.

### TF-012.5 — Verify cancellation, pending, and restore

**Description:** As a user who does not complete a purchase, I need honest
recovery states and no false unlock. Test user cancellation, pending/Ask to Buy
where supported, restore with no active purchase, and restore with a valid prior
purchase. Confirm cancellation is non-error, pending explains delay, empty
restore is informative, valid restore unlocks, and no state grants access early.
Record expected/actual and screenshots without tester PII. The expected change is a
negative-state and restore scenario matrix. Block progression on premature
entitlement, false success, or failed valid restore.

### TF-012.6 — Verify entitlement lifecycle and offline behavior

**Description:** As a subscriber after account changes, I need access to follow
current StoreKit entitlement. Use TestFlight’s accelerated renewal and Sandbox
Apple Account controls where required to test renewal, expiration, billing
failure/retry if in scope, refund, revocation, and relaunch/refresh. Record
offline launch behavior for an existing entitlement and confirm no profile flag
independently unlocks. Any sticky entitlement, access without verification, or
valid entitlement loss without recovery blocks the beta. The expected change is an
entitlement-lifecycle matrix covering online, offline, and account-change cases.

### TF-012.7 — Make internal go/no-go decision

**Description:** As the release owner, I need one evidence-backed decision.
Aggregate tester/device rows and StoreKit cases, file every failure with exact
build and reproduction, and determine whether a binary, product metadata, or
account fix is needed. Binary fixes increment the build and invalidate applicable
TF-009–TF-012 evidence. Mark `done` only when smoke, all three products, negative
states, restore, and lifecycle behavior pass with no blocker/high issue. The
expected change is the internal TestFlight go/no-go record for TF-014.

## Internal group setup

1. In App Store Connect → Svara → TestFlight, create the internal group named in
   TF-001.
2. Add only authorized App Store Connect users with Svara access.
3. Add the processed TF-011 build.
4. Enter build-level What to Test from `AppStore/metadata.md`.
5. Do not enable a public link.
6. Confirm invited users receive the invitation and install through TestFlight,
   not Xcode.

## Required testers/devices

- At least two internal testers if available.
- At least one physical iPhone.
- Prefer one device near minimum supported iOS and one current iOS/device.
- Record TestFlight version/build and device/OS.

## Install/smoke subtasks

- Fresh install and onboarding.
- No login/account prompt.
- Today practice completion and relaunch persistence.
- Lesson completion/resume and entitlement gates.
- Audio playback/interruption.
- Notification prompt/delivery.
- Legal/support links.
- No unexpected crash, missing asset, or blank StoreKit product list.

## Live StoreKit sandbox subtasks

Use a Sandbox Apple Account belonging to the same developer account where
required. Test each product independently with a clean transaction state:

1. Monthly purchase: localized price, Apple sheet, verified unlock.
2. Yearly purchase: localized price, verified unlock.
3. Lifetime purchase: one-time disclosure and persistent unlock.
4. Cancellation: no error and no entitlement.
5. Pending approval: pending message and no early entitlement.
6. Restore with no purchase: honest no-active-purchases message.
7. Restore after purchase: unlock restored.
8. Subscription renewal/expiration: access follows current entitlement.
9. Refund/revocation: access is removed after entitlement refresh/relaunch.
10. Offline launch: existing current StoreKit entitlement behavior is recorded;
    no profile flag independently unlocks access.

Apple currently accelerates TestFlight subscription renewal to daily, up to six
renewals in one week. Record this environment behavior; do not interpret it as
production duration.

## Acceptance criteria

- [ ] Internal group exists and build installs through TestFlight.
- [ ] At least one complete internal smoke run passes.
- [ ] All three live products load with approved localized prices.
- [ ] Purchase/cancel/pending/restore/expiry/refund/revocation behaviors pass.
- [ ] Entitlement remains StoreKit-authoritative.
- [ ] No blocker/high issue remains.
- [ ] Evidence exists at `quality/evidence/testflight/TF-012.md`.

## Failure handling

Stop external progression for any missing product, wrong price, sticky
entitlement, false success, crash, data loss, or legal/content mismatch. If a
binary fix is required, create a new build number and invalidate TF-009 through
TF-012 as applicable.

## Apple sources

- https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers/
- https://developer.apple.com/help/app-store-connect/test-a-beta-version/testing-subscriptions-and-in-app-purchases-in-testflight/
