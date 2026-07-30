# TF-009 — Harden and Rerun Final Automated Release Gates

- **Status:** `done`
- **Blocker:** none
- **Gate:** upload
- **Execution type:** agent
- **Owner:** engineering/QA
- **Dependencies:** TF-001

## Objective

Run every declared Factory suite against the exact external-eligible build 2
source commit and produce durable evidence. Prior results are a baseline only;
any subsequent binary/content change requires a new run.

## Task description

**Summary:** Freeze the build 2 candidate and reproduce every automated Factory
gate on that exact source and build identity. **User story:** As the release
owner, I want durable automated evidence tied to one commit so an old passing
test run cannot be mistaken for proof about a changed binary. We validate
repository configuration, run tests and analysis, inspect a fresh archive,
harden CI, and record exact artifacts. This is the engineering gate before
manual QA and signing; any source/binary change invalidates it.
**Expected change:** One frozen external-eligible commit and build identity has
passing repository checks, tests, Release analysis, archive inspection, CI, and
durable evidence; later external-scope changes invalidate it.

## Subtask plan

### TF-009.1 — Freeze the candidate identity and environment

**Description:** As QA, I need an unambiguous candidate. Ensure the worktree
contains only intended release changes without discarding user work, record
branch, commit SHA, status, Xcode/macOS version, selected simulator/runtime,
marketing version, and proposed build number. Check App Store Connect to ensure
the build number is unused; increment it consistently if needed. The expected change is
a candidate header in TF-009 evidence. Stop if the tree cannot be cleanly
identified or upstream task output is not in the commit.

### TF-009.2 — Run repository and configuration gates

**Description:** As the Factory standard, I need machine-readable project and
release files to be structurally sound. Run the exact repository commands in
this file: current Factory verifier, JSON parsing/schema checks when tooling is
available, `git diff --check`, privacy plist lint, scheme XML validation,
metadata-length checks, and scans for credentials, test fixtures, trial claims,
staging endpoints, fake login, and developer copy. Record command, exit status,
and relevant output. Fix failures and rerun; never waive silently. The expected
change is a zero-failure configuration-gate record tied to the frozen commit.

### TF-009.3 — Run the complete automated test action

**Description:** As a beta user, I need all declared unit, integration, and UI
smoke behavior verified on the frozen commit. Query available destinations,
select an installed current large iPhone, remove or choose a unique result path,
run the full `xcodebuild test` command with signing disabled, and extract the
summary using `xcresulttool`. Record executed/passed/failed/skipped counts and
artifact location. Any failure or unexpected skip blocks the task and must be
reproduced/fixed before a full rerun. The expected change is a complete `.xcresult` and
recorded test summary for the frozen candidate.

### TF-009.4 — Run Release static analysis

**Description:** As engineering, I need compiler/analyzer findings from the
shipping configuration rather than Debug only. Run `xcodebuild analyze` for
Release and generic iOS with signing disabled, retain the log, and inspect every
warning/error. Fix in-scope issues or record a formally approved waiver under
`quality/waivers/`; a warning is not accepted merely because the command exits
zero. The expected change is a clean or explicitly governed Release analysis result.
Stop on any unresolved error, warning, or unapproved waiver.

### TF-009.5 — Create and inspect a fresh Release archive

**Description:** As TF-011, I need a production-shaped archive whose contents
match requirements. Archive to a new explicit path, then verify bundle ID,
version/build, arm64, minimum iOS, app/dSYM UUID match, icon properties, privacy
manifest, expected audio/resources, export flag, and absence of `.storekit`,
preview data, credentials, test bundles, staging endpoints, and developer copy.
Record commands and inspection output. Any unexpected file or mismatch blocks
the task. The expected change is a fresh production-shaped archive whose
identity, resources, symbols, and exclusions match every documented check.

### TF-009.6 — Harden and verify CI

**Description:** As future maintainers, we need the same release failures caught
on every commit. Update `.github/workflows/ci.yml` to select an available
simulator, run the full tests and Release analysis, build an unsigned Release
archive, assert privacy presence/StoreKit absence, and upload `.xcresult` plus
inspection text. Preserve existing workflow behavior and avoid unavailable
hard-coded devices. Push/observe CI only through the approved workflow and
record the green run URL; local success alone does not complete this subtask.
The expected change is a green release-capable CI run and retained artifacts.

### TF-009.7 — Assemble final evidence and freeze downstream

**Description:** As TF-011/TF-015, I need one go/no-go record. Confirm all
artifacts reference the same commit/version/build, summarize counts and archive
findings, list checks not run, and update task/status/checklist/completion
report. Mark `done` only when repository checks, tests, analysis, archive, and
CI pass. Add a clear invalidation note: any later binary/content/config change
returns TF-009 to `verification_pending`. The expected change is one final automated
go/no-go record consumed by TF-011 and TF-015. It is not external-release
evidence after deferred content, commerce, metadata, legal, or QA changes.

## Precondition

The worktree must contain only the intended release changes. Record:

```sh
git branch --show-current
git rev-parse HEAD
git status --short
```

Do not discard unrelated changes. Decide and document whether build `1` is still
unused in App Store Connect; if it already exists, increment
`CURRENT_PROJECT_VERSION` in every app configuration before archiving.

## Repository checks

```sh
bash /path/to/iOS_app_factory_rules/scripts/verify-project-registration.sh .
git diff --check
plutil -lint Svara/Resources/PrivacyInfo.xcprivacy
xmllint --noout Svara.xcodeproj/xcshareddata/xcschemes/Svara.xcscheme
for f in .factory/*.json quality/*.json \
  quality/feature-contracts/*.json quality/completion-reports/*.json; do
  python3 -m json.tool "$f" >/dev/null
done
```

Verify metadata limits programmatically and scan the Release binary/source for
credential forms, developer-only StoreKit copy, trial claims, and stale legal
copy.

## Xcode checks

1. List destinations and choose an actually available current large iPhone:

```sh
xcodebuild -showdestinations -project Svara.xcodeproj -scheme Svara
```

2. Run the full test action and save `.xcresult`:

```sh
xcodebuild test -project Svara.xcodeproj -scheme Svara \
  -destination 'platform=iOS Simulator,name=<large iPhone>,OS=<version>' \
  CODE_SIGNING_ALLOWED=NO \
  -resultBundlePath /safe/path/SvaraTests.xcresult
```

3. Extract counts:

```sh
xcrun xcresulttool get test-results summary \
  --path /safe/path/SvaraTests.xcresult
```

4. Run Release analysis:

```sh
xcodebuild analyze -project Svara.xcodeproj -scheme Svara \
  -configuration Release -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO
```

5. Create a fresh unsigned archive with a unique path, then inspect:
   bundle/version/build, arm64, minimum iOS, matching dSYM UUID, app icon,
   privacy manifest, audio, export flag, and absence of `.storekit`, preview
   content, credentials, staging endpoints, and developer copy.

## CI hardening subtask

Update `.github/workflows/ci.yml` so CI also:

- runs Release static analysis;
- creates an unsigned Release archive;
- asserts `PrivacyInfo.xcprivacy` is present and `.storekit` is absent;
- uploads `.xcresult` and archive-inspection text on every run.

Do not hard-code a simulator name unavailable on the selected GitHub runner.
Select from `simctl` and print the selected runtime/device.

## Acceptance criteria

- [x] Final factory/repository checks pass.
- [x] Full test suite has zero failures/skips; count recorded.
- [x] Release analysis passes.
- [x] Fresh archive inspection passes.
- [x] CI contains all required manifest suites and is green for the final
  binary/canonical state.
- [x] Evidence uses the final binary commit/build number.
- [x] `quality/evidence/testflight/TF-009.md` exists.

## Failure handling

Fix failures in scope, rerun the failed check and all invalidated downstream
checks, and never copy earlier counts to a new commit.
