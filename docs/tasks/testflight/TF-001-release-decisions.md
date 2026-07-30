# TF-001 — Lock Release Decisions and Owners

- **Status:** `done`
- **Gate:** active owner-only milestone and all deferred downstream work
- **Execution type:** human decision with agent documentation
- **Owner:** product/release owner
- **Dependencies:** none
- **Current blocker:** TF-001.2 requires the authorized owner to complete the
  remaining owner-decision rows at `quality/evidence/testflight/TF-001.md`.

## Objective

Resolve every product, commercial, and ownership choice that an implementation
agent must not guess. Record decisions in the repository before configuring
Apple systems.

## Task description

**Summary:** Establish one owner-approved configuration for the active private
internal build and explicitly defer every external/commercial choice. **User story:**
As the sole owner/tester, I want the minimum identity, scope, and
ownership decisions recorded so agents can upload one private build without
pretending external-release work is complete. We are converting the applicable
worksheet rows into `DEC-005`, attaching named deferrals to TF-005–TF-008 and
TF-010–TF-014, and reconciling only the active internal path. This is first
because an incorrect SKU, app identity, build scope, or operator can create an
irreversible Apple record or upload the wrong app. The executor must collect
explicit answers, quote the decision source in sanitized evidence, update the
listed files, and stop on any unanswered internal-path choice.
**Expected change:** One owner-approved internal-only `DEC-005`, a complete private-build
ownership map, and explicit blockers on every deferred external surface.

## Subtask plan

### TF-001.1 — Build the decision worksheet

**Description:** As the product/release owner, I need one complete question set
so no choice is hidden across code and metadata. The executor reads every file
under **Inputs**, copies the fifteen required decisions into
`quality/evidence/testflight/TF-001.md`, and adds columns for proposed value,
approved value, approver reference, date, and affected files. Record existing
facts such as bundle ID separately from proposals such as English (U.S.). Do
not present a proposal as a default. The expected change is a worksheet containing all
fifteen rows; stop if an input file is missing or contradicts the inventory.

### TF-001.2 — Obtain explicit owner decisions

**Description:** As downstream implementers, we need approved values rather
than assumptions. Present the worksheet to the authorized owner and collect an
answer for every row: approved value, explicitly deferred value with dependent
tasks blocked, or rejected proposal with replacement. Ask follow-up questions
when an answer is not operational—for example, “worldwide” must be translated
into specific App Store territories during TF-005. Keep phone numbers, private
emails, and legal details in an approved secure record and store only its
reference. The expected change is a dated, owner-attributed decision set; stop without
inventing any unanswered value.

### TF-001.3 — Record DEC-005

**Description:** As an agent entering the project later, I need the approved
configuration in the repository’s decision log. Replace the pending DEC-005
section in `docs/DECISIONS.md` with the exact approved values, decision date,
approver role, secure-record references, and consequences. Clearly label any
deferral and list the tasks it blocks. Do not copy secrets or turn a proposal
into an accepted decision. The expected change is an internally consistent DEC-005 whose
values can be traced to TF-001 evidence.

### TF-001.4 — Reconcile every dependent source

**Description:** As a tester and reviewer, I need code, StoreKit configuration,
metadata, assumptions, and task instructions to describe the same beta. Compare
each DEC-005 value against `FeatureFlags.current`, target device family,
`Svara.storekit`, `AppStore/metadata.md`, `docs/ASSUMPTIONS.md`, and this task
register. Make only owner-authorized changes. If beta scope or StoreKit choices
require binary changes, implement them with tests or create a blocking bug and
leave TF-001 incomplete. The expected change is a reconciliation table with
match/changed/blocked for every affected source.

### TF-001.5 — Close the decision gate

**Description:** As the release coordinator, I need a reliable signal that
dependent work can start. Check every parent acceptance criterion, list
remaining deferrals, update TF-001’s status in this file and
`docs/TESTFLIGHT_TASKS.md`, and update assumptions/status/handoff. Only set
`done` when every downstream-required value is explicit and all repository
contradictions are resolved. The expected change is completed TF-001 evidence and a
reconciled task register; if any blocking value remains, keep the task
`blocked` or `in_progress` and name the owner/action needed.

## Inputs

- `ProductGuardrails.md`
- `AppStore/metadata.md`
- `Svara/Core/FeatureFlags.swift`
- `Svara/Resources/Svara.storekit`
- `docs/ASSUMPTIONS.md`

## Required decisions

For the active TF-015 milestone, rows 1, 2, 3, 5, 11, 12, 14, and 15 require
explicit owner values. Rows 4, 6–10, and 13 may be recorded as deferred with
the exact external/IAP task they block. A deferral is not approval.

1. **Beta surface:** choose either:
   - `full`: Today, Learn, Festivals, Stories, Profile; matches current
     `FeatureFlags.current` and metadata, or
   - `betaScope`: Today, Learn, Profile; requires a code change, test update,
     metadata rewrite, and new release verification.
2. **Target devices:** confirm iPhone-only is intentional. Do not promise iPad
   while `TARGETED_DEVICE_FAMILY = 1`.
3. **Primary language:** confirm the App Store Connect primary language.
   Proposed value: English (U.S.).
4. **Categories:** defer to TF-008 for external review, or approve/replace the
   proposed primary **Health & Fitness** and secondary **Education** values.
5. **SKU:** choose a stable internal SKU. It is not user-facing and cannot be
   guessed by an agent.
6. **Public App Store copyright/seller copy:** defer this non-TestFlight field
   to the public App Store release backlog. Apple requires copyright for an App
   Store version submission, not TestFlight App Review. Do not make the legal
   owner name a TF-001 or external TestFlight blocker.
7. **Commercial model:** defer live commerce to TF-005/TF-012 for this
   owner-only smoke, or confirm all three products remain monthly, yearly, and
   lifetime.
8. **Reference prices:** approve or replace USD references:
   monthly `$0.99`, yearly `$7.99`, lifetime `$19.99`. App Store Connect sets
   actual storefront price points.
9. **Introductory offer:** decide whether monthly and yearly subscriptions have
   a one-week free trial. The local StoreKit configuration currently includes
   both trials; user-facing metadata does not promise them.
10. **Availability:** defer storefront/product availability to TF-005/TF-008,
    or define intended countries/regions.
11. **Content scope:** confirm the current bundled content/audio may be viewed
    by the sole owner for private evaluation. This is a risk acknowledgment,
    not TF-007 cultural or rights approval, and never permits external access.
12. **People/roles:** assign release owner, App Store Connect operator, QA
    owner, cultural reviewer, audio-rights approver, and beta-feedback owner.
13. **App Review contact:** defer to TF-008/TF-014 while external TestFlight is
    out of scope. When resumed, keep the real name, monitored email, and
    reachable phone in App Store Connect or another secure owner record.
14. **Tester cohort:** name the one-owner internal group and confirm tester
    limit `1`; defer any external group and keep public links disabled.
15. **Stop authority:** identify who can immediately stop testing for a crash,
    data loss, entitlement error, legal-rights issue, or cultural harm report.

## Procedure

1. Present only the unresolved choices above to the owner.
2. Record accepted decisions as `DEC-005 — TestFlight release configuration` in
   `docs/DECISIONS.md`.
3. Update `docs/ASSUMPTIONS.md`; convert confirmed assumptions to decisions.
4. Reconcile `AppStore/metadata.md`, StoreKit config, feature flags, and task
   dependencies. Do not change code unless the selected option requires it.
5. Record only role labels and safe contact references in repo docs; keep
   sensitive contact/business details in the approved secure system.

## Acceptance criteria

- [ ] Every required decision has an explicit value or an explicit deferral
  that blocks its dependent task.
- [ ] `docs/DECISIONS.md` is updated.
- [ ] No StoreKit, metadata, device, or beta-scope contradiction remains.
- [ ] Owners exist for every human gate.
- [ ] Evidence exists at `quality/evidence/testflight/TF-001.md`.

## Do not

- Do not infer prices, territories, trial eligibility, SKU, phone number, or
  reviewer identity.
- Do not enable a public TestFlight link as part of this task.

## Mirror summary

Lock Svara 1.0 TestFlight scope, monetization, territories, contacts, owners,
tester cohorts, and stop authority. Source:
`docs/tasks/testflight/TF-001-release-decisions.md`.
