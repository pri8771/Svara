# Apple TestFlight Requirements

_Research baseline: 2026-07-29. Apple documentation and the live App Store
Connect UI are authoritative if labels or workflows change._

This document records the external requirements behind Svara's canonical task
backlog. It is not a checklist; execution status lives in
`docs/TESTFLIGHT_TASKS.md`.

## Gate model

### 1. Upload eligibility

Before any TestFlight build can exist:

- an App Store Connect app record must already exist;
- the bundle ID, version, and build number in the binary must identify that
  record and upload;
- the uploader needs an allowed App Store Connect role;
- the archive must be distribution-signed with the correct team, App ID, and
  provisioning;
- export-compliance questions or Info.plist declarations must be satisfied;
- the uploaded build must finish Apple's processing.

Apple associates uploads using bundle ID and version, and treats the build
string as the unique build identifier. Processing completion is distinct from
upload success.

## 2. Internal TestFlight eligibility

- Create an internal testing group and add App Store Connect users who have
  access to the app.
- Add a processed build and provide build-level **What to Test** text.
- Internal TestFlight supports up to 100 App Store Connect users.
- Builds uploaded as **TestFlight Internal Only** cannot later be used for
  external testing. Svara may use that option for the explicitly private
  TF-015 owner build. Any later external candidate must use a new build number,
  rerun invalidated gates, and not use Internal Only.
- TestFlight builds are available for 90 days.

## 3. External TestFlight eligibility

This section is deferred from the active one-owner TF-015 milestone.

- An internal group must exist before an external group is created.
- Provide TestFlight test information: beta app description, feedback email,
  review contact details, and review notes; provide credentials only if the app
  actually requires login. Svara does not.
- Add the build to an external group and provide **What to Test**.
- Submit the build and metadata to TestFlight App Review. The first build
  normally receives a full review; later builds might not.
- Apple allows up to 10,000 external testers. A public link can be constrained
  by device/OS criteria and tester limit.
- Only one build per version can be in TestFlight review at a time, and no more
  than six builds may be submitted for TestFlight review in 24 hours.

## StoreKit and paid-content requirements

- The Account Holder must accept the Paid Apps Agreement to offer IAP.
- Banking and tax information must be complete as required by the account.
- Monthly and yearly plans belong in one subscription group; users can hold
  only one subscription in a group at a time.
- Product ID, duration, price, localization, availability, tax category, and
  review information must be complete.
- A non-consumable lifetime product is configured separately.
- TestFlight IAP runs in Apple's sandbox. Subscription renewal is accelerated;
  current Apple guidance says TestFlight subscriptions renew daily, up to six
  times in one week.
- Metadata changes can take up to one hour to appear in sandbox.
- For eventual App Store release, the first auto-renewable subscription and
  first non-consumable must be submitted with an app version. This is an App
  Store release requirement, not permission to skip sandbox testing before the
  external beta.

## Privacy, content, and metadata requirements

- A privacy policy URL is required for iOS.
- App Privacy answers must cover data collected by the developer and integrated
  third parties. Apple defines collection as off-device transmission that lets
  the developer or partner access data beyond servicing a real-time request.
  Svara's current local-only data is therefore documented as not collected.
- Privacy responses must be published in App Store Connect and kept current.
- Apps containing third-party content must possess necessary distribution
  rights. Svara cannot complete this declaration until audio/content evidence
  is complete.
- Age rating is a required app-level property and must come from the current
  questionnaire, not from a guessed number in repository copy.
- TestFlight builds must follow the App Review Guidelines: complete metadata,
  functional URLs, working IAP, accurate descriptions, and no hidden or
  misleading behavior.
- A support URL must lead to real contact information.
- If screenshots are shown in the invitation experience, they must accurately
  represent the build. Approved App Store screenshots can be deselected for a
  TestFlight invitation. Final App Store screenshots remain a later App Store
  release task, not an upload blocker for this external beta.
- Copyright is required platform-version information for a public App Store
  submission. It is not part of TestFlight test information and does not block
  internal or external TestFlight. External TestFlight still requires its
  separate review contact information, stored securely in App Store Connect.

## Export compliance

Apple requires an encryption determination for uploaded/tested apps. Svara's
current archive declares `ITSAppUsesNonExemptEncryption = NO`. Reconfirm the
final dependency and networking inventory before upload; do not reuse that
answer if encryption behavior changes.

## Primary Apple sources

| Topic | Source |
|---|---|
| TestFlight workflow | https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/ |
| Create an app record | https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/ |
| Upload and process builds | https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/ |
| Build processing statuses | https://developer.apple.com/help/app-store-connect/reference/app-uploads/build-upload-statuses/ |
| Certificates | https://developer.apple.com/help/account/create-certificates/certificates-overview |
| App Store provisioning | https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile |
| Cloud-managed certificates | https://developer.apple.com/help/account/certificates/cloud-managed-certificates/ |
| Internal testers | https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers/ |
| Test information | https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-test-information |
| TestFlight review information definition | https://developer.apple.com/help/glossary/testflight-test-information/ |
| External testers/review | https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers |
| Paid Apps agreement | https://developer.apple.com/help/app-store-connect/manage-agreements/sign-and-update-agreements/ |
| Subscription setup | https://developer.apple.com/help/app-store-connect/manage-subscriptions/offer-auto-renewable-subscriptions/ |
| IAP submission | https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase |
| TestFlight IAP testing | https://developer.apple.com/help/app-store-connect/test-a-beta-version/testing-subscriptions-and-in-app-purchases-in-testflight/ |
| App Privacy | https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy |
| Export compliance | https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance |
| Age rating | https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating |
| App information/content rights | https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/ |
| Platform version copyright and review fields | https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information |
| App Review Guidelines | https://developer.apple.com/app-store/review/guidelines/ |
