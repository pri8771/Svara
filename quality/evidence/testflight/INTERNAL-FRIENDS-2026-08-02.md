# Internal Friends TestFlight Setup Evidence

- Date: 2026-08-02
- Status: `removed`
- Group: `Svara Friends Internal`
- Group type: Internal
- Automatic distribution: disabled
- Attached build: Svara 1.0 (3)
- Current tester count: 1 owner
- External group/public link: none

The owner created a separate internal group and manually attached processed
build 3. The owner was added and remains in `Invited` state. One approved friend
was invited to App Store Connect with the Marketing role restricted to Svara;
no other app, finance, development-certificate, API-key, or administrative
access was granted.

At the time of setup, Apple exposed only the owner in the internal TestFlight
tester picker. The friend had to accept the App Store Connect invitation before
becoming eligible for group addition and therefore did not receive the
group/build TestFlight invitation. That planned addition was cancelled by the
later group reset; acceptance must not trigger assignment to a replacement
group without a new owner-approved cohort design.

## Removal

Later on 2026-08-02, the owner authorized deletion of every internal and
external TestFlight group while explicitly preserving App Store Connect users.
`Svara Friends Internal` was deleted. The Svara-only App Store Connect
invitation remains pending; the user was not deleted and has not received a
group/build TestFlight invitation. App Store Connect showed zero internal and
zero external groups after the reset, with no group assigned to builds 2 or 3.

This historical interim setup does not close TF-015, authorize external
testing, or clear legal, cultural, audio-rights, metadata, physical-device QA,
and TestFlight App Review gates.
