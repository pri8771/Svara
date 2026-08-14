# Svara landing page, icon, and waitlist tasks

Status: `planned`  
Created: 2026-08-03  
Public route: `https://priyanshchordia.com/products/svara/`

## Outcome

Publish an honest, accessible Svara marketing page with a selected new icon
direction, exact-candidate screenshots, and an app-specific HubSpot waitlist.
This track does not weaken `ProductGuardrails.md`, content/audio review, or the
TestFlight gates in `TESTFLIGHT_TASKS.md`.

The local design reference is
`/Users/pchordia/Documents/claude-design-handoff-five-apps-2026-08-03.zip`.
Claude Design is requested to create three complete Svara page concepts and
three corresponding icon candidates as part of 15 portfolio concepts. None is
approved merely because it was generated.

## Product truth

- Positioning: a private daily spiritual companion rooted in Hindu culture.
- Current testing scope includes Practice, Learn/Aaroh, Festivals, Stories,
  local progress, reminders, and only audio actually present in the candidate.
- All content is free in the current testing configuration; do not advertise
  dormant Plus or StoreKit products.
- Do not present Svara as a religious authority or claim unverified endorsement.
- Cultural symbols and text require respectful, reviewed use.

## Asset baseline

- Current opaque 1024×1024 icon and supplementary Svara mark are references.
- No approved website screenshot set is supplied.
- New icon concepts remain candidates until owner, cultural, small-size,
  opacity, and uniqueness review passes.

## Task index

| ID | Task | Status | Depends on | Completion evidence |
|---|---|---|---|---|
| SVA-LP-001 | Reconcile claims with exact build 3 or its approved successor | ready | candidate identity | Build/SHA claim matrix |
| SVA-LP-002 | Produce 3 full clickable concepts and 3 icon candidates | ready | handoff ZIP | Ingestion report, diversity matrix, prototypes, icon board |
| SVA-LP-003 | Review product clarity, cultural framing, accessibility, and implementation feasibility | blocked | SVA-LP-002, human review | Recorded concept dispositions and selection |
| SVA-LP-004 | Capture approved real screenshots | blocked | selected concept, exact candidate | Shot manifest with provenance and checksums |
| SVA-LP-005 | Finalize copy, content claims, audio claims, and limitations | blocked | SVA-LP-001, content/audio review | Approved copy deck |
| SVA-LP-006 | Select and production-test an icon | blocked | SVA-LP-003 | Owner/cultural approval plus small-size and technical checks |
| SVA-LP-007 | Approve website privacy and Svara waitlist consent | blocked | HubSpot configuration, legal owner | Approved disclosure, retention, deletion, consent |
| SVA-LP-008 | Deliver selected assets/copy to website repository | blocked | SVA-LP-004 through SVA-LP-007 | Versioned public-only handoff manifest |
| SVA-LP-009 | Verify landing page and waitlist | blocked | website implementation | Responsive/a11y/form/privacy/link evidence |
| SVA-LP-010 | Approve publication | blocked | SVA-LP-009 | Exact website commit and owner approval |

## Screenshot minimum

Capture Today, a real guided practice, Aaroh, one reviewed festival/story/symbol
surface, and local progress/profile. Never expose a paywall while Plus is
disabled. Record the exact build, source SHA, device, appearance, content IDs,
and capture approval.

## Waitlist contract

Email is required; first name and device/testing interest are optional. Require
Svara-specific consent. Use hidden `app_slug=svara` plus page/source/UTM context.
Do not enroll contacts in other lists without separate consent. Verify all form
states and a non-JavaScript support fallback.

## Done means

A selected prototype alone is not completion. Real reviewed assets, product and
cultural approval, truthful candidate claims, verified privacy/consent,
accessible responsive implementation, exact deployment evidence, and explicit
publication approval are required.

## Website implementation update — 2026-08-03

The canonical website now implements The Ascent, Almanac, and Constellation of
Practice as three persistent/query-addressable Svara directions with responsive
layouts and CSS-rendered icon previews. Automated checks and desktop/mobile
selector checks pass. Exact-candidate screenshots, cultural/claim approval,
production icon approval, HubSpot form/consent states, deployment evidence, and
publication approval remain open. The current CTA discloses an email fallback.
