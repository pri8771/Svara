# TF-011 — Produce, Validate, Upload, and Process the Signed Build

- **Status:** `blocked`
- **Current state:** build 1.0 (2) remains processed historical evidence, but
  its incompatible audio encoding failed owner device evaluation. Build 1.0
  (3) must complete TF-009 before archive, validation, and upload.
- **Gate:** TestFlight upload
- **Execution type:** hybrid
- **Owner:** release owner
- **Dependencies:** TF-003, TF-004, TF-009

## Objective

Create the signed archive from the verified final source, upload it to the
correct App Store Connect record, and prove Apple's processing completed
without unresolved warnings.

## Task description

**Summary:** Turn the verified source commit into the exact signed build Apple
processes for TestFlight. **User story:** As the owner and later close-friends
testers, we want
to install a build that is demonstrably derived from the QA-approved commit,
signed for the intended app, and accepted by Apple. We perform a clean preflight,
archive, validate, upload once, wait for terminal processing, and inspect the
result. This task is intentionally controlled because a different commit or
reused build number breaks all prior evidence.
**Expected change:** Apple reports the one validated, signed build 3 candidate
as fully processed, eligible for the owner’s TF-015 smoke and later external
review, and tied to the frozen source/build evidence.

## Subtask plan

### TF-011.1 — Run signed-build preflight

**Description:** As the release owner, I need to prevent the wrong source or
identity from entering Organizer. On a clean checkout/worktree of the TF-009
commit, record SHA/status, rerun its fast repository checks, compare version,
unused build number, bundle ID, team, App Store record, signing state, and
dependencies. Confirm the distribution method remains external-eligible and is
**not** TestFlight Internal Only. The expected change is a signed preflight
checklist. Stop on any dirty
or mismatched source, used build number, failed dependency, or wrong team.

### TF-011.2 — Create and identify the signed archive

**Description:** As Apple’s upload pipeline, I need one fresh Release archive
for generic arm64 iOS. In Xcode select **Any iOS Device (arm64)**, archive once,
and identify the new archive by creation time. In Organizer verify app name,
version/build, bundle ID, team, icon, size, and absence of unexpected
extensions. Cross-check archive UUID/content against TF-009 expectations. The
expected change is one correctly identified signed archive; never reuse an older
look-alike archive.

### TF-011.3 — Validate the archive

**Description:** As the uploader, I need Apple/Xcode validation before network
submission. Choose App Store Connect distribution with approved automatic/cloud
or manual signing, run validation, and record all errors/warnings. Resolve every
error and investigate privacy, signing, entitlement, SDK, export, and IAP
warnings; do not click through unexplained warnings. The expected change is a successful
validation report tied to the archive. A rebuild requires a new archive and
revalidation.

### TF-011.4 — Upload exactly once

**Description:** As App Store Connect, I need a single intentional upload to the
correct record. Reconfirm target record and distribution option, start upload,
wait for Xcode’s confirmed upload result, and record timestamp/archive/build.
Do not retry while the first upload may still be accepted or processing. The
expected change is Apple’s upload confirmation for the unique build number;
uncertain
network state is resolved by checking App Store Connect before any retry.

### TF-011.5 — Wait for and resolve processing

**Description:** As TF-012, I need Apple’s processed/thinned build, not upload
success alone. In App Store Connect monitor the candidate: wait during
`Processing`, inspect action-required/compliance prompts, and stop on `Failed`.
If processing exceeds 24 hours, follow Apple support guidance rather than
uploading duplicates. A binary fix requires a new build number and invalidated
gates. The expected change is status `Complete` with no missing compliance action.

### TF-011.6 — Inspect Apple build metadata and close

**Description:** As internal QA, I need proof Apple processed the intended
private artifact. Inspect displayed bundle/version/build, supported devices/OS,
sizes, SDK/privacy/export warnings, and external eligibility. Compare size
with the local archive, record a safe build reference, complete TF-011 evidence,
and update task/status/checklist. Mark `done` only when all fields match and the
build can be attached to TF-015. The expected change is a processed
processed build record for TF-015 and TF-014. Stop on any metadata mismatch,
warning requiring action, or accidental Internal Only restriction.

## Preconditions

- All dependencies are `done`.
- Final repository commit SHA is recorded and CI is green.
- Marketing version is `1.0`.
- Build number is unused for `1.0`. If build `1` already exists in App Store
  Connect, increment before building; an uploaded build number is not reused.
- DEC-005 authorizes the owner smoke and invitation-only close-friends beta.
- Distribution mode is external-eligible; **TestFlight Internal Only is off**.

## Procedure

1. On a clean checkout of the final commit, run the fast repository checks from
   TF-009.
2. In Xcode select **Any iOS Device (arm64)** and Product → Archive.
3. In Organizer select the new archive. Confirm:
   - Svara 1.0 (`<approved build>`);
   - bundle `com.primandir.svara`;
   - team `796XH483R4`;
   - expected icon and size;
   - no unexpected extension or entitlement.
4. Choose **Distribute App → App Store Connect → Upload**, leave **TestFlight
   Internal Only** off, and use automatic signing/cloud management unless
   DEC-005 approves manual signing.
5. Run Xcode validation. Resolve every error. Record warnings and why each is
   acceptable; do not ignore privacy/IAP/signing warnings.
6. Upload once. Do not repeatedly resubmit while Apple is processing.
7. In App Store Connect → TestFlight/Build Uploads, wait for status:
   - `Processing`: wait; if over 24 hours follow Apple support guidance;
   - `Failed`: inspect errors, fix, increment/rebuild if a new binary is needed;
   - `Complete`: continue.
8. Inspect Apple's build metadata, supported devices, OS, app thinning sizes,
   export state, and warning badge.
9. Attach the uploaded build to the correct Svara record only.

## Post-upload verification

- Bundle ID/version/build match.
- Processing is `Complete`.
- No missing compliance action.
- No unexpected SDK, tracking domain, entitlement, or privacy warning.
- Build size is reasonable compared with the 14 MB local archive.
- Build is external-eligible and available for TF-015.

## Acceptance criteria

- [x] Signed archive comes from recorded final commit.
- [x] Xcode/App Store Connect validation passes.
- [x] Upload succeeds.
- [x] Apple processing reaches the terminal `Ready to Submit` state.
- [x] Build metadata is inspected and clean.
- [x] Exact build number and App Store Connect build link/reference are recorded.
- [x] Evidence exists at `quality/evidence/testflight/TF-011.md`.
- [x] Evidence states the build is external-eligible but cannot be invited
  externally until TF-014 dependencies and TestFlight App Review complete.

## Security

Do not commit archives, `.ipa`, certificates, private keys, profiles, Apple
credentials, session cookies, API keys, or 2FA codes.

## Apple sources

- https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
- https://developer.apple.com/help/app-store-connect/reference/app-uploads/build-upload-statuses/
- https://developer.apple.com/help/app-store-connect/manage-builds/view-builds-and-metadata/
