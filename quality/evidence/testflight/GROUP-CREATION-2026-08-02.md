# TestFlight Group Creation Evidence

- Date: 2026-08-02
- Internal group count: 2
- External group count: 2
- Tester count across new groups: 0
- Build assignment count across new groups: 0
- Public links enabled: 0
- TestFlight App Review submissions made: 0

After the clean-slate reset, the release owner explicitly requested and App
Store Connect displayed these replacement groups:

| Type | Group | Automatic distribution | Testers | Builds |
|---|---|---:|---:|---:|
| Internal | `internal_family` | disabled | 0 | 0 |
| Internal | `internal_family_and_friends` | disabled | 0 | 0 |
| External | `external_family` | not applicable | 0 | 0 |
| External | `external_family_and_friends` | not applicable | 0 | 0 |

The internal creation dialogs were explicitly changed from Apple's enabled
automatic-distribution default to disabled before creation. External creation
only named the empty groups. No tester, build, public link, or external-review
submission was added. App Store Connect users and the pending Svara-only user
invitation were not modified.

The next distribution change requires an explicit owner mapping of users and
builds to groups. For TF-015, the owner must designate exactly one internal
group, add only the owner, and attach only processed build 3. External groups
must remain empty until TF-006–TF-008, TF-010, TF-013, and TF-014 permit rollout.
