# TestFlight Group Reset Evidence

- Date: 2026-08-02
- Authorization: release owner explicitly approved deletion of all internal and
  external TestFlight groups and preservation of all App Store Connect users
- Internal groups before reset: 2
- External groups before reset: 0
- Internal groups after reset: 0
- External groups after reset: 0
- Builds with a group assignment after reset: 0
- Public links after reset: 0

The manual internal groups `Svara Owner Smoke` and `Svara Friends Internal`
were deleted through App Store Connect after the owner confirmed Apple's final
deletion warning. The TestFlight sidebar then showed no internal tester groups,
and no external group section was present. The iOS build list showed blank
group assignments for Svara 1.0 (2) and 1.0 (3).

The Users and Access list was rechecked after deletion. The release owner
remains an Account Holder/Admin with all-app access. The approved friend remains
a Marketing user restricted to Svara, and the App Store Connect invitation is
still pending acceptance. No user was deleted, no role was changed, and no
invitation was revoked. Tester email addresses are intentionally omitted from
repository evidence.

Group deletion removes the testers' access to builds through those groups; it
does not delete the users, processed builds, or upload evidence. Replacement
groups must not be inferred. Record the owner-approved name, internal/external
type, membership, build assignment, automatic-distribution setting, and public-
link state before recreating each cohort.
