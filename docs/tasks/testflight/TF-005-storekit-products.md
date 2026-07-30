# TF-005 — Configure and Reconcile All Svara Plus Products

> **Current applicability:** deferred under `DEC-006`. The owner-only testing
> build is free and exposes no Plus, paywall, membership, or purchase UI. Do
> not execute this task unless the owner explicitly decides to restore
> monetization.

- **Status:** `deferred`
- **Gate:** IAP functionality and external review
- **Execution type:** hybrid
- **Owner:** App Manager plus implementation agent
- **Dependencies:** TF-001, TF-002, TF-004

## Objective

Make App Store Connect, the local StoreKit configuration, code identifiers,
paywall behavior, and repository metadata describe the same three products.

## Task description

**Summary:** Configure a single, internally consistent Svara Plus product
catalog and prove its local behavior. **User story:** As a beta tester, I want
the three products shown in Svara to load with the intended terms and grant
access only after verified StoreKit transactions. We configure Apple products,
their commercial metadata, and the repository fixture from the approved
contract. This matters because product IDs cannot be casually replaced and
price/trial mismatches are both review and trust failures.
**Expected change:** App Store Connect, code, local StoreKit configuration, UI
copy, and tests agree on the approved monthly, yearly, and lifetime products.

## Subtask plan

### TF-005.1 — Freeze the product contract

**Description:** As the App Manager and developer, we need one immutable
comparison sheet before touching products. Copy the three exact IDs, types,
durations, group, approved prices, trial decision, family-sharing decision,
territories, and tax category from TF-001 into TF-005 evidence. Compare them to
`StoreService.swift`, `Svara.storekit`, paywall copy, and metadata, marking every
mismatch. The expected change is a signed-off product contract; stop if any commercial
value is still undecided.

### TF-005.2 — Configure the subscription group and plans

**Description:** As a subscriber, I need monthly and yearly choices that are
mutually exclusive levels of the same service. In App Store Connect, create or
open one **Svara Plus** subscription group, then create/verify the exact monthly
and yearly IDs and durations inside it. Never recreate an ID that already
exists. Record reference names and group membership. The expected change is two correctly
grouped auto-renewable subscriptions; stop on an ID/type/duration conflict.

### TF-005.3 — Configure the lifetime product

**Description:** As a purchaser, I need lifetime access represented as a
one-time non-consumable rather than a subscription. Create or verify
`com.svara.plus.lifetime` as a non-consumable, then confirm it is outside the
subscription group. Record its reference name and type. The expected change is one exact
non-consumable; if the existing ID has the wrong type, stop because Apple does
not permit silently changing product semantics.

### TF-005.4 — Complete commercial and review metadata

**Description:** As Apple Review and storefront testers, we need complete,
accurate product information. For every product enter approved localization,
price point, availability, tax category, family-sharing choice, review notes,
and a truthful paywall screenshot. Apply the approved introductory-offer
decision to both subscriptions and ensure eligibility is not promised
universally. Reload each product and record status. The expected change is three products
complete enough to load in sandbox; pending agreement or missing metadata blocks
completion.

### TF-005.5 — Reconcile code, fixture, UI, and copy

**Description:** As an implementation agent, I need every local source to match
Apple. Compare App Store Connect values to `SvaraProductID`, StoreKit fixture
durations/offers/prices, paywall labels/disclosures, and `AppStore/metadata.md`.
Change only the repository side that conflicts with approved TF-001/Apple
configuration, add or update unit tests, and never hard-code localized price
strings in production UI. The expected change is a zero-mismatch reconciliation table.

### TF-005.6 — Run local StoreKit scenarios

**Description:** As QA, I need deterministic local evidence before live
TestFlight testing. Enable the shared scheme’s StoreKit configuration and run
product load, each purchase, cancellation, pending approval, restore empty,
restore purchased, expiration, refund, and revocation cases. Verify UI state and
that only verified current entitlements unlock Plus. Record test environment
and results. A false unlock, false success, missing recovery, or inconsistent
product blocks completion. The expected change is a scenario matrix with actual
entitlement/UI results for every case.

### TF-005.7 — Close the catalog gate

**Description:** As TF-009 and TF-012 executors, we need a trusted catalog
baseline. Resolve ASM-002, record all product statuses and repository commit,
check the parent criteria, and update task/status/checklist files. Mark `done`
only when Apple configuration, repository sources, and local tests agree.
Remember that live TestFlight sandbox behavior remains a separate TF-012 gate.
The expected change is a frozen, reconciled product-catalog baseline for TF-012. Keep the
task blocked if any parent criterion or catalog row is incomplete.

## Canonical identifiers

| Product | Type | Product ID | Current reference |
|---|---|---|---|
| Monthly | auto-renewable, 1 month | `com.svara.plus.monthly` | USD $0.99 |
| Yearly | auto-renewable, 1 year | `com.svara.plus.yearly` | USD $7.99 |
| Lifetime | non-consumable | `com.svara.plus.lifetime` | USD $19.99 |

Monthly/yearly must be in one subscription group named **Svara Plus**. Prices
and the one-week introductory trials are decisions from TF-001, not assumptions.

## Procedure

1. Confirm Paid Apps, banking, and tax gates from TF-002.
2. In App Store Connect create/verify one Svara Plus subscription group.
3. Create/verify monthly and yearly products using the exact IDs/durations.
4. Create/verify the lifetime non-consumable using its exact ID.
5. For every product complete:
   - reference name;
   - English display name and description;
   - approved storefront price and availability;
   - tax category;
   - review screenshot showing the in-app paywall;
   - review notes explaining where the product is found;
   - family sharing decision.
6. Apply the TF-001 introductory-offer decision. If trials are disabled, remove
   them from `Svara.storekit`. If enabled, configure matching one-week offers
   in App Store Connect, but do not claim every customer is eligible.
7. Compare App Store Connect against:
   - `Svara/Core/Services/StoreService.swift`
   - `Svara/Resources/Svara.storekit`
   - `AppStore/metadata.md`
   - `Svara/Features/Profile/PaywallView.swift`
8. Run local StoreKit configuration tests for:
   load, monthly, yearly, lifetime, cancellation, pending approval, restore with
   no purchases, restore with purchase, refund/revocation, and expiry.
9. Wait up to one hour for App Store Connect metadata changes before declaring a
   sandbox lookup failure.
10. Record each product's App Store Connect status. For TestFlight it must be
    complete enough to load in sandbox; eventual first public submission must
    include the first subscription and first non-consumable with an app version.

## Acceptance criteria

- [ ] Three exact identifiers exist with correct product types.
- [ ] Monthly/yearly share one group.
- [ ] Pricing, availability, localization, tax, and review information complete.
- [ ] Trial decision is consistent everywhere.
- [ ] Local StoreKit scenarios pass.
- [ ] No profile flag can grant premium.
- [ ] ASM-002 is resolved.
- [ ] Evidence exists at `quality/evidence/testflight/TF-005.md`.

## Do not

- Do not create replacement product IDs to work around incomplete metadata.
- Do not promise a free trial without checking eligibility.
- Do not mark purchase success until StoreKit verifies the transaction.

## Apple sources

- https://developer.apple.com/help/app-store-connect/manage-subscriptions/offer-auto-renewable-subscriptions/
- https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase
- https://developer.apple.com/help/app-store-connect/test-a-beta-version/testing-subscriptions-and-in-app-purchases-in-testflight/
