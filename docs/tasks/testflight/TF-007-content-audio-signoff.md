# TF-007 — Complete Cultural-Content and Audio-Rights Sign-off

- **Status:** `blocked`
- **Blocker:** TF-001 has not assigned the cultural reviewer and rights owner;
  the underlying gate remains `human_review_required`
- **Gate:** App Factory completion and any external distribution
- **Execution type:** human review with agent-generated inventory
- **Owner:** cultural reviewer and rights owner from TF-001
- **Dependencies:** TF-001

## Objective

Establish review evidence—not just JSON status labels—for every shipped
user-facing content record and every bundled recording.

## Task description

**Summary:** Convert authored review claims into independent, item-level
cultural and rights evidence for the exact shipped content. **User story:** As a
tester and community member, I want devotional content and recordings that are
respectful, accurate, appropriately sourced, and legally distributable. We
freeze the inventory, obtain qualified human review, correct and re-review
issues, verify audio rights/quality, and rerun automated guardrails. This gate
exists because code tests cannot establish cultural accuracy, consent, or
copyright permission.
**Expected change:** The hash-frozen content and audio inventory has complete
item-level cultural, rights, quality, and automated evidence approving the
exact distribution set.

## Subtask plan

### TF-007.1 — Freeze content and audio inventory

**Description:** As reviewers, we need an exact immutable review scope. Record
the repository commit, enumerate every JSON filename/record ID, calculate file
hashes, enumerate all nine MP3 paths, and recalculate SHA-256 values. Compare
counts to the inventory table and `docs/CONTENT_REVIEW_SIGNOFF.md`. The expected
change is a 64-record plus nine-audio manifest tied to a commit. Stop if counts,
decoding, duplicate IDs, or hashes do not reconcile.

### TF-007.2 — Perform item-level cultural review

**Description:** As a user relying on respectful cultural education, I need a
qualified reviewer to examine every applicable item rather than trust embedded
`reviewStatus`. The assigned reviewer checks Sanskrit, transliteration,
pronunciation notes, translation, sourcing, plural/tradition framing, festival
dates, regional caveats, doctrinal/medical claims, pressure language, and
ProductGuardrails compliance. Record pass/fail and reviewer/date per item in
the sign-off document. No sampled review or anonymous “approved” value is
sufficient. The expected change is an item-level cultural review row for every record.
Stop the affected row when the reviewer lacks sufficient expertise or source
material; do not convert uncertainty into approval.

### TF-007.3 — Resolve and re-review content issues

**Description:** As the cultural reviewer, I need every discovered issue
traceable to a correction. Add each problem to the required issue log with
record ID, exact concern, required change, owner, and severity. An implementation
agent makes only the requested source change, updates the in-code fallback when
parity requires it, runs relevant tests, and records the resolution commit.
The reviewer then re-checks and signs that row. Any unresolved issue keeps the
parent blocked and invalidates affected hashes. The expected change is a closed,
reviewer-signed issue log tied to resolution commits.

### TF-007.4 — Establish rights for every audio file

**Description:** As the distributor, I need documented permission for each exact
recording. The rights owner completes every `docs/AUDIO_PROVENANCE.md` row with
creator/source, performer consent, copyright owner, license, TestFlight/App
Store permission, territories, duration, derivative rights, reviewer/date,
hash, and secure evidence reference. Possession of a file is not permission.
Remove or replace any asset whose rights cannot be proven, then update the
inventory and code references. The expected change is nine complete rights rows whose
hashes match the distribution files.

### TF-007.5 — Review audio content and technical quality

**Description:** As a listener, I need each recording to match its mantra and be
usable. On real playback equipment, the cultural/audio reviewers verify
pronunciation, correspondence to referenced text, clipping, noise, leading and
trailing silence, loudness consistency, and complete playback. Record device,
reviewer, result, and corrective action per file. A licensed but incorrect or
unusable recording does not pass. The expected change is a nine-file pronunciation and
technical-quality matrix. Block each failing file until it is corrected or
replaced and re-reviewed.

### TF-007.6 — Run final automated content gates

**Description:** As engineering, I need proof the human-approved files still
decode and satisfy executable guardrails. On the frozen final content commit,
run hashes and the full content validation, forbidden-term,
doctrinal-authority, seed parity, and review-gate tests. Record exact commands,
environment, counts, failures, and `.xcresult` reference. Fixes invalidate
affected review rows and require re-review before rerunning. The expected change is a
passing final content-gate run tied to the frozen commit. Stop on any nonzero
test result or hash mismatch.

### TF-007.7 — Approve the frozen distribution set

**Description:** As TF-008/TF-011, we need a clear legal and cultural go/no-go.
Confirm all 64 records are accounted for, all nine recordings have rights and
quality approval, hashes match, issue log is closed, and automated gates pass.
Both assigned owners sign the frozen commit in sanitized evidence. Resolve
REL-002/REL-003 and update task/status/checklist files only then; otherwise
record the precise remaining rows. The expected change is the dual-owner distribution
sign-off or an exact list of blocking inventory rows.

## Inventory

| Source | Records | Current authored status |
|---|---:|---|
| `seed_achievements.json` | 10 | no cultural status field |
| `seed_festivals.json` | 8 | 8 `humanReviewed` |
| `seed_lessons.json` | 9 | 8 `humanReviewed`, 1 `sourced` |
| `seed_mantras.json` | 10 | 8 `humanReviewed`, 2 `sourced` |
| `seed_shlokas.json` | 10 | 5 `humanReviewed`, 5 `sourced` |
| `seed_stories.json` | 10 | 10 `humanReviewed` |
| `seed_story_library.json` | 7 | 7 `reviewed` |
| `Svara/Resources/Audio/*.mp3` | 9 | rights fields pending |

An authored `reviewStatus` is a claim, not proof. The sign-off must identify the
reviewer, date, exact file/hash, scope, issues, and resolution.

## Cultural review procedure

1. Freeze the content commit SHA.
2. Generate a list of every record ID and source file.
3. A qualified reviewer checks:
   - Sanskrit/transliteration/pronunciation;
   - translation and interpretive humility;
   - source attribution;
   - regional/tradition caveats;
   - festival dates and approximate-date labels;
   - no doctrinal-authority, medical, guilt, fear, or ritual-simulation claims;
   - consistency with `ProductGuardrails.md`;
   - achievement/paywall language for pressure or spiritual hierarchy.
4. Record pass/fail/changes in `docs/CONTENT_REVIEW_SIGNOFF.md`.
5. Any content change invalidates its prior hash/sign-off; rerun content tests.

## Audio review procedure

For every row in `docs/AUDIO_PROVENANCE.md`, record:

- recording source and creator;
- performer identity or approved pseudonymous record;
- performer consent;
- copyright owner;
- license terms and permission for TestFlight/App Store distribution;
- permitted territories and duration;
- whether editing/derivatives are allowed;
- secure evidence location;
- reviewer/date;
- exact SHA-256.

Also review pronunciation, clipping/noise, consistent loudness, silence, and
whether the recording matches the mantra referenced in JSON.

If rights cannot be proven, remove/replace the file and corresponding app claim;
never mark it approved based on possession alone.

## Verification

```sh
shasum -a 256 Svara/Resources/Audio/*.mp3
xcodebuild test -project Svara.xcodeproj -scheme Svara \
  -destination 'platform=iOS Simulator,name=<available iPhone>' \
  CODE_SIGNING_ALLOWED=NO
```

Run the content validation, forbidden-term, doctrinal-authority, seed parity,
and content review gate tests. The exact final count must be recorded.

## Acceptance criteria

- [ ] Every one of 64 JSON records has an evidence row or explicit
  non-cultural product-copy review.
- [ ] Every devotional record has cultural/theological approval.
- [ ] All nine audio files have complete rights and performer evidence.
- [ ] File hashes match evidence.
- [ ] Automated content gates pass after final changes.
- [ ] REL-002 and REL-003 are resolved.
- [ ] Evidence exists at `quality/evidence/testflight/TF-007.md`.

## Do not

- Do not invent source, license, consent, or reviewer data.
- Do not store private identity documents or contracts in the public repo;
  store durable secure references.
