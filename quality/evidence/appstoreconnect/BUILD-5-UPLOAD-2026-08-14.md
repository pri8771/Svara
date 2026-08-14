# Build 5 signed archive and upload — 2026-08-14

## Outcome

Status: uploaded; Apple processing/Ready-to-Test confirmation pending human
verification in App Store Connect (not checked from this session — no
authenticated App Store Connect session was available here).

Build 1.0 (4), uploaded 2026-08-13, predated the Om-chant and Saraswati-mantra
audio fixes recorded in commit `1e69d00`. This build supersedes it with the
same source tree plus that fix, cut from `dev` at `1e69d00`.

## Steps and results

- Source: branch `dev` at `1e69d00` (Replace Om practice bed with plain breath
  chant; give Saraswati mantra its own audio — CNT-001/CNT-002), no
  working-tree changes except the build-number bump described below.
- Pre-flight unit tests: `xcodebuild test -scheme Svara -only-testing:SvaraTests`
  on iPhone 17 Pro Simulator → **143/143 passed**, 0 failures
  (`/private/tmp/svara-build/SvaraTests-1e69d00.xcresult`).
- Build number: `CURRENT_PROJECT_VERSION` bumped from `4` to `5` for the
  `Svara` app target only (`Svara.xcodeproj/project.pbxproj`, configurations
  `AA000000000000000000000E`/`F`); `MARKETING_VERSION` remains `1.0`. The
  `SvaraTests`/`SvaraUITests` target configurations were left untouched, as in
  prior builds.
- Archive: `xcodebuild archive -project Svara.xcodeproj -scheme Svara
  -destination "generic/platform=iOS" -allowProvisioningUpdates
  CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=796XH483R4`
  → `** ARCHIVE SUCCEEDED **` at `/private/tmp/svara-build/Svara-1.0-5.xcarchive`.
- Archive contents verified: `CFBundleVersion` = `5`, `CFBundleShortVersionString`
  = `1.0`; no `.mp3` files present; `mantra_om.m4a` and
  `mantra_saraswati_aim.m4a` both present in the bundled app (confirming the
  audio fix shipped in this archive); matching `Svara.app.dSYM` generated.
- Upload: `xcodebuild -exportArchive` with an app-store-connect/upload export
  options plist (automatic signing, team `796XH483R4`, `uploadSymbols` true)
  → `Upload succeeded` / `** EXPORT SUCCEEDED **` at 2026-08-14 18:31 local.

## Remaining verification (not performed in this session)

- Confirm App Store Connect finishes processing build 1.0 (5) and records it
  as Ready to Submit / Ready to Test. This session had no authenticated
  App Store Connect browser/API session, so processing state could not be
  checked directly — a human must confirm this in App Store Connect.
- Attach build 5 (not build 4) to an internal TestFlight group, add the owner
  as tester, and run the TF-015 owner smoke on a physical iPhone — this is
  what verifies the CNT-001/CNT-002 audio fixes and the UI-015 M4A fix on
  hardware. No group currently has a tester or build attached.
- All previously recorded human gates (REL-002, REL-003, REL-005, REL-006,
  TF-006/007/008/010) remain open; this evidence does not waive them.
- Nothing was submitted for TestFlight external or App Store review, and
  "Submit for Review" was not clicked, per the task's hard boundary.
