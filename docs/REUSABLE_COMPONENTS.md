# Reusable Components

## Catalog reviewed

- Catalog version: `0.1.0`
- Snapshot date: 2026-07-17
- Review date: 2026-07-29
- Registered libraries: none
- Capabilities reviewed: persistence, StoreKit, notifications, content loading,
  audio playback, validation, progress/streak logic, design system, test support

The current central catalog has no released package candidates. Svara therefore
keeps its existing, dependency-free local implementations. This is not approval
to add a third-party dependency; `TF-001` and current project constraints still
apply.

## Adopted shared libraries

None.

## App-local reusable candidates

| Module | Capability | Why local for now | Genericity evidence | Promotion trigger |
|---|---|---|---|---|
| `Core/Services/Persistence.swift` | Codable `UserDefaults` persistence | Small product-local API; no registered package | Multiple Svara services use the same typed store | A second product needs identical semantics and tests |
| `Core/Services/StoreService.swift` | StoreKit 2 entitlement handling | Product IDs and Plus rules are Svara-specific | Transaction verification/listening patterns may generalize | A stable product-agnostic API is proven in another app |
| `Core/Services/NotificationService.swift` | Local reminder permission/scheduling | Copy, identifiers, and schedule are product-specific | Permission-state handling is broadly reusable | Another product needs the same tested adapter |
| `Core/Content/ContentValidation.swift` | Content schema/guardrail validation | Cultural rules are Svara-specific | Validation framework shape may generalize; rules do not | A generic validation core can exclude product doctrine |
| `Core/Services/StreakCalculator.swift` | Local-day streak arithmetic | Current surface is narrow and tested locally | Pure date logic is potentially reusable | Cross-product requirements establish one semantic contract |

No extraction is authorized by this document. Extraction requires a separate
decision, compatibility review, tests, and central registry change.

## Upstream edge cases

None; no shared library is adopted.

## Rejected candidates

| Candidate | Reason |
|---|---|
| New third-party persistence library | Current local Codable store is sufficient; project constraints disallow third-party dependencies |
| New third-party StoreKit wrapper | StoreKit 2 implementation already exists and product entitlement rules are app-specific |
| New analytics/remote-config SDK | Product scope explicitly excludes analytics, tracking, backend, and remote configuration |
