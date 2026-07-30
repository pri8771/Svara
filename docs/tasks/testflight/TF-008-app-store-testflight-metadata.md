# TF-008 — Complete App Store Connect and TestFlight Metadata

- **Status:** `blocked`
- **Gate:** external TestFlight review
- **Execution type:** hybrid
- **Owner:** App Manager/Marketing plus release owner
- **Dependencies:** TF-001, TF-004, TF-006, TF-007

## Objective

Enter accurate app-level, TestFlight-level, and review-contact information using
`AppStore/metadata.md` as the canonical copy.

## Task description

**Summary:** Complete App Store Connect and TestFlight information from approved
repository facts, then prove the live fields match. **User story:** As an Apple
reviewer and tester, I want accurate privacy, rights, age, contact, and testing
information so I understand the build and can evaluate it without hidden
requirements. We reconcile canonical copy, enter app-level declarations, enter
beta information, and compare the saved UI back to the repository. This matters
because metadata is part of the reviewed product and false answers can invalidate
the beta even when the binary works.
**Expected change:** Every required saved App Store Connect and TestFlight field
matches approved repository facts, with no placeholder or unexplained mismatch.

## Subtask plan

### TF-008.1 — Freeze and validate canonical metadata

**Description:** As the App Manager, I need approved source text before entering
fields. Copy the final App Store record facts from TF-004, URLs from TF-006,
rights result from TF-007, and configuration from DEC-005 into a metadata
worksheet. Re-read the exact build behavior and validate name, subtitle,
keywords, description, beta description, What to Test, review notes, and email
against current UI. Calculate field lengths. The expected change is a zero-placeholder,
zero-contradiction worksheet. Stop if an upstream fact is missing.

### TF-008.2 — Complete app identity and classification fields

**Description:** As App Store Connect, I need the record’s stable descriptive
fields. Enter or verify app name, subtitle where applicable, primary/secondary
categories, primary language, SKU, copyright/seller text, Apple ID, bundle ID,
and privacy-policy URL using approved values only. Save, reload, and compare
each displayed value to the worksheet. The expected change is a field-by-field verified
App Information record; do not rename or reclassify the product to work around
an error.

### TF-008.3 — Complete and publish App Privacy

**Description:** As a tester, I need Apple’s privacy disclosure to match actual
data flows. Re-audit the final dependencies, SDKs, networking, analytics,
tracking, account behavior, local profile/progress/reflections, notifications,
and IAP. Select “No, we do not collect data” only if no developer/partner can
access off-device data under Apple’s definition, publish the response, reload
it, and record selected answers. Any unexpected network/SDK behavior stops this
subtask and creates a privacy bug rather than forcing the planned answer. The
expected change is a published App Privacy response plus its audited data-flow
basis.

### TF-008.4 — Complete age, rights, and export declarations

**Description:** As Apple and regional users, we need honest regulatory and
content declarations. Answer every current age-rating question based on shipped
content, record the selected answers and calculated regional ratings, answer
Content Rights from TF-007 evidence, and confirm export compliance against the
final binary/dependencies and Info.plist. Do not force the proposed 4+ result.
The expected change is a saved declaration set with evidence references; ambiguity is
escalated to the responsible owner.

### TF-008.5 — Enter TestFlight test information

**Description:** As an external tester and TestFlight reviewer, I need concise
instructions and a reachable contact. Under TestFlight Test Information, select
the approved language and enter Beta App Description, Feedback Email, review
contact name/email/phone from the secure TF-001 record, review notes, and
sign-in-required = No. For the candidate build/group, enter What to Test. Turn
off Invitation Experience App Information if approved screenshots do not exist.
Save and reload. The expected change is complete review/test information with no fake
credentials or misleading screenshots.

### TF-008.6 — Perform repository-to-Apple comparison and close

**Description:** As later upload/review tasks, we need proof the external system
is a faithful copy. Compare every saved field to `AppStore/metadata.md`, record
timestamp and sanitized screenshots/references, correct the repository first if
an approved change is necessary, then re-copy it to Apple. Check parent
acceptance criteria and update task/status/checklist. Mark `done` only when the
repository and saved App Store Connect values match exactly. The expected change is a
timestamped repository-to-Apple field comparison with zero unresolved drift.

## App-level fields to verify

- Name and subtitle (both within Apple's 30-character limits).
- Primary/secondary category.
- Privacy policy URL.
- Content Rights answer. Do not assert rights until TF-007 is complete.
- Age rating questionnaire and calculated regional results.
- Primary language, SKU, bundle ID, Apple ID.
- Export-compliance state for the uploaded build.

## TestFlight fields

- Beta App Description.
- Feedback Email.
- App Review contact name, email, and phone from TF-001 secure record.
- Beta App Review Notes.
- Sign-in required: **No**.
- Build-level **What to Test** copied from the canonical repository section.

## Procedure

1. Re-read the final binary behavior and `AppStore/metadata.md`.
2. Add missing repository facts: Apple ID, SKU, primary language, confirmed
   categories, age-rating result, content-rights answer, and secure contact
   reference. Do not commit a private phone number without approval.
3. In App Store Connect, complete App Information and App Privacy:
   - choose **No, we do not collect data from this app** only if final dependency
     audit still confirms no off-device developer/partner collection;
   - publish the App Privacy response;
   - enter the verified live privacy URL.
4. Complete the current age questionnaire honestly. Record all selected answers
   and Apple's calculated global/region-specific rating; do not force 4+ merely
   because the repository currently proposes it.
5. Complete Content Rights only after TF-007.
6. Under TestFlight → Test Information, enter beta description, feedback email,
   contact, and notes.
7. For the selected build/group, enter What to Test.
8. Keep the Invitation Experience App Information option off if no approved,
   accurate screenshots exist. Do not upload misleading placeholders.
9. Compare every entered field back to repository copy and record timestamp.

## Required validation

- Name: 5 characters.
- Subtitle: currently exactly 30 UTF-8 bytes.
- Keywords: currently 96 UTF-8 bytes; relevant for eventual store version.
- No login credentials are entered.
- IAP identifiers and access path appear in review notes.
- URLs open without authentication.

## Acceptance criteria

- [ ] App-level required fields are complete and accurate.
- [ ] App Privacy response is published.
- [ ] Age questionnaire result is recorded.
- [ ] Content Rights response is supported by TF-007.
- [ ] TestFlight description, feedback email, contact, notes, and What to Test
  are entered.
- [ ] Repository copy exactly matches App Store Connect.
- [ ] Evidence exists at `quality/evidence/testflight/TF-008.md`.

## Apple sources

- https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-test-information
- https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating
- https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/
