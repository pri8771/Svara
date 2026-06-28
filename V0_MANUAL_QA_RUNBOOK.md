# My Mandir V0 — Manual Simulator + Screenshot Evidence Runbook

A step-by-step procedure for capturing **screenshot evidence** that the v0 build
satisfies [`V0_SCREEN_CONTRACTS.md`](./V0_SCREEN_CONTRACTS.md). Run this on a Mac
with Xcode; this repo's CI is a headless compile gate and cannot produce
per-screen screenshots.

- **Project:** `DigitalTemple.xcodeproj`  ·  **Scheme:** `DigitalTemple`
- **Bundle id:** `com.mymandir.digitaltemple`
- **Target device:** iPhone 16, iOS 18.5 (matches CI)
- **Toolchain:** Xcode 16.4

> Nothing here changes the app. It only builds, launches, navigates, and
> screenshots. No signing, no network, no accounts.

---

## 0. Prerequisites

```bash
# From the repo root, on the v0 branch:
git checkout claude/my-mandir-ios-v0-se5f3a
git pull --ff-only origin claude/my-mandir-ios-v0-se5f3a

xcodebuild -version          # expect Xcode 16.4
xcrun simctl list devices available | grep "iPhone 16"
mkdir -p ~/mymandir-evidence  # where screenshots will land
```

---

## 1. Build, install, and launch on a clean simulator

A **clean** simulator is required so you witness first-run onboarding and the
true empty states (Thread bare, no sankalp held).

```bash
# Boot the simulator and open the Simulator app window.
xcrun simctl boot "iPhone 16" 2>/dev/null || true
open -a Simulator

# Erase any prior state so onboarding starts fresh (optional but recommended).
xcrun simctl uninstall booted com.mymandir.digitaltemple 2>/dev/null || true

# Build for the simulator (no signing).
xcodebuild \
  -project DigitalTemple.xcodeproj \
  -scheme DigitalTemple \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  build

# Install and launch.
APP="build/Build/Products/Debug-iphonesimulator/DigitalTemple.app"
xcrun simctl install booted "$APP"
xcrun simctl launch booted com.mymandir.digitaltemple
```

Screenshot any screen at any time with:

```bash
xcrun simctl io booted screenshot ~/mymandir-evidence/<filename>.png
```

> Alternative: just press **▶︎ (Run)** in Xcode with the iPhone 16 simulator
> selected, and use **Simulator → File → Save Screen** (⌘S) instead of the CLI.

---

## 2. Offline confirmation (do this once, up front)

The app must run with **no network**. It makes no network calls by design, but
prove it visually:

```bash
# Optional belt-and-suspenders: install Apple's Network Link Conditioner and set
# it to "100% Loss", OR simply trust that no URLSession/Firebase code exists
# (verified at the code level) and confirm all content still appears below.
```

**Pass criteria:** Seeded devatas (12) appear in onboarding step 4 and the app
renders fully without any loading spinner, error, or "no connection" state.

---

## 3. Per-screen capture + contract checklist

Walk the screens in this order. For each, **(a)** navigate as described,
**(b)** verify the assertions, **(c)** capture the named screenshot, **(d)**
confirm none of the red-flag "must NOT" items are present.

### 3.1 Onboarding (contract §1)
**Navigate:** Fresh launch lands here (Welcome).
**Capture each step:**
- `01-onboarding-welcome.png` — Welcome
- `02-onboarding-intention.png` — "Why are you here?" (6 reasons)
- `03-onboarding-name.png` — Name your mandir (primary action disabled until named)
- `04-onboarding-devatas.png` — Choose devatas (12 seeded; multi-select)
- `05-onboarding-sankalp.png` — Optional first sankalp (skippable)

**Verify:** Naming is the only unskippable step; first sankalp is skippable.
**Red flags (fail if present):** any email/phone/account/sign-up field, a
permissions gauntlet, a survey, or a feature tour.

### 3.2 Altar — unlit (contract §2)
**Navigate:** Complete onboarding → you arrive at the altar home.
**Capture:** `06-altar-unlit.png`
**Verify:** Dim altar with a diya; caption **"Hold the wick to light your
lamp."**; mode selector shows Altar / Offer / Reflect / Thread; a gear (Settings)
in the header. If you made a sankalp, it appears as the held intention.
**Red flags:** any **tab bar**, stat cards, streaks, badges, counters, a feed/
dashboard, or a one-tap lamp toggle.

### 3.3 Altar — lit (contract §2)
**Navigate:** **Press and hold** the wick (~1.3s) until the ring fills.
**Capture:** `07-altar-lit.png`
**Verify:** Flame glows; caption changes to **"The lamp is lit. You are here."**
**Red flags:** lamp lighting from a single tap (it must require the hold).

### 3.4 Offer (contract §3)
**Navigate:** Tap **Offer** in the mode selector.
**Capture:** `08-offer.png`; then select **Vachan** and capture
`09-offer-vachan.png` (the "Place" button must be disabled until a word is typed).
**Verify:** Four kinds — Pushpa / Jal / Deep / Vachan. Placing writes a return.
**Red flags:** any price, currency, donation/payment, premium catalog, or counts
("you've offered 47 flowers").

### 3.5 Reflect (contract §4)
**Navigate:** Tap **Reflect**.
- If a sankalp is held: capture `10-reflect-held.png` — mood picker + composer +
  "Fulfill this sankalp".
- To see the empty state: from a fresh install without making a sankalp, Reflect
  shows **"No intention is held yet."** → capture `11-reflect-empty.png`.

**Verify:** Mood is a small set of honest options; words are free-form.
**Red flags:** mood charts, journaling prompts/streaks, an AI that replies, or
sentiment "insights"/scores.

### 3.6 Thread (contract §5)
**Navigate:** Tap **Thread**.
- Empty (fresh): **"Your thread is bare…"** → capture `12-thread-empty.png`.
- After lighting the lamp / placing an offering / leaving a reflection: entries
  appear newest-first → capture `13-thread-populated.png`.

**Verify:** Chronological, newest first; a **Preserve** action for memories.
**Red flags:** social/share affordances, engagement metrics, or sort/filter into
a productivity view.

### 3.7 Settings (contract §6)
**Navigate:** Tap the **gear** in the altar header.
**Capture:** `14-settings.png`
**Verify:** Three sections — devotional identity (tap to edit), a privacy
statement ("Everything stays on this device… makes no network calls"), and About
(name + version). A debug-only Feature Flag inspector is expected **only** in
Debug builds and is acceptable.
**Red flags:** an account center, subscription/upgrade page, notifications
console, login, "connect with friends," or data-sharing hub.

---

## 4. Evidence summary table (fill in)

| # | Screen | File | Contract § | Result (PASS/FAIL) | Notes |
|---|--------|------|-----------|--------------------|-------|
| 1 | Onboarding — welcome | `01-onboarding-welcome.png` | §1 | | |
| 2 | Onboarding — intention | `02-onboarding-intention.png` | §1 | | |
| 3 | Onboarding — name | `03-onboarding-name.png` | §1 | | |
| 4 | Onboarding — devatas | `04-onboarding-devatas.png` | §1 | | |
| 5 | Onboarding — sankalp | `05-onboarding-sankalp.png` | §1 | | |
| 6 | Altar — unlit | `06-altar-unlit.png` | §2 | | |
| 7 | Altar — lit | `07-altar-lit.png` | §2 | | |
| 8 | Offer | `08-offer.png` | §3 | | |
| 9 | Offer — vachan gated | `09-offer-vachan.png` | §3 | | |
| 10 | Reflect — held | `10-reflect-held.png` | §4 | | |
| 11 | Reflect — empty | `11-reflect-empty.png` | §4 | | |
| 12 | Thread — empty | `12-thread-empty.png` | §5 | | |
| 13 | Thread — populated | `13-thread-populated.png` | §5 | | |
| 14 | Settings | `14-settings.png` | §6 | | |

**Global guardrails (must all be PASS):**

- [ ] No tab bar anywhere — navigation is the altar mode selector + pushes.
- [ ] Lamp requires a deliberate hold (not a one-tap toggle).
- [ ] No streaks / points / badges / leaderboards / gamified UI.
- [ ] No Svara/gamified leftover screens.
- [ ] App launches and renders fully with no network.
- [ ] No account/sign-up/payment anywhere; Settings exposes no backend.

---

## 5. Attaching evidence to PR #1

1. Zip the folder: `cd ~/mymandir-evidence && zip -r mymandir-v0-evidence.zip .`
2. Drag the images (or zip) into a comment on PR #1, or attach to the PR
   description under a "Screenshot evidence" section.
3. Keep PR #1 in **Draft** until all 14 captures are PASS.
