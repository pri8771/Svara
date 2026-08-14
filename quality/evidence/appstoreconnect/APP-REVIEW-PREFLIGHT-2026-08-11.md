# App Review preflight — 2026-08-11

## Outcome

Status: `human_review_required`; not submitted to App Review.

Svara cannot currently be added to an App Store review submission. The local
automated test action completed successfully for the current `dev` source, but
the signed Release archive failed before creation because Xcode reported no
valid Apple account and no provisioning profile for `com.primandir.svara`.
App Store Connect also redirected the Svara version URL to a failed-auth login
page, so live metadata could not be reverified.

## Approval blockers

- No approved App Store screenshots exist in the repository.
- App Privacy, age rating, Content Rights, and production version metadata are
  not evidenced as complete in App Store Connect (`TF-008`).
- Source, performer consent, and App Store distribution rights remain
  unverified for all nine bundled audio recordings (`REL-002`, `TF-007`).
- Independent cultural/theological review remains incomplete (`REL-003`,
  `TF-007`).
- Physical-device accessibility, notification, and audio-route coverage remains
  incomplete (`REL-005`, `TF-010`).
- Owner legal approval and physical verification of support/privacy/terms links
  remain incomplete (`REL-006`, `TF-006`).
- Build 4 has not been signed, uploaded, processed, or attached to App Store
  version 1.0. Existing build 3 is TestFlight-processed evidence only and is not
  recorded as a production-approved candidate.

## Local observations

- Branch: `dev`.
- App version/build in project: `1.0 (4)`.
- Bundle ID: `com.primandir.svara`.
- Full simulator test command returned success on iPhone 17 / iOS 26.4.1.
- Privacy manifest parses successfully and declares no tracking/collection plus
  the UserDefaults required-reason API.
- Source scan found no implemented analytics, advertising, tracking, backend,
  or network client in the shipping target.
- Signed archive attempt failed with `No Accounts` and no matching provisioning
  profile. No binary was uploaded.

## Required next actions

1. Restore the authorized Apple account in Xcode and App Store Connect.
2. Complete TF-006, TF-007, TF-008, TF-010, and the owner TestFlight smoke.
3. Produce and approve real App Store screenshots.
4. Freeze the production candidate, rerun release gates, create a signed
   archive, upload a unique build, and verify Apple processing.
5. Compare every live App Store Connect field to `AppStore/metadata.md`.
6. Only then add the version for review and submit it.

No rights, legal, privacy, age-rating, or reviewer answers were inferred or
entered during this preflight.
