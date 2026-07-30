# TF-003 — Repair Distribution Signing and Provisioning

- **Status:** `done`
- **Blocker:** none; automatic cloud-managed distribution is the approved path
- **Gate:** signed archive/upload
- **Execution type:** hybrid; account action plus local verification
- **Owner:** release owner / Apple Admin
- **Dependencies:** TF-002

## Objective

Produce a valid distribution signing path for team `796XH483R4` and explicit
bundle ID `com.primandir.svara` without revoking unrelated team credentials.

## Task description

**Summary:** Establish and prove a safe Apple Distribution signing path for the
exact Svara identity. **User story:** As the release uploader, I want Xcode to
produce a valid signed archive so Apple can authenticate the binary without
damaging anyone else’s team credentials. We are diagnosing the current zero-
identity state, preferring automatic/cloud signing, configuring only Svara, and
inspecting a signed archive. This matters because certificate revocation can
break other apps and a mismatched profile can upload the wrong identity. Follow
the ordered subtasks and stop before deleting or revoking anything.
**Expected change:** An authorized, reproducible Svara signing configuration
produces a valid archive with the intended team, bundle ID, entitlements, and
distribution profile.

## Subtask plan

### TF-003.1 — Capture the signing baseline

**Description:** As the Apple Admin, I need an exact diagnosis before changing
credentials. Run the verification commands in this file, inspect Xcode
**Settings → Accounts**, the Svara target’s Release signing settings, and the
specific installed profile errors. Record team, bundle ID, signing style,
identity count, profile names/UUID validity, and error text with secrets
redacted. The expected change is a baseline showing whether the failure is account,
certificate/private-key, profile, or build-setting related. Do not remove files
or revoke certificates during diagnosis.

### TF-003.2 — Establish an authorized distribution identity

**Description:** As the uploader, I need an Apple-approved identity with a usable
private key. First refresh the authorized Xcode account and attempt automatic
or cloud-managed signing. If local signing is required, have an Admin create or
install an Apple Distribution certificate and confirm its private key appears
in the login keychain. Re-run `security find-identity`. The expected change is either an
approved cloud-signing path or at least one valid distribution identity. Stop
and escalate before revoking, replacing, or exporting any team certificate.

### TF-003.3 — Configure Svara signing and provisioning

**Description:** As the build system, I need Release settings tied to the exact
App ID and team. Set the Svara target to team `796XH483R4`, bundle
`com.primandir.svara`, and automatic signing unless DEC-005 explicitly approves
manual signing. For manual signing, create an App Store Connect profile for the
explicit App ID and selected certificate, download it, and verify it parses.
Quarantine only a specifically proven malformed local profile after confirming
replacement. The expected change is a clean Release signing configuration; stop on any
identity mismatch.

### TF-003.4 — Produce and inspect a signed archive

**Description:** As App Store Connect, I need a correctly signed distribution
archive rather than a successful development build. Create a fresh Release
archive for a generic iOS device, locate its `.app`, run the `codesign` and
profile-inspection commands, and compare application identifier, team, bundle,
expiration, entitlements, and signing authority to the approved values. Save
only sanitized command results. The expected change is an archive that passes strict
signature verification. Any unexpected entitlement, expired profile, or
mismatch blocks completion.

### TF-003.5 — Record reproducibility and resolve REL-001

**Description:** As a future release operator, I need to know this signing path
can be repeated without stored secrets. Document the Xcode/account approach,
certificate type, profile name if manual, commands, results, and secure owner
reference in TF-003 evidence. Do not commit archives, profiles, certificates,
or keys. Check all acceptance criteria, update REL-001 and task status, and
leave the task blocked if the path works only through an unexplained one-off
state. The expected change is a sanitized, reproducible signing runbook and resolved or
precisely blocked REL-001 row.

## Current evidence

The 2026-07-29 baseline reported no local distribution identity. On
2026-07-30, Xcode automatic/cloud-managed distribution for team `796XH483R4`
successfully exported and uploaded Svara 1.0 (2) with
`testFlightInternalTestingOnly=false`. No certificate was revoked or exported.

## Preferred approach

Use Xcode automatic signing and the Organizer distribution workflow. Xcode 13+
can use cloud-managed distribution certificates when the operator has
permission. Use manual profiles only if automatic/cloud signing cannot work.

## Procedure

1. Confirm TF-002 and the correct Apple team.
2. In Xcode **Settings → Accounts**, add/select the authorized Apple Account and
   refresh/download profiles.
3. Open the Svara target **Signing & Capabilities**:
   - Bundle Identifier: `com.primandir.svara`
   - Team: the team whose ID is `796XH483R4`
   - Automatically manage signing: enabled unless an approved manual-signing
     decision exists.
4. Do not delete or revoke certificates merely because this Mac lacks one.
   Check team impact with the Account Holder first.
5. If local signing is required, create/install an **Apple Distribution**
   certificate whose private key is present in the login keychain.
6. If manual signing is approved, create an **App Store Connect** distribution
   profile for the explicit App ID and selected Apple Distribution certificate.
7. Remove or quarantine only the specifically malformed local profile files
   after resolving their exact paths and confirming they are replaceable.
8. Reopen Xcode and let it refresh signing state.

## Verification commands

```sh
security find-identity -v -p codesigning
xcodebuild -showBuildSettings \
  -project Svara.xcodeproj \
  -scheme Svara \
  -configuration Release |
  rg 'DEVELOPMENT_TEAM|PRODUCT_BUNDLE_IDENTIFIER|CODE_SIGN'
```

Then create a signed Release archive in Xcode Organizer. Inspect the archived
app:

```sh
codesign --verify --deep --strict --verbose=2 /path/to/Svara.app
codesign -d --entitlements :- /path/to/Svara.app
security cms -D -i /path/to/Svara.app/embedded.mobileprovision
```

Do not commit the archive or provisioning material.

## Acceptance criteria

- [x] At least one appropriate valid signing identity or approved cloud-signing
  path is available.
- [x] Signed archive succeeds for the correct team/bundle ID.
- [x] `codesign --verify` succeeds.
- [x] App Store Connect accepted the cloud-signed application identifier for
  `796XH483R4.com.primandir.svara`.
- [x] No unintended entitlements appear.
- [x] Sanitized evidence exists at
  `quality/evidence/testflight/TF-003.md`.

## Apple sources

- https://developer.apple.com/help/account/create-certificates/certificates-overview
- https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile
- https://developer.apple.com/help/account/certificates/cloud-managed-certificates/
