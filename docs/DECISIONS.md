# Decisions

## DEC-001 — App Factory registration

- **Status:** accepted
- **Decision:** Classify Svara as an existing iOS project governed by App
  Factory standard 0.4.0. The initial 0.2.0 enrollment was migrated on
  2026-07-29 to add the required repository map, documentation index, and
  reusable-library catalog.
- **Consequences:** Agents read `.factory` registration, project docs, quality
  manifest, and relevant contracts before changing code.

## DEC-002 — Local profile, not mock authentication

- **Status:** accepted
- **Context:** The former form accepted arbitrary email/password combinations.
- **Decision:** Ship without an account surface. Users may edit a display name
  stored only on their device.
- **Consequences:** No account-deletion flow or sign-in promise applies to 1.0.
  A real backend account feature requires a new contract and privacy review.

## DEC-003 — StoreKit is entitlement authority

- **Status:** accepted
- **Decision:** Premium access derives only from verified current StoreKit
  entitlements. The legacy profile flag is retained solely for decoding and is
  cleared during migration.
- **Consequences:** Expiration, refund, and revocation remove access after
  entitlement refresh.

## DEC-004 — StoreKit configuration is development-only

- **Status:** accepted
- **Decision:** Keep the shared scheme reference for simulator testing but
  exclude `Svara.storekit` from production target membership.

## DEC-006 — Owner testing build is free

- **Status:** accepted
- **Date:** 2026-07-30
- **Decision:** The current owner-only testing configuration exposes every
  bundled feature and content item for free. It has no Svara Plus card,
  membership label, paywall, or StoreKit product-loading flow.
- **Implementation:** `FeatureFlags.current.plusTierEnabled` is `false`.
  Authored premium markers, the paywall, StoreKit service, product identifiers,
  and a `monetizedFull` configuration remain dormant for intentional future
  reactivation.
- **Consequences:** Commerce tasks `TF-005` and `TF-012` are deferred and do
  not block the owner-only free build. Re-enabling Plus requires a new explicit
  owner decision, metadata/legal reconciliation, and full commerce testing.

## DEC-005 — TestFlight release configuration

- **Status:** accepted
- **Date:** 2026-07-30
- **Decision:** Upload Svara 1.0 (build 2) as an external-eligible TestFlight
  candidate for the owner first and a small, invitation-only close-friends
  cohort after TestFlight App Review. The build uses the full five-tab surface,
  targets iPhone on iOS 17+, and uses English (U.S.) as its primary language.
  Public links remain disabled. The existing App Store Connect record uses the
  immutable internal SKU `SVARA001` (reconciled on 2026-07-30; the earlier
  fallback proposal `SVARA-IOS-001` was never created). The private external group is
  `Svara Close Friends`, initially capped at 10 testers. The owner is the
  release operator, QA/feedback owner, and stop authority.
- **Review contact:** Use the owner’s secure contact record in App Store
  Connect; do not copy phone or other private contact data into the repository.
- **Commerce:** All content is free under `DEC-006`; IAP setup and testing are
  deferred and do not gate this free beta.
- **Consequences:** The uploaded build must not be marked TestFlight Internal
  Only, because that would make it permanently ineligible for close-friends
  external testing. Upload and owner-internal smoke may proceed first. External
  invitations remain blocked until metadata/legal/content/audio and physical
  QA gates are satisfied and Apple approves TestFlight App Review.
