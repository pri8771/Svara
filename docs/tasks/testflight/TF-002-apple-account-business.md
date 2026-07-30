# TF-002 — Verify Apple Account, Roles, Agreements, Tax, and Banking

- **Status:** `done`
- **Blocker:** none for the free TestFlight scope; paid-commerce business
  setup remains deferred to TF-005
- **Gate:** app record, IAP, signing, upload
- **Execution type:** human-only for sensitive/account actions
- **Owner:** Account Holder or delegated Admin/Finance
- **Dependencies:** TF-001

## Objective

Ensure the Apple Developer and App Store Connect account can create the app,
sign distribution builds, configure IAP, receive proceeds, and invite testers.

## Task description

**Summary:** Prove the intended Apple team and sole owner can create, sign,
upload, and internally test Svara; separately record paid-commerce state when
that scope resumes. **User story:** As the release owner, I want verified
membership, team identity, and sufficient Apple roles so the private upload
does not fail midway. This task checks account state without exporting
sensitive data. Active membership, the latest account agreement, app access,
and signing/upload/tester capabilities gate TF-015. Paid Apps, banking, and tax
gate TF-005/TF-012 only and may be explicitly deferred. **Expected change:**
The intended Apple team can perform the owner-only upload path, with every
unverified commerce item recorded as a named TF-005 blocker rather than passed.

## Subtask plan

### TF-002.1 — Verify membership and team identity

**Description:** As the app owner, I need to know the configured Xcode team is
the active legal developer team. Sign in to developer.apple.com with the
authorized account, select the intended organization, and compare its Team ID
to `796XH483R4`. Record membership active/expired, renewal date if safely
shareable, entity type, and Team ID—never credentials. The expected change is a
sanitized team verification. Stop immediately if the Team ID differs; do not
change Xcode or create a second account.

### TF-002.2 — Verify roles and app access

**Description:** As each downstream operator, I need the minimum Apple roles
needed for my assigned action. In App Store Connect **Users and Access**, map
the TF-001 roles to actual Apple roles and confirm access to Svara or all apps.
Check certificate/profile access, app-record/IAP access, upload access, Finance
access, and tester-management access. Record role names and access yes/no, not
people’s private data. The expected change is a role-to-capability matrix; stop and ask
an Admin/Account Holder to adjust access if any capability is missing.

### TF-002.3 — Resolve agreements

**Description:** As the account owner, I need the agreement state appropriate
to the selected scope. Verify the current membership/developer agreement needed
to create and upload the app. Also inspect Paid Apps status if accessible. If
IAP remains deferred, record Paid Apps as `deferred_to_TF-005` instead of
accepting or asserting it; if IAP is selected, the Account Holder must resolve
it and verify `Active`. The expected change is sanitized agreement-status
evidence separating the internal upload requirement from paid-commerce state.
Stop if an agreement blocks app creation or upload.

### TF-002.4 — Verify banking and tax readiness

**Description:** As the future legal seller, I need paid-commerce readiness
tracked without exposing sensitive data or blocking a non-commerce internal
install. If IAP remains deferred, record banking and tax as
`deferred_to_TF-005` without opening or copying sensitive forms. If commerce is
in scope, an Account Holder/Finance user verifies every required region is
complete/active. The expected change is either sanitized active/complete rows
or explicit TF-005 deferrals; never infer readiness. Stop if Apple unexpectedly
requires these items for the owner-only upload.

### TF-002.5 — Run capability checks and close

**Description:** As downstream TF-003–TF-014 executors, we need proof that the
assigned operator can reach the required Apple surfaces. Verify the operator can
view Certificates/Identifiers/Profiles, Apps, TestFlight, IAP, and relevant
Business status without an agreement banner. Record each observed result in
TF-002 evidence, check acceptance criteria, and update repository status. Mark
`done` when all capabilities required by DEC-005 pass and every deferred
commerce capability names TF-005; otherwise state the exact missing role,
agreement, or Apple processing blocker. The expected change is the completed
scope-aware capability matrix and parent go/no-go result.

## Required access

- Account Holder for agreements.
- Account Holder/Admin for certificates and profiles.
- Account Holder/Admin/App Manager for app records and IAP.
- Finance access as needed for banking/tax status.
- Developer or higher for build upload.

## Procedure

1. Sign in to Apple Developer and App Store Connect using the intended team.
2. Confirm the Apple Developer Program membership is active and the team ID is
   `796XH483R4`. If it differs, stop; do not silently change Xcode settings.
3. Confirm the current agreement required for membership/app creation/upload
   is accepted.
4. If commerce is deferred in DEC-005, record Paid Apps, banking, and tax as
   `deferred_to_TF-005`; otherwise verify them through the authorized account.
6. In **Users and Access**, confirm the assigned operator can access Svara (or
   all apps) and has the roles required for TF-003 through TF-014.
7. Confirm certificate access or cloud-managed distribution permission is
   available to the person who will archive/upload.
8. Record sanitized status only: team ID, membership active yes/no, agreements
   active yes/no, banking/tax complete yes/no, and role names.

## Verification

- Creating a new app and uploading is not blocked by an agreement banner.
- The operator can view Certificates, Identifiers & Profiles.
- The operator can access Apps and TestFlight in App Store Connect.
- Paid Apps status is active before TF-005.

## Acceptance criteria

- [x] Membership/team verified.
- [x] Latest upload-required agreement accepted.
- [x] Paid Apps, banking, and tax are either complete/active or explicitly
  deferred to TF-005 under DEC-005.
- [x] Required roles and app access verified.
- [x] Sanitized evidence exists at
  `quality/evidence/testflight/TF-002.md`.

## Failure handling

If membership, team identity, role, or an upload-required agreement is pending,
set this task to `blocked`. A paid-commerce-only issue blocks TF-005/TF-012 but
does not block TF-003, TF-004, TF-011, or TF-015 when DEC-005 defers commerce.

## Do not

- Never commit tax forms, bank details, identity documents, 2FA codes, or
  screenshots containing them.

## Apple sources

- https://developer.apple.com/help/app-store-connect/manage-agreements/sign-and-update-agreements/
- https://developer.apple.com/help/app-store-connect/manage-agreements/view-agreements-status/
