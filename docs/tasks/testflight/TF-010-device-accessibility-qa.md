# TF-010 — Complete Manual Device, Accessibility, Audio, and Permission QA

- **Status:** `blocked`
- **Blocker:** the exact final build is not frozen by TF-009; the underlying
  manual gate remains `human_review_required`
- **Gate:** external TestFlight
- **Execution type:** hybrid
- **Owner:** QA owner
- **Dependencies:** TF-001, TF-009

## Objective

Verify the exact final build in scenarios automation and a single large
simulator cannot establish.

## Task description

**Summary:** Exercise the frozen candidate across required devices, assistive
settings, hardware, permissions, and primary workflows. **User story:** As a
beta tester—including someone using VoiceOver or large text—I want every
essential action to remain understandable, reachable, and truthful on supported
iPhones. We prepare a traceable matrix, execute focused workflow/hardware
passes, file reproducible defects, and require re-test. This matters because
simulator automation cannot establish real audio routing, notification delivery,
physical VoiceOver use, or all responsive layouts.
**Expected change:** The required physical-device and accessibility matrix
passes with no unresolved blocker/high issue and with reproducible evidence for
every row.

## Subtask plan

### TF-010.1 — Prepare the QA matrix and clean states

**Description:** As QA, I need every required coverage cell assigned before
testing. Create a matrix with smallest supported simulator, large simulator,
physical iPhone(s), minimum available iOS 17.x, current iOS, light/dark, default/
largest text, VoiceOver, fresh install, and persisted upgrade/relaunch. Record
device model, OS build, candidate commit/build, language/region, and tester.
Prepare repeatable reset instructions without deleting unrelated device data.
The expected change is a complete scheduled matrix; unavailable minimum hardware must be
explicitly escalated, not silently skipped. Stop execution until every required
cell has an assigned device/tester or recorded owner-approved resolution.

### TF-010.2 — Verify layout, appearance, and Dynamic Type

**Description:** As users on different iPhones, we need primary content and
actions to remain visible. On each required simulator/device combination, walk
onboarding, all shipped tabs, long readers, Settings, and paywall in light/dark
and default/largest Accessibility text. Check scrolling, wrapping, safe areas,
keyboard avoidance, rotation behavior if supported, contrast, truncation, and
reachable controls. Capture failures with screen/build/state. The expected change is a
pass/fail row for every matrix cell; clipped legal/price/action content is
blocking.

### TF-010.3 — Verify VoiceOver and motion/color alternatives

**Description:** As an assistive-technology user, I need logical navigation and
nonvisual state. On a physical iPhone, enable VoiceOver and traverse onboarding,
practice, lesson, settings/reminders, and paywall; verify labels, roles, values,
focus order, adjustable controls, announcements, selected state, and dismissal.
Also enable Reduce Motion and Differentiate Without Color where applicable.
Record exact issues. Unlabeled or unreachable essential actions, color-only
state, or missing purchase status blocks completion. The expected change is a
workflow-by-workflow assistive-technology result matrix.

### TF-010.4 — Verify primary workflows and persistence

**Description:** As a returning user, I need core actions to work once and
survive relaunch. Execute fresh onboarding/profile edit, practice rapid-tap and
completion, lesson correct/incorrect/hint/resume, festival activity, story
search/reflection, settings changes, background/foreground, force-quit, and
relaunch. Confirm points/streak are idempotent and private work persists locally.
Record expected/actual per workflow. Crash, data loss, duplicate reward, or
inescapable flow is blocking. The expected change is a persistence and primary-workflow
matrix tied to the candidate build.

### TF-010.5 — Verify real audio and route behavior

**Description:** As a listener, I need safe, controllable playback through real
hardware changes. Test every representative audio path with speaker, wired
headphones if available, Bluetooth, play/pause, rapid actions, incoming
call/Siri interruption, route removal/change, lock screen, background/foreground,
completion, and missing-file behavior. Confirm UI and audio state resynchronize
without overlapping playback or crash. Record device/accessory/scenario. Any
stuck, duplicated, or uncontrolled audio blocks completion.
The expected change is a device/accessory/interruption audio-routing matrix.

### TF-010.6 — Verify notification permission and delivery

**Description:** As a user controlling reminders, I need permission outcomes and
delivery reflected honestly. On a physical device, test first grant, first
denial, repeated enable after denial, Settings recovery, toggle rollback,
selected times, rescheduling, cancellation, and actual foreground/background
delivery. Record OS permission state and scheduled/delivered behavior without
capturing private notification content. False enabled state or missing recovery
path blocks the task. The expected change is a permission-state and actual-delivery
matrix from a physical device.

### TF-010.7 — Verify paywall accessibility and failure states

**Description:** As a potential purchaser, I need products, disclosures, legal
links, purchase, and restore controls accessible before spending. With largest
text and VoiceOver, verify product loading/empty/error, localized price and
selection announcements, purchase control, terms/privacy, cancellation,
pending, restore-empty, error/retry, and no premature entitlement. Do not use
this subtask as live TestFlight transaction proof—that belongs to TF-012. The
expected change is manual UI/accessibility evidence and filed defects.

### TF-010.8 — Triage, re-test, and close REL-005

**Description:** As the release owner, I need failures converted into actionable
work and passing rows rechecked after fixes. For each issue record reproduction,
expected/actual, candidate build, device/OS/settings, severity, artifact, and
owning bug. Binary fixes invalidate TF-009 and require the affected matrix to be
rerun on a new frozen candidate. Close REL-005 and mark TF-010 `done` only when
every required row passes and no blocker/high issue remains. The expected change is a
fully passing QA matrix and closed REL-005.

## Required matrix

| Dimension | Minimum coverage |
|---|---|
| Layout | smallest available supported iPhone simulator + current large iPhone |
| OS | minimum iOS 17.x where available + current supported iOS |
| Appearance | light + dark |
| Text | default + largest Accessibility size |
| Assistive tech | VoiceOver on a physical iPhone |
| Hardware | at least one physical iPhone |
| State | fresh install + upgrade/relaunch with persisted data |

Record exact model, OS build, build number, language/region, and text size.

## Workflow subtasks

### Onboarding/local profile

- Fresh install reaches content without login.
- Back/forward flow is escapable and essential actions remain reachable.
- Local display-name edit validates empty/whitespace input and persists.

### Today/practice/audio

- Start, pause/resume, complete, rapid-tap, background/foreground, and relaunch.
- Points/streak award exactly once.
- Audio: play/pause, speaker/headphones/Bluetooth, interruption by call/Siri,
  route change, lock screen, background/foreground, completion, and missing-file
  behavior.

### Learn

- Locked/free lesson state, correct/incorrect/hint, resume, completion, largest
  text, VoiceOver answer order, and no punitive lives language.

### Festivals/stories/reflections

- Long content scrolls; share sheet (if enabled) is cancellable.
- Reflections preserve input after recoverable failure and remain local.
- Search/filter/empty behavior and regional caveats remain understandable.

### Settings/notifications/legal

- Notification permission grant, denial, repeated denial, toggle rollback,
  selected times, actual delivery, and recovery through iOS Settings.
- Legal/support links open the deployed pages.

### Paywall

- Products load; selection and localized price are spoken by VoiceOver.
- Essential purchase/legal/restore controls remain reachable at largest text.
- Cancellation is silent, pending is explained, restore-empty is informative,
  and errors permit retry.

## Accessibility checks

- Meaningful labels/roles/values and focus order.
- No icon-only unlabeled actions.
- No essential information encoded only by color.
- Reduce Motion does not hide completion or navigation state.
- Contrast is usable in light/dark mode.
- No clipped price, legal disclosure, error, or destructive consequence.

## Acceptance criteria

- [ ] Every required matrix cell has pass/fail evidence.
- [ ] Every primary workflow passes VoiceOver and largest text.
- [ ] Audio interruption/route matrix passes.
- [ ] Notification denial/delivery passes.
- [ ] Persistence/relaunch passes.
- [ ] No blocker/high issue remains open.
- [ ] REL-005 is resolved.
- [ ] Evidence exists at `quality/evidence/testflight/TF-010.md`.

## Failure handling

Create a bug with reproduction, expected/actual, device/OS, screenshot/video,
severity, and owner. Any crash, data loss, inaccessible primary action, false
purchase state, or silent entitlement error blocks downstream work.
