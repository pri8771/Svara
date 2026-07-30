# TF-004 — Verify or Create the App Store Connect App Record

- **Status:** `done`
- **Gate:** upload
- **Execution type:** hybrid
- **Owner:** App Manager/Admin
- **Dependencies:** TF-001, TF-002

## Objective

Ensure exactly one iOS App Store Connect record corresponds to Svara's explicit
bundle ID before uploading.

## Task description

**Summary:** Resolve Svara to one verified Apple App ID and App Store Connect
record. **User story:** As the release team, I want uploads routed to the
intended app so we do not create an irreversible duplicate or attach a build to
the wrong product. We first search both Apple systems, compare immutable
identity fields, create only what is absent, and record the resulting Apple ID.
This task precedes products and upload because bundle ID, SKU, language, and app
record choices constrain all later work.
**Expected change:** Exactly one verified App ID and one App Store Connect app
record match Svara’s approved immutable identity, with no unresolved duplicate.

## Subtask plan

### TF-004.1 — Search existing Apple records

**Description:** As the account owner, I need to know what already exists before
creation. Search App Store Connect Apps by Svara/name and inspect every plausible
record’s bundle ID, platform, Apple ID, SKU, access, and status. Separately search
Certificates, Identifiers & Profiles for `com.primandir.svara`. Record sanitized
matches and non-matches in evidence. The expected change is an inventory of existing app
records and explicit identifiers. Stop if multiple plausible records or a
mismatched record make the intended identity ambiguous.

### TF-004.2 — Validate required creation values

**Description:** As the App Manager, I need every one-time creation value
approved before submitting the form. Copy platform, name, team, bundle ID,
primary language, SKU, and user access from TF-001/TF-002 into a preflight
table, then compare the bundle ID to Xcode Release settings. No field may be
blank or proposed. The expected change is a reviewed creation payload. Stop rather than
choosing a new SKU, name, language, or access mode.

### TF-004.3 — Create only missing records

**Description:** As the product owner, I need one Apple identity, not duplicates.
If the explicit App ID is absent, an authorized Admin creates it with the exact
bundle ID. If the App Store record is absent, create it once using the preflight
payload and latest accepted agreement. If both exist, make no creation call.
The expected change is exactly one explicit App ID and one iOS app record. Any Apple name
conflict or validation error is escalated without changing identity.

### TF-004.4 — Verify resulting identity

**Description:** As the upload task, I need an independently verified target.
Reload App Information and compare Apple ID, bundle ID, team, platform, SKU,
language, access, and displayed name against the repository and Xcode. Record
the numeric Apple ID and safe App Store Connect reference. The expected change is a
field-by-field match; an app status alone is not proof. Stop on any mismatched
immutable identity field.

### TF-004.5 — Reconcile repository and close ASM-001

**Description:** As future agents, we need confirmed Apple facts in the repo.
Update `AppStore/metadata.md` with the safe confirmed identifiers, change
ASM-001 from assumption to resolved evidence, complete TF-004 evidence, and
update task/checklist/status files. Mark `done` only when exactly one correct
record exists and no duplicate remains unresolved. The expected change is the confirmed
repository identity record and closed ASM-001.

## Required values

- Platform: iOS
- Name: Svara
- Bundle ID: `com.primandir.svara`
- Team: `796XH483R4`
- Primary language: TF-001 decision
- SKU: TF-001 decision
- User access: TF-001/TF-002 decision

## Procedure

1. Search App Store Connect **Apps** for an existing Svara record.
2. Open candidates and compare bundle ID. Do not create a duplicate if a record
   already uses `com.primandir.svara`.
3. In Apple Developer **Certificates, Identifiers & Profiles → Identifiers**,
   verify an explicit App ID exists for the bundle ID.
4. If no app record exists, create one using **Apps → + → New App** with the
   required values. The latest agreement must already be accepted.
5. Record the Apple ID (numeric app identifier), SKU, primary language, and
   access mode in repository evidence. The Apple ID is safe to record; do not
   record account credentials.
6. Confirm App Information displays the intended bundle ID and app name.
7. Update `docs/ASSUMPTIONS.md` for ASM-001 and add the confirmed record facts
   to `AppStore/metadata.md`.

## Verification

- App record status is visible (normally **Prepare for Submission** before a
  first public version).
- Bundle ID exactly matches the built archive.
- No other Svara record on the team uses the same intended identity.

## Acceptance criteria

- [x] Exactly one correct app record exists.
- [x] Explicit App ID exists.
- [x] Apple ID, SKU, language, and access are documented.
- [x] ASM-001 is resolved.
- [x] Evidence exists at `quality/evidence/testflight/TF-004.md`.

## Failure handling

If the name is unavailable or a mismatched record exists, stop and escalate to
the owner. Do not change the product name or bundle ID without TF-001 and a new
decision record.

## Apple source

https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/
