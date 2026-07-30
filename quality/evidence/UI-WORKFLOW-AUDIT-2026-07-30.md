# UI Workflow Audit — 2026-07-30

> **Build 2 remediation update:** The failures documented below are historical
> discovery results. `UI-001`, `UI-002`, `UI-003`, `UI-005`, and `UI-008` now
> pass automated regressions. `UI-006`, `UI-007`, `UI-009`, `UI-010`, and
> `UI-014` have code changes recorded in `docs/BUGS.md`; physical-device
> audio/notification/VoiceOver checks remain under TF-010. Commerce findings
> remain deferred while Plus is disabled.

> **Subsequent product change:** `DEC-006` disabled Plus and made all bundled
> content free for owner testing later on 2026-07-30. Findings `UI-004`,
> `UI-011`, and `UI-012` remain historical requirements for a future monetized
> build, not active free-build failures. Focused post-change evidence is
> `/private/tmp/SvaraFreeMode-20260730.xcresult`.

## Result

Svara is **not UI-release-ready**. The simulator suite can traverse the shipped
surface without crashes, but four user-visible product defects are reproduced
by automation, the syllable-order control is not exposed as an accessible
button, and several additional failure paths are unsafe by source inspection.
The app can still be used for a private owner-only exploratory build if these
known failures are accepted; this report is not release acceptance evidence.

## Scope and interpretation

The request for every combination and permutation is bounded to every shipped
workflow, every shipped content item where the item can change navigation, all
meaningful states of each workflow, and pairwise global presentation states.
A literal Cartesian product is neither finite nor useful: time, locale, text
input, notification state, StoreKit history, audio route, and repeated actions
create unbounded combinations.

The audit therefore covers:

- all five primary tabs;
- onboarding skip from every page and returning-user relaunch;
- all four daily practices, including both audio-backed practices;
- all eight non-premium lessons, all lesson step kinds, the ninth premium
  lesson gate, progress, revisit, and cross-entry behavior;
- all eight festival details, all region filters, save state, and all eight
  festival activities;
- all seven stories, all 21 symbol sheets, search/no-result behavior, and
  reflection persistence;
- profile, display-name validation/persistence, reminders, achievements, and
  paywall unavailable-catalog behavior;
- a large current iPhone simulator and a smaller current iPhone simulator with
  dark mode and maximum accessibility text.

Per owner direction, only simulator results are acceptance evidence. Physical
device output is excluded.

## Environment and durable evidence

| Evidence | Environment | Result |
|---|---|---|
| Consolidated suite | iPhone 17 Pro, iOS 26.4.1 Simulator | 13 tests: 8 passed, 4 expected product failures, 1 environment skip, 0 unexpected failures |
| Story/symbol corpus | iPhone 17 Pro, iOS 26.4.1 Simulator | 1 passed, 0 failed: all seven stories and all 21 symbol sheets |
| Festival corpus | iPhone 17 Pro, iOS 26.4.1 Simulator | 1 passed, 0 failed: all eight region filters, details, guided activities, saved states, and return paths |
| Small-device presentation | iPhone 17e, iOS 26.4.1 Simulator; dark mode; accessibility XXXL | Passed |
| Prior full automated baseline | iPhone 17 Pro, iOS 26.4.1 Simulator | 136 passed, 0 failed, 0 skipped |

Local result bundles:

- `/private/tmp/SvaraFullUI-Consolidated-20260730.xcresult`
- `/private/tmp/SvaraFullUI-Corpus-20260730.xcresult`
- `/private/tmp/SvaraFullUI-Festivals-20260730f.xcresult`
- `/private/tmp/SvaraFullUI-Lessons-20260730b.xcresult`
- `/private/tmp/SvaraFullUI-Small-20260730.xcresult`
- `/private/tmp/SvaraTFTests-20260729b.xcresult`

These bundles are local/ephemeral and are not committed. This audit was run
against a working tree containing pre-existing uncommitted release-readiness
changes, so it must not be substituted for `TF-009` on a frozen candidate SHA.

## Workflow results

| Area | Workflow and states exercised | Result |
|---|---|---|
| Onboarding | Fresh launch; skip from pages 1, 2, and 3; relaunch after each; returning launch bypasses onboarding | PASS |
| App shell | Today, Learn, Festivals, Stories, and Profile tab selection | PASS |
| Layout | Large/small simulators; default presentation; dark mode plus maximum accessibility text; primary actions remain reachable | PASS, with accessibility defect `UI-005` below |
| Today reading | Mantra card → Sanskrit/transliteration/translation → back | PASS |
| Today shloka | Shloka card → related content route | PASS |
| Daily practices | Open, begin, finish-now, result, done, completion state for Morning Mantra, Midday Reset, Evening Prayer, and Three Gratitudes | PASS |
| Practice audio | Play and pause Morning Mantra and Evening Prayer; non-audio practices do not invent an audio button | PASS in Simulator; interruption/route/lock behavior not simulator-validated |
| Repeat practice | Complete the same practice twice and compare points | **FAIL — `UI-001`** |
| Learn core | Complete all eight non-premium lessons | PASS for ordinary touch |
| Lesson variants | Intro, listen/audio, meaning, reflection, match-meaning, fill-blank, multiple-choice, hint, gentle non-match feedback, syllable order, result, done | PASS for ordinary touch |
| Lesson resume | Advance to lesson step 2, close, reopen | **FAIL — `UI-002`** |
| Aaroh sequence | Open a locked Day 3 lesson from a story cross-link | **FAIL — `UI-003`** |
| Premium gate | Open premium lesson from Learn | PASS: paywall appears |
| Premium gate parity | Open the same recommended premium lesson from Today | **FAIL — `UI-004`** |
| Syllable accessibility | Locate and activate each syllable as an accessible button | **FAIL — `UI-005`**; coordinate touch completes the lesson |
| Festivals | All eight festival cards/details; all eight region filters; required detail sections | PASS |
| Festival save | Save every festival and verify saved state | PASS |
| Festival activity | Complete every step and result flow for all eight festival activities | PASS |
| Festival share | App-owned share action is present by source; system share-sheet destinations | BLOCKED: system-owned UI, not included in deterministic suite |
| Stories | Search and open all seven stories; no-result search; clear search | PASS |
| Symbols | Open and dismiss all 21 symbol detail sheets | PASS |
| Reflections | Empty and pre-existing reflection states; disabled empty save; save text; display persisted text | PASS for successful writes; write-failure handling is unsafe (`UI-008`) |
| Related content | Story → lesson cross-link | Navigation works, but lock enforcement fails (`UI-003`) |
| Profile | Streak/points/achievement surface; settings navigation | PASS |
| Display name | Whitespace rejection; valid save; relaunch persistence | PASS |
| Reminders | Enable; deny prompt when available; toggle rolls back; relaunch | PASS for denial rollback; recovery and rapid edits remain unsafe (`UI-007`) |
| Paywall shell | Profile → paywall; unavailable-catalog message; close | PASS |
| StoreKit catalog/purchase | Three products, selection, purchase outcomes, restore, expiry/refund/revocation | BLOCKED: XCUI cannot inject the fixture into the separately launched app; requires interactive StoreKit or TestFlight sandbox work in `TF-005`/`TF-012` |
| App relaunch | Onboarding, display name, completed practice/lesson, saved festival, and reflection state | PASS where exercised; the UI reset hook does not clear reflection files |

## Confirmed broken workflows

### UI-001 — A completed practice can award points repeatedly

Completing Morning Mantra twice changed the profile from `Svara Points: 40` to
`Svara Points: 55`. `LocalProgressService.recordSession` appends every session
and always adds its points; it does not enforce one award per practice/day.
This breaks point integrity and contradicts the UI's completed-today state.

### UI-002 — “Continue” restarts a lesson

Step progress is persisted, but `LessonPlayerView` initializes `index` to zero
on every presentation and never derives a resume index from `LessonProgress`.
Closing after the listen step and reopening shows “Meet Om” again.

### UI-003 — Story links bypass Aaroh sequence locks

The Learn course checks `AarohPath.isUnlocked`, but `StoryDetailView` assigns
its related lesson directly to a full-screen cover. A fresh profile can open
the locked Day 3 “Meet Vakratunda” lesson from the Ganesha story.

### UI-004 — Today bypasses the premium gate

Learn checks `lesson.isPremium && !env.isPremium` and presents the paywall.
Today assigns the recommended lesson directly to `activeLesson`. After the
eight free lessons are complete, Today opens “A Prayer for All” without a
verified entitlement.

### UI-005 — Syllable chips are not accessible controls

The syllable-order screen exposes the container as “Available syllables” but
does not expose `vak`, `ra`, `tun`, and `da` as buttons or individually
labelled elements. Coordinate touch can complete the workflow; accessibility
automation cannot. Treat this as a VoiceOver blocker until verified and fixed.

## Additional source-audit defects

These are deterministic implementation defects or unsafe failure paths found
while tracing every workflow. They are not claimed as separate runtime
reproductions unless stated above.

| ID | Area | Finding |
|---|---|---|
| UI-006 | Learn | Locked course nodes remain enabled and silently do nothing; no explanation is presented. |
| UI-007 | Notifications | Permission denial only turns the toggle off; there is no Settings recovery action. The `isSavingReminders` guard also drops hour changes made while a save is running. |
| UI-008 | Reflections | Encoding and file-write errors are swallowed. The editor dismisses and can imply success even when persistence failed. |
| UI-009 | Achievements | When several achievements unlock together, only the first toast is shown and then the entire pending array is cleared. |
| UI-010 | Lesson result | Replaying a completed lesson does not award points, but the result view can still claim points were earned. |
| UI-011 | Paywall copy | “Unlock every lesson, story and festival” overstates current gating; stories/festivals are not premium-gated. |
| UI-012 | StoreKit recovery | Product-load failure shows generic unavailable copy without a Retry action. |
| UI-013 | Accessibility | Profile settings and paywall close are icon-only controls without useful explicit accessibility labels. |
| UI-014 | Audio robustness | Playback supports play/pause, but no interruption, route-change, or background/lock recovery handling is implemented. |

## Combinations not truthfully closed by simulator automation

- live App Store Connect product availability and verified purchase;
- pending/cancelled purchase dialogs, subscription renewal, expiry, refund, and
  revocation in Apple's sandbox;
- actual notification delivery, system Settings recovery, and time-zone/DST
  delivery behavior;
- headphones/Bluetooth routes, phone-call interruption, lock-screen controls,
  and background audio behavior;
- human VoiceOver traversal quality and cultural/content judgment;
- OS share-sheet destination apps and third-party extensions;
- iOS 17 runtime behavior because that simulator runtime is not installed.

These are not passes. They remain `verification_pending`,
`human_review_required`, or `external_blocked` under the matching TestFlight
tasks.

## Recommendation

Fix `UI-001` through `UI-005` before calling the UI ready. Fix `UI-007`,
`UI-008`, `UI-010`, and `UI-013` before broad beta use. Reconcile `UI-011`
before enabling commerce. Then rerun this suite on a frozen candidate commit
and execute the blocked Apple/system scenarios under `TF-010` and `TF-012`.
