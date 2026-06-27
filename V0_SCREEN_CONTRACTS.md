# V0 Screen Contracts — My Mandir (Digital Temple)

These contracts define the **doctrine boundaries** of each v0 screen. They are
binding: a screen may grow richer, but it must never drift into what it "must
NOT become." The north star is a *sacred relationship*, not engagement.

The v0 app is six screens: **Onboarding**, **MandirHome (Altar)**, **Offer**,
**Reflect**, **Thread**, and **Settings**. Offer, Reflect, and Thread are the
ritual surfaces selected in-place beneath the persistent altar (no tab bar).

---

## 1. Onboarding (5 steps)

- **Purpose.** Bring a person across the threshold from "an app" to "my
  mandir": welcome them, learn why they came, let them name the space, welcome
  devatas, and (gently) make a first sankalp.
- **Sacred relationship deepened.** Establishes the *who* (devotional identity),
  the *where* (a named mandir), the *before whom* (chosen devatas), and the
  first *vow* — the seeds of every later return.
- **Primary action.** Create the mandir and enter it. The first sankalp is
  strongly encouraged but skippable.
- **Data required.** Seeded `Devata` list (12). Writes: `DigitalMandir`,
  `DevotionalIdentity`, chosen `Devata.isChosen`, optional first `Sankalp`.
- **Empty state.** N/A — this *is* the empty-state of the whole app. Steps with
  no input keep their primary action disabled rather than showing emptiness.
- **Must NOT become.** A sign-up/account wall, a permissions gauntlet, a survey,
  a feature tour, or anything that asks for an email, phone number, or network
  identity. No step may be unskippable except naming the mandir.

---

## 2. MandirHome (Altar)

- **Purpose.** The anchor and emotional center: a quiet, living altar the person
  returns to. A persistent altar (header, lamp, mode selector) with the selected
  ritual surface beneath.
- **Sacred relationship deepened.** Presence. Lighting the lamp (hold the wick)
  is a deliberate act of returning — the heartbeat of the relationship,
  recorded as a `MandirReturn`.
- **Primary action.** Hold the wick to light the lamp (a return). Secondary:
  choose a mode (Altar / Offer / Reflect / Thread); open Settings via the gear.
- **Data required.** `DigitalMandir`, presiding `Devata`, held `Sankalp`
  (most-recent active), today's lit state (`hasReturnedToday`), next
  `SacredDateEntry`.
- **Empty state.** Unlit altar with the invitation "Hold the wick to light your
  lamp." If no sankalp is held: a calm invitation to hold an intention.
- **Must NOT become.** A dashboard, a feed, a home with stat cards, streaks,
  badges, counters, or notifications-bait. No tab bar. The lamp must never be a
  one-tap toggle — the effort is the point.

---

## 3. Offer

- **Purpose.** Let the person place a small, private offering before the altar —
  pushpa (flower), jal (water), deep (lamp), or vachan (a spoken word).
- **Sacred relationship deepened.** Giving. A wordless (or few-word) act of
  devotion that asks for nothing back; each offering becomes a return in the
  Thread.
- **Primary action.** Choose an offering kind and place it (writes a
  `MandirReturn` with an `OfferingKind`).
- **Data required.** Held `Sankalp` (optional, for dedication). Writes:
  `MandirReturn(offeringKind:note:)`.
- **Empty state.** N/A — always presents the four offering choices. `vachan`
  requires a word before it can be placed.
- **Must NOT become.** A store, a donation/payment flow, a catalog of premium
  offerings, or anything quantified ("you've offered 47 flowers!"). No real
  money, no virtual currency, no leaderboards.

---

## 4. Reflect

- **Purpose.** A moment of return spent with the held sankalp: name the inner
  weather (mood) and leave a few words. Also where a sankalp is fulfilled.
- **Sacred relationship deepened.** Remembering and honesty over time — the
  person watches their own relationship to a vow evolve.
- **Primary action.** Leave a reflection (writes `Reflection` + a `MandirReturn`
  with `reflectionId`). Secondary: fulfill the sankalp.
- **Data required.** Held `Sankalp`, its past `Reflection`s. Writes:
  `Reflection`, `MandirReturn`.
- **Empty state.** When no sankalp is held: "No intention is held yet" with an
  invitation to make a sankalp. When held but no past reflections: just the
  composer, no emptiness shown.
- **Must NOT become.** A mood tracker with charts, a journaling product with
  prompts/streaks, an AI that replies, or a sentiment-analysis surface. No
  scores, no "insights," no guru.

---

## 5. Thread

- **Purpose.** The woven, chronological record of the relationship — every
  return (lamp, offering, reflection) and every preserved memory, newest first.
- **Sacred relationship deepened.** Continuity and preservation: the person sees
  that they have, in fact, kept returning. This is the long memory of the
  mandir.
- **Primary action.** Read the thread. Secondary: preserve a memory (a moment,
  tradition, offering, or reflection worth keeping).
- **Data required.** `MandirReturn`s and `Memory`s for the mandir (merged,
  sorted by date). Writes (via the preserve sheet): `Memory`.
- **Empty state.** "Your thread is bare. Light the lamp, place an offering, or
  leave a reflection — each becomes a thread to return to."
- **Must NOT become.** A social feed, a shareable timeline, an activity log with
  engagement metrics, or anything sortable/filterable into a productivity view.
  It is read in one direction: backward, with reverence.

---

## 6. Settings

- **Purpose.** The few things that belong to a private sacred space: the
  devotional identity, a clear statement of privacy, and an about section.
- **Sacred relationship deepened.** Stewardship — the person tends the
  particulars of their space (its name, who presides, how they are known).
- **Primary action.** Edit the devotional identity (mandir name, display name,
  tradition leaning, presiding devata).
- **Data required.** `DigitalMandir`, `DevotionalIdentity`, chosen `Devata`s.
  Debug-only: `FeatureFlag` inspector.
- **Empty state.** N/A — always shows identity, privacy, and about.
- **Must NOT become.** An account center, a subscription/upgrade page, a
  notifications console, a data-sharing or social-connection hub, or a settings
  sprawl. No login, no "connect with friends," no analytics opt-outs for data
  that is never collected.
