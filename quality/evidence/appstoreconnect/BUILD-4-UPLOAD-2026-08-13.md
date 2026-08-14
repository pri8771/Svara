# Build 4 signed archive and upload — 2026-08-13

## Outcome

Status: uploaded; Apple processing pending verification.

The 2026-08-11 signing blocker did not reproduce. The Apple account session was
available to `xcodebuild` today, automatic signing produced a valid
provisioning profile for `com.primandir.svara`, and build 4 was uploaded to
App Store Connect.

## Steps and results

- Source: branch `dev` at `667b44c` plus working-tree documentation changes
  only (no Swift or resource changes relative to `667b44c`).
- Archive: `xcodebuild archive -project Svara.xcodeproj -scheme Svara
  -destination "generic/platform=iOS" -allowProvisioningUpdates
  CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=796XH483R4`
  → `** ARCHIVE SUCCEEDED **` at `/private/tmp/svara-build/Svara-1.0-4.xcarchive`.
- Signature check: `codesign -dv` reports `com.primandir.svara`, team
  `796XH483R4`, with `embedded.mobileprovision` present.
- Upload: `xcodebuild -exportArchive` with an app-store-connect/upload
  export options plist (automatic signing, team `796XH483R4`,
  `uploadSymbols` true) → `Upload succeeded` / `** EXPORT SUCCEEDED **`
  at 2026-08-13 20:38 local.

## Remaining verification

- Confirm App Store Connect finishes processing build 1.0 (4) and records it
  as Ready to Submit / Ready to Test.
- Attach build 4 to an internal group, add the owner as tester, and run the
  TF-015 owner smoke on a physical iPhone (verifies the UI-015 M4A audio fix
  on hardware).
- All previously recorded human gates (REL-002/003/005/006, TF-006/007/008/010)
  remain open; this evidence does not waive them.
