# TF-013 — Define Beta Operations, Monitoring, Triage, and Stop Criteria

- **Status:** `done`
- **Blocker:** none; TF-014 still enforces metadata/review dependencies
- **Gate:** external rollout
- **Execution type:** hybrid
- **Owner:** beta-feedback/release owner
- **Dependencies:** TF-001

## Objective

Set up a safe operating process before external testers receive access.

## Task description

**Summary:** Establish the people, cohorts, monitoring, severity, stop, and
replacement procedures that govern the beta after invitations begin.
**User story:** As a tester and release owner, I want feedback handled quickly and a
harmful build stopped predictably instead of relying on ad hoc judgment. We
define a staged cohort, assign monitoring coverage, standardize triage, approve
stop criteria, and document replacement/invalidation. This task is operational,
not a binary change, but it must be complete before external access.
**Expected change:** An owner-approved and tabletop-tested operations plan names
cohorts, monitoring coverage, severity rules, stop authority, and replacement
steps.

## Subtask plan

### TF-013.1 — Define staged cohorts and distribution controls

**Description:** As the release owner, I need exposure proportional to observed
risk. Record approved internal/external group names, invitation method, initial
tester count, audience/device/cultural coverage, public-link decision, device/OS
criteria, hard limits, expansion stages, and minimum observation period.
Default to the smallest private cohort; do not enable an unrestricted public
link by assumption. The expected change is an owner-approved staged rollout table.

### TF-013.2 — Assign monitoring and response ownership

**Description:** As a tester reporting a problem, I need a monitored channel and
responsible human. Assign primary/backup feedback owners, release owner, stop
authority, engineering triage, cultural escalation, rights/legal escalation,
and support response target. Verify each person can access required TestFlight/
App Store Connect surfaces and secure contacts. Store private escalation details
outside the repo with a durable reference. The expected change is a coverage roster with
no unowned time/window.

### TF-013.3 — Define severity and repository-first triage

**Description:** As implementers, we need consistent decisions from incomplete
beta reports. Define blocker/high/medium/low using the criteria in this file,
then document intake fields: build, device/OS, state, reproduction, expected/
actual, frequency, logs/media, privacy handling, owner, and next action. Every
actionable issue is created in `docs/BUGS.md` or its approved repository issue
mechanism before Jira/Notion mirroring. The expected change is a reproducible triage
workflow that excludes tester PII from public records.

### TF-013.4 — Approve stop and escalation criteria

**Description:** As users exposed to a beta, we need immediate containment for
crash, data loss, false purchase, privacy, rights, cultural harm, or inaccessible
primary workflows. Review each stop condition with the TF-001 stop authority,
specify who can disable a build/public link, how quickly, who is notified, and
where the decision is logged. Conduct a tabletop example to confirm access.
The expected change is an approved, executable stop procedure—not merely a list of risks.

### TF-013.5 — Define replacement-build procedure

**Description:** As engineering, I need every replacement to carry new identity
and new evidence. Document: stop affected distribution, create repo bug, fix,
increment build, identify which content/code/config changed, reset invalidated
TF tasks, rerun them, upload, update What to Test, and only then replace group
builds. Include a matrix for common change types and invalidated gates. The
expected change is a replacement procedure that prevents evidence from an old
binary being attached to a new one.

### TF-013.6 — Define mirror and secure-data handling

**Description:** As project operators, we need useful Jira/Notion copies without
creating another authority or leaking tester data. Record the repository-first
mirror contract, destination IDs once approved, commit SHA field, sync owner,
and correction process. Define where private tester lists, phone numbers,
screenshots, legal records, and purchase/account details live. The expected change is an
approved external-systems handling procedure. Stop mirror setup while a
destination, commit SHA, sync owner, or secure storage location is missing.

### TF-013.7 — Tabletop, approve, and close

**Description:** As the release owner, I need proof the operating plan works.
Run a tabletop scenario—such as a tester charged without access—from intake
through stop, escalation, bug creation, replacement, and resumption. Record
gaps, revise the plan, obtain owner approval, and create TF-013 evidence. Mark
`done` only when cohorts, coverage, triage, stop access, replacement, and secure
handling are executable. The expected change is an owner-approved, tabletop-verified beta
operations plan.

## Cohort plan

Record owner-approved values:

- internal group name and testers;
- private external group name;
- initial external tester count/limit;
- whether email invitation or public link is used;
- if public link, device/OS criteria and hard tester limit;
- rollout stages and minimum observation period between stages;
- feedback owner and backup;
- support response target.

Do not default to an unrestricted public link. Start with the smallest cohort
that can exercise the device/cultural audience matrix.

## Feedback workflow

1. Monitor TestFlight feedback, screenshots, sessions, crashes, and App Store
   Connect build status.
2. Triage every report into:
   - blocker: crash loop, data loss, false purchase/entitlement, rights/privacy
     issue, harmful cultural content, inaccessible primary workflow;
   - high: repeatable major workflow failure;
   - medium/low: recoverable or cosmetic.
3. Create repository bug entries first using build/device/OS/reproduction.
4. Copy repo bug ID/link into Jira/Notion only after the repo entry exists.
5. Never copy tester PII or screenshots containing private content into a public
   repository.

## Stop criteria

Immediately stop testing/disable the public link for:

- launch or repeatable workflow crash;
- user progress/reflection loss;
- purchase charged without access, access without verified entitlement, wrong
  price/product, or restore failure affecting valid purchasers;
- privacy/legal mismatch or unexpected data transmission;
- unlicensed audio/content concern;
- credible cultural harm or doctrinal-authority issue;
- primary action inaccessible with supported accessibility settings.

The release owner named in TF-001 has stop authority. Record escalation contacts
in a secure system.

## Build replacement procedure

1. Stop the affected build/group if severity requires.
2. Record bug and evidence in repo.
3. Fix on a new branch/change.
4. Increment build number.
5. Repeat every invalidated gate; never attach old evidence to a new binary.
6. Update What to Test with the fix/regression focus.

## Acceptance criteria

- [ ] Cohorts, limits, criteria, and rollout stages approved.
- [ ] Feedback and bug triage ownership assigned.
- [ ] Stop criteria and stop authority recorded.
- [ ] Secure escalation path exists.
- [ ] Build replacement procedure agreed.
- [ ] Jira/Notion mirror rules understood.
- [ ] Evidence/operations record exists at
  `quality/evidence/testflight/TF-013.md`.

## Apple sources

- https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/
- https://developer.apple.com/help/app-store-connect/reference/testflight/beta-tester-feedback/
