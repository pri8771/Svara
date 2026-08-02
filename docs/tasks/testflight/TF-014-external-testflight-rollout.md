# TF-014 — Submit TestFlight App Review and Roll Out External Cohort

- **Status:** `blocked`
- **Gate:** external beta complete
- **Execution type:** human App Store Connect action with repository evidence
- **Owner:** App Manager/release owner
- **Dependencies:** TF-012, TF-013

## Objective

Submit the internally verified build and accurate metadata to TestFlight App
Review, then invite the approved owner-defined external cohort safely.

## Task description

**Summary:** Submit the internally proven candidate for TestFlight App Review
and begin the approved external cohort under active monitoring. **User story:**
As an external tester, I want access only to a reviewed build with accurate
instructions, functioning support, and a team ready to stop or replace it. We
perform a final dependency check, configure the external group, submit once,
handle review outcomes, invite the first cohort, verify the tester journey, and
observe before expansion. Completion means the initial external beta is
operating safely, not that public App Store release is ready.
**Expected change:** TestFlight App Review has approved the candidate and the
monitored initial external cohort can complete the documented tester journey.

## Subtask plan

### TF-014.1 — Run external-release preflight

**Description:** As the release owner, I need to ensure the exact approved build
and operating plan remain valid. Verify TF-012 and TF-013 are `done`, no blocker/
high bug is open, metadata/contacts/rights/legal/IAP evidence is current, build
is externally eligible and not Internal Only, no same-version build is already
in review, and Apple’s submission-rate limit is not at risk. Record timestamp
and observed states. Any mismatch stops submission. The expected change is a signed
external-release preflight record.

### TF-014.2 — Configure the external group

**Description:** As the beta operator, I need a group matching the approved
cohort plan. Obtain the owner's explicit choice of `external_family` or
`external_family_and_friends`, record the mapping, and open that existing
DEC-011 group; do not create a duplicate. Attach only the internally verified
build, copy canonical What to Test, verify test information, choose automatic
notification exactly as approved, and keep the public link disabled unless
explicitly authorized. Save/reload and record group/build/settings. The
expected change is one review-ready selected group without invited testers yet.

### TF-014.3 — Submit once and monitor TestFlight App Review

**Description:** As Apple Review, I need one coherent build and metadata
submission. Recheck build and fields, click **Submit Review** once, record time
and status, and monitor without adding replacement builds while pending. Respond
to Apple messages through the authorized owner and keep a sanitized summary in
evidence. The expected change is an Approved or documented Rejected outcome; pending is
not completion. Stop and wait while review is pending instead of submitting a
duplicate build.

### TF-014.4 — Handle rejection without bypassing gates

**Description:** As the release team, I need rejection converted into traceable
corrective work. Capture Apple’s exact reason in a private-safe summary, classify
whether metadata, rights, account, IAP, or binary changes are required, create
repository bugs/tasks, and reset affected TF statuses. If the binary changes,
increment the build and rerun invalidated gates before resubmission. Never hide
functionality, create misleading reviewer instructions, or submit repeatedly
without resolving the cause. The expected change is a rejection disposition that names
the owning repository work and invalidated gates.

### TF-014.5 — Invite the approved initial cohort

**Description:** As approved external testers, we need controlled access after
Apple approval. Confirm TF-013 monitoring coverage is active, then invite only
the initial approved count by the chosen email/private-link method. If a public
link is authorized later, apply device/OS criteria and hard tester limit before
sharing. Record counts and distribution time without committing tester emails.
The expected change is a live first cohort within approved limits.

### TF-014.6 — Verify the external tester journey

**Description:** As the release owner, I need end-to-end proof an outsider can
participate. Have at least one external tester accept the invitation, install
the exact build, launch/onboard, view What to Test, perform a core action, and
submit TestFlight feedback. Record sanitized device/OS/build and results.
Invitation receipt alone is insufficient; install/launch/feedback must work.
The expected change is a sanitized end-to-end external tester journey record. Stop
rollout expansion if any stage of that journey fails.

### TF-014.7 — Observe, decide expansion, and close

**Description:** As beta operations, we need evidence before increasing
exposure. Monitor crashes, feedback, sessions, StoreKit/support reports, and
cultural/rights concerns for the TF-013 minimum observation period. Triage all
reports and apply stop criteria. The release owner records hold/expand/stop with
rationale. Mark TF-014 `done` only when the initial cohort is actively testing,
monitoring/stop controls work, and no release-blocking issue is open. The
expected change is the initial-cohort hold/expand/stop decision and final TF-014
evidence.

## Preconditions

- Internal group exists and TF-012 passed.
- TF-013 cohort/stop plan is approved.
- Test information and review contact are complete.
- No login credentials are needed.
- Audio/content/legal/privacy/IAP evidence is complete.
- The build is not marked TestFlight Internal Only.
- No other build of version 1.0 is currently in TestFlight review.

## Procedure

1. Record which existing DEC-011 external group the owner selects for the
   initial cohort, then open it in TestFlight. Do not create another group.
2. Add the exact internally verified build.
3. Enter What to Test from repository copy.
4. Verify Beta App Description, Feedback Email, review contact, and notes.
5. Confirm correct device/OS compatibility and product behavior.
6. Choose whether testers are automatically notified according to TF-013.
7. Click **Submit Review** once.
8. Record submission time/status. Do not submit replacement builds while review
   is pending unless the current build is withdrawn for a documented blocker.
9. If rejected, record Apple's reason in a private-safe repo summary, create
   tasks/bugs, fix, increment build as needed, and repeat invalidated gates.
10. After approval, invite only the first approved private cohort.
11. If using a public link later, apply approved device/OS criteria and tester
    limit before sharing it.
12. Confirm at least one external tester can accept, install, launch, and submit
    feedback.
13. Begin TF-013 monitoring; review results before expanding the cohort.

## Apple limits to respect

- Up to 10,000 external testers.
- One build per version in review at a time.
- Up to six TestFlight review submissions in 24 hours.
- First external build normally receives full TestFlight App Review.
- Builds expire after 90 days.

## Acceptance criteria

- [ ] External group contains the correct build and What to Test.
- [ ] TestFlight App Review approves the build.
- [ ] Initial cohort receives access.
- [ ] At least one external install/launch/feedback path succeeds.
- [ ] Monitoring and stop controls are active.
- [ ] Repository status, checklist, and completion report are updated before
  Jira/Notion mirrors.
- [ ] Evidence exists at `quality/evidence/testflight/TF-014.md`.

## Done definition

TF-014 may be `done` when the planned initial external cohort is actively
testing the approved build and no release-blocking issue is open. This does not
mean the app is ready for public App Store release.

## Apple sources

- https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers
- https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/
