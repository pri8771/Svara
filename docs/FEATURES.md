# Features

## Product outcome

Help a user build a respectful, brief Hindu spiritual-wellness practice without
an account, ads, social pressure, or a network connection.

## MVP boundary

### Included

- Onboarding and local profile
- Daily practices and bundled mantra audio
- Aaroh lesson path and progress
- Festival moments and activities
- Stories, symbols, and private local reflections
- Gentle local reminders
- All bundled content available without payment in the owner testing build

### Excluded

- Backend accounts or sync
- Analytics, ads, and public social features
- Virtual rituals, marketplace, or doctrinal authority
- WidgetKit and remote content delivery

## Feature inventory

| ID | Feature | Status | Contract |
|---|---|---|---|
| FEAT-001 | TestFlight release candidate | verification_pending | `quality/feature-contracts/FEAT-001.json` |
| FEAT-002 | Daily practice and audio | human_review_required | covered by FEAT-001 |
| FEAT-003 | Aaroh learning path | human_review_required | covered by FEAT-001 |
| FEAT-004 | Festivals and stories | human_review_required | covered by FEAT-001 |
| FEAT-005 | Local progress and reminders | verification_pending | covered by FEAT-001 |
| FEAT-006 | Svara Plus | deferred; hidden in current build | covered by FEAT-001 |

Release readiness for these features is executed through
`docs/TESTFLIGHT_TASKS.md`. In particular, content/audio are gated by `TF-007`,
device accessibility by `TF-010`. End-to-end Svara Plus behavior remains
deferred to `TF-005` and `TF-012` before any future monetized build.
