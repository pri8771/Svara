# TF-006 — Publish and Verify Legal, Support, and Privacy Surfaces

- **Status:** `blocked`
- **Blocker:** repository source is corrected, but TF-001 has not confirmed the
  release/legal owner and production URL decision
- **Gate:** external TestFlight review
- **Execution type:** hybrid
- **Owner:** release/legal owner
- **Dependencies:** TF-001

## Objective

Publish the corrected repository-owned legal/support pages and prove that every
URL in the app and App Store metadata is live, accurate, and consistent with
the exact beta binary.

## Task description

**Summary:** Deploy the approved legal/support source and prove users and Apple
can reach the correct content. **User story:** As a beta tester, I want privacy,
terms, and support links that accurately describe the app I installed and give
me a real contact path. We review repository HTML against actual behavior,
obtain human legal approval, deploy through the known Pages workflow, verify
content—not only HTTP status—and test in-app navigation. This matters because
stale or generic pages can misrepresent data handling and fail review.
**Expected change:** Approved privacy, terms, and support pages are live over
HTTPS, match the shipped behavior and metadata, and open correctly from the app.

## Subtask plan

### TF-006.1 — Audit canonical source against the build

**Description:** As the legal owner, I need source copy grounded in current app
behavior. Compare `index.html`, `privacy.html`, and `terms.html` against the
final architecture, privacy manifest, local storage, notifications, IAP,
account absence, deletion semantics, contact, and SvaraLinks. Create a
requirement-to-paragraph checklist and correct factual mismatches in source.
Do not add legal promises unsupported by code. The expected change is internally
consistent source ready for legal review. Stop and create a factual blocker if
current behavior cannot be established.

### TF-006.2 — Obtain legal and contact approval

**Description:** As the organization responsible for the beta, I need an
authorized human to approve legal language and monitored support contact. Send
the exact source commit/diff to the TF-001 legal owner, capture approval date
and secure reference, and confirm the contact is monitored. Engineering review
is not legal approval. The expected change is a traceable approval; requested changes
must be applied and re-approved before proceeding. Stop without an authorized
approval reference.

### TF-006.3 — Deploy the approved commit

**Description:** As a user opening a URL, I need the approved source actually
served. Determine the repository’s real GitHub Pages source branch/folder or
workflow, merge the approved files through the normal process, and wait for the
deployment job to succeed. Record source and deployment commit SHAs and job
reference. Do not assume the current feature branch deploys or point metadata
at a temporary unapproved host. The expected change is a successful deployment record
for the exact approved source commit.

### TF-006.4 — Verify live transport and content

**Description:** As App Review, I need public pages that load without login and
contain the approved facts. From a clean network, verify HTTPS, HTTP 200,
redirect destination, titles, key phrases, support contact, and absence of
stale account/tracking claims using the provided `curl`/`rg` commands plus a
source-to-live comparison. The expected change is a timestamped content verification,
not merely a status-code screenshot. Any stale cache or content mismatch keeps
the task blocked.

### TF-006.5 — Verify in-app links on device

**Description:** As a tester, I need Profile → Settings links to open the
correct live pages. Install the current build on a physical device, open
Support, Privacy, and Terms individually, verify final URLs and readable
content, then return to the app successfully. Record model/OS/build and results.
Broken deep links, authentication prompts, or unreachable contact block the
task. The expected change is a three-link physical-device verification matrix.

### TF-006.6 — Reconcile metadata and close REL-006

**Description:** As TF-008, I need one set of production URLs. Compare deployed
URLs to `SvaraLinks.swift` and `AppStore/metadata.md`, update only real
differences, complete TF-006 evidence, resolve ASM-003 and REL-006, and update
task/checklist/status files. Mark `done` only when approved source, deployed
content, metadata, and in-app behavior all match. The expected change is one canonical
URL set plus closed ASM-003 and REL-006 records.

## Canonical source files

- `docs/index.html`
- `docs/privacy.html`
- `docs/terms.html`
- `Svara/Core/SvaraLinks.swift`
- `AppStore/metadata.md`

## Required URLs

- Support/marketing: `https://pri8771.github.io/Svara/`
- Privacy: `https://pri8771.github.io/Svara/privacy.html`
- Terms: `https://pri8771.github.io/Svara/terms.html`

## Procedure

1. Review the local HTML against current app behavior:
   - no account or credential collection;
   - local display name/progress/reflections;
   - no analytics, ads, tracking, or backend;
   - local notifications;
   - Apple-processed IAP;
   - deletion occurs by deleting app/local data;
   - current contact information.
2. Obtain legal-owner approval. An engineering agent cannot provide legal
   approval.
3. Determine the repository's actual GitHub Pages deployment branch/workflow.
   Do not assume the current feature branch is deployed.
4. Commit/merge the approved pages through the normal repository workflow.
5. Wait for Pages deployment completion.
6. From a clean network verify HTTP 200, TLS, correct title/body, and contact:

```sh
curl -fsS https://pri8771.github.io/Svara/ |
  rg 'priyansh.chordia@gmail.com|Support'
curl -fsS https://pri8771.github.io/Svara/privacy.html |
  rg 'does not create an account|No tracking'
curl -fsS https://pri8771.github.io/Svara/terms.html |
  rg 'local profile|App Store'
```

7. Open all three links from Profile → Settings on a physical device.
8. Confirm `SvaraLinks.swift` and `AppStore/metadata.md` match the deployed
   canonical URLs.
9. Record deployment commit SHA and verification timestamp.

## Acceptance criteria

- [ ] Legal owner approved current source.
- [ ] Correct source is deployed.
- [ ] All URLs return 200 over HTTPS.
- [ ] Support page exposes a monitored contact method.
- [ ] Live privacy/terms copy matches no-account/local-only behavior.
- [ ] In-app links open successfully.
- [ ] REL-006 is resolved.
- [ ] Evidence exists at `quality/evidence/testflight/TF-006.md`.

## Failure handling

If deployment serves stale copy, do not edit App Store metadata to point at an
unapproved temporary site. Fix the Pages source/deployment and verify again.

## Apple sources

- https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
