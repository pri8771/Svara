# Assumptions

| ID | Assumption | Evidence | Validation plan / task | Status |
|---|---|---|---|---|
| ASM-001 | Bundle ID `com.primandir.svara` and team `796XH483R4` match the intended App Store record. | Xcode build settings | Confirm in App Store Connect in `TF-004` before signing. | unverified |
| ASM-002 | Dormant IAP identifiers and reference prices may be candidates for a future monetized build. | Current owner-testing build disables Plus under `DEC-006`. | Reconfirm every product, price, and territory in `TF-005` before reactivation. | deferred |
| ASM-003 | GitHub Pages URLs are the intended production legal and support destinations, and the corrected repository copy will be deployed there. | URLs returned HTTP 200, but the served copy was stale on 2026-07-29. | Deploy and content-check the exact URLs in `TF-006`. | verification_pending |
| ASM-004 | iPhone-only target family is intentional. | `TARGETED_DEVICE_FAMILY = 1` | Product owner confirms in `TF-001`. | needs_owner_confirmation |
| ASM-005 | The app uses no non-exempt encryption. | No network/crypto dependency; Info.plist flag | Reconfirm exact final dependency inventory in `TF-009` and signed build in `TF-011`. | verified_local |
| ASM-006 | The full five-tab build, rather than `FeatureFlags.betaScope`, is the intended external beta scope. | Shipping code currently uses `FeatureFlags.full`; guardrails describe a focused beta option. | Product owner selects and records scope in `TF-001`. | needs_owner_confirmation |
| ASM-007 | The dormant one-week introductory offers may be intended for a future Plus release. | Local StoreKit fixture contains them; current free build does not expose StoreKit. | Product owner explicitly accepts/removes trials during future `TF-005`. | deferred |
| ASM-008 | The beta territories, primary language, SKU, review contact, tester cohorts, and stop authority are known. | Values are absent or incomplete in repository docs. | Record every TestFlight value in `TF-001`; defer public-version copyright to the App Store release backlog. | unverified |
