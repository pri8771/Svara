# Svara — Product Guardrails

This document is the source of truth for **what Svara is and is not**. Every
feature, screen, label, and piece of content must be checked against it.
If a proposed feature conflicts with these guardrails, the feature is wrong —
not the guardrails.

Treat this file as a contract. It exists so that Svara never drifts into
becoming a virtual-temple / ritual-simulator app.

---

## 1. What Svara Is

Svara is a **daily spiritual wellness app rooted in Hindu culture** — think
*Headspace meets Duolingo* with a Hindu spiritual soul.

Its four pillars:

1. **Daily spiritual wellness** — short (≈3 minute) practices: a morning
   mantra, an evening prayer, a breath, a moment of gratitude.
2. **Mantra & sloka learning** — Duolingo-style, bite-sized lessons that teach
   meaning, not just repetition.
3. **Cultural reconnection** — the *why* behind festivals and traditions, in
   plain modern language, for people who grew up with them but were never told
   the stories.
4. **Stories & symbols** — deity tales organised by human themes (courage,
   wisdom, devotion, gratitude, stillness, inner strength).

Plus **gentle progress**: streaks, Svara Points, achievements — encouragement,
never pressure.

**Audience:** Indians aged 18–35, in India and across the diaspora.

---

## 2. What Svara Is Not

- ❌ **Not a religion app.** It does not instruct people how to be religious,
  prescribe correct belief, or take a doctrinal stance.
- ❌ **Not a ritual simulator.** No virtual puja, no tapping a screen to ring a
  bell or wave a diya, no on-screen offerings.
- ❌ **Not a virtual temple.** No darshan feeds, no temple live-streams, no
  "visit this temple" experiences.
- ❌ **Not a public social network.** No community feed, no public profiles,
  no follower mechanics, no comments, no public leaderboards in MVP.
- ❌ **Not a religious marketplace.** No booking priests, no ordering prasad,
  no buying ritual items, no temple donations/transactions.

---

## 3. Anti-Primandir Constraints (hard rules)

Svara must **never** resemble Primandir or any virtual-temple app. The
following are explicitly forbidden and are checked automatically by
`ContentValidation`:

**Forbidden feature concepts**
- Virtual puja / online puja flows
- Darshan feeds or darshan booking
- Temple live-streams ("live temple")
- On-screen offerings / prasad ordering
- Diya / bell / aarti tap-interactions as ritual simulation
- Booking priests / priest services
- Temple marketplace / religious e-commerce
- Ritual booking of any kind
- Public community / social feeds

**Forbidden user-facing terms** (case-insensitive; enforced in code):
`virtual puja`, `darshan booking`, `offerings`, `priest booking`,
`temple marketplace`, `live temple`.

> Note: religious *words* used educationally in story/lesson **body content**
> (e.g. explaining what a puja is) are acceptable. What is forbidden is
> shipping these as **features or feature labels**. The validator targets
> user-facing feature labels, titles, taglines, and CTAs.

---

## 4. Tone Principles

- **Warm, not preachy.** A kind friend, not a guru or an authority.
- **Inviting, not obligating.** "Take a mindful moment", never "You must".
- **Modern and grounded.** Connects ancient ideas to a 25-year-old's real life.
- **Inclusive.** Welcomes the curious, the lapsed, and the devout alike;
  assumes no prior knowledge and never shames a lack of it.
- **Calm.** Visual and verbal restraint. Space to breathe.

---

## 5. Copywriting Rules

- Use **plain English first**; introduce Sanskrit terms with a gloss.
- Prefer **invitations** ("Begin", "Take a moment") over **commands**.
- Never imply spiritual hierarchy, sin, punishment, or that the user is failing.
- Translate the *meaning and relevance* of content — answer "why does this
  matter to me?"
- Avoid absolutist religious claims ("this is the only true…"). Present
  tradition as living culture, with humility.
- Streak/points language is **encouraging**, never guilt-tripping
  ("Keep the flame alive" ✓ / "You broke your streak, shame!" ✗).
- No fear-based or scarcity-based spiritual messaging.

---

## 6. Gamification Ethics

Gamification exists to build a **gentle daily habit**, not to exploit.

- **No dark patterns.** No manipulative loss-aversion, no FOMO countdowns
  designed to induce anxiety, no pay-to-win spirituality.
- **Streaks are forgiving by design.** A missed day is a fresh start, framed
  kindly. (Future: streak freezes / grace days.)
- **Points are intrinsic-leaning.** Svara Points celebrate consistency; they
  buy nothing that pressures spending.
- **No public ranking** of devotion. Spiritual practice is not a competition.
- **Premium gates value, not guilt.** Free tier is genuinely useful; Plus adds
  depth, never removes basic dignity.
- **Honest notifications.** Reminders are helpful nudges at user-chosen times,
  not manufactured urgency.

---

## 7. Content Sensitivity Notes

- **Accuracy & respect.** Sanskrit, transliteration, translations, and stories
  must be sourced and handled with care; cite `sourceName` where possible.
- **Multiple traditions.** Hinduism is plural (regional, sampradaya, language
  differences). Avoid presenting one regional form as "the" correct one.
- **Festivals vary.** Dates and customs differ by region and calendar; present
  them as commonly observed, not absolute.
- **No appropriation framing.** Content celebrates and explains; it does not
  exoticise or commodify.
- **Inclusive of the diaspora.** Acknowledge growing up away from the cultural
  context; never assume fluency in Sanskrit, Hindi, or ritual.
- **Avoid medical/spiritual overclaims.** A breath practice calms; it does not
  "cure". Keep wellness claims modest and honest.
- **Human review.** All shipped devotional content should pass human review
  before release, in addition to automated `ContentValidation`. The release
  procedure and item-level sign-off are `TF-007` and
  `docs/CONTENT_REVIEW_SIGNOFF.md`.

---

## 8. Product Review Corrections (binding)

These corrections came out of product review and are **hard rules**, on the
same footing as the anti-Primandir constraints above.

### 8.1 Symbol system — no bell
The bell is **too temple-coded** and is removed from Svara's symbol system.
The canonical six symbols are:

> **Lotus · Diya · Om · Dawn · Mandala · Sunrise**

No bell icon may appear in the symbol system, the design system, or seed
content as a spiritual/brand symbol. (See `SvaraSymbol` in
`Core/DesignSystem/SvaraSymbol.swift`.) A plain notification glyph for
reminders is fine, but it must not be a bell.

- **Sunrise is the primary replacement for the bell** as Svara's hopeful,
  daily-renewal motif. Acceptable alternates if a slot is needed:
  Sound-wave or Orb.
- **Shankha / Conch is a secondary cultural symbol only** — it may appear as
  decorative/illustrative art but must **never be interactive** (no tap-to-blow,
  no sound-on-tap ritual interaction).

### 8.2 Learn tab — no "lives"
The Learn experience must **not** use a lives / hearts mechanic (no "lotus
lives", no losing hearts on a wrong answer). A punitive lives system makes
learning feel like failure. Instead:
- a **gentle hint system** for quiz steps, and
- simple **progress tracking** (steps completed, best score).
Getting an answer wrong shows the correct answer kindly and lets the learner
continue — it never costs a life or blocks progress.

### 8.3 Festivals — no game-economy loot
Do **not** attach game-economy items to sacred festivals. Specifically, there
is **no "streak-freeze gift" tied to Diwali** (or any festival). Festivals are
cultural moments, not loot drops.
- **Grace days** may exist later as a *general kindness mechanic* (a forgiving
  streak), but they are never framed as festival rewards or treated as
  collectible items earned from sacred occasions.

### 8.4 No doctrinal-authority content (binding)
Svara explains living culture; it never rules on belief. Content must **not**
instruct people in "correct belief", make absolutist religious claims, or use
sin/punishment framing. Prefer humble, plural framing — "One way to understand
this…", "Traditions vary by region and family…".

- Enforced by `ContentValidation.scanDoctrinalAuthority` (word-boundary matched
  doctrinal-authority phrases) and `DoctrinalAuthorityTests`. A flagged phrase in
  shipped content is a blocking validation error.

### 8.5 No user-to-user / social surface (binding)
Svara is **private, not a feed**. There is no community feed, public profile,
followers, comments, groups, chat, or public leaderboard — and no user-to-user
religious interaction. The only "profile" is the user's own local, private screen.

- Enforced structurally: the `MainTab` navigation registry has no social case,
  and `TabConfigurationTests.testNoSocialSurfaceInNavigationRegistry` fails if a
  social surface ever appears. Outbound OS share (handing a festival's text to
  the system share sheet) is permitted and flag-gated (`FeatureFlags.contentSharing`);
  it is not an in-app social graph.

### 8.6 Beta scope is configurable and tested
The focused beta is **Today + Learn primary**, with Festivals/Stories staged out
of primary navigation (`FeatureFlags.betaScope`). Today and Learn are the
irreducible core and can never be staged out; `TabConfigurationTests` fails if a
staged tab reappears as a primary beta surface. The shipping default
(`FeatureFlags.full`) is the complete product with all surfaces on.

## 9. How this is enforced in code

- `ContentValidation` (in `Core/Content/`) checks seed content for required
  fields, valid lesson ordering, parseable festival dates, present premium
  flags, and **forbidden Primandir-style terms** in user-facing labels.
- Unit tests (`SvaraTests/`) assert seed content decodes, validates, and is
  free of forbidden terms, and that shloka-of-day selection is deterministic.
- Any new content file or feature label is expected to pass these checks in CI.
