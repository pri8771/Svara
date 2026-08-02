# App Store Connect account cleanup evidence — 2026-08-02

Scope: cleanup requested by the account owner. No users or tester memberships were changed.

## Removal results

Removal was confirmed for these records (they no longer appeared in the Apps list after the action):

- Wave Shooter PC
- AR Dare Lab
- Nootry CMU
- YourGovt

For the following records, App Store Connect accepted the confirmation dialog but then displayed **“This app is unable to be removed right now.”** They remain account records and require an Apple-side eligibility/status change before retrying:

- MeetYourCongress
- SeeYourRep
- Dollar Per Life
- VGScoreKeeper (not yet retried after the same legacy-record behavior was observed)

Do not treat the blocked records as deleted. The Remove App action moves eligible records to Apple’s Removed Apps workflow; it is not an irreversible data purge.

## Current users (observed live)

- Priyansh Chordia — Account Holder and Admin — All Apps
- Sonakshi Mittal — Marketing — Anjali Svara — invitation pending
- Supriya Chordia — Developer — Anjali Mala: A Quiet Digital Mala — invitation pending
- Eshan Chordia — Developer — Anjali Mala: A Quiet Digital Mala — invitation pending

Emails are intentionally omitted from repository evidence.

## Remaining product records observed during audit

The Svara account still showed Svara and the other retained records, plus an `Anjali` record. Confirm the desired retention of `Anjali` before any future deletion request; it was not included in the owner’s deletion list.

## Svara TestFlight readiness follow-up

The Svara record remains `Prepare for Submission`. App Privacy is not started, Test Information is blank, no iPhone screenshots are uploaded, and no build is attached to the App Store version. Content Rights and Age Ratings also require setup. These are separate from account cleanup and remain release blockers.
