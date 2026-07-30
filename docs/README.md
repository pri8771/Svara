---
id: DOC-INDEX
canonicalFor: documentation-navigation
status: active
lastVerified: 2026-07-29
readWhen:
  - onboarding
  - locating authoritative project information
related:
  - ../.factory/repository-map.json
supersedes:
  - PROJECT_DOCUMENTATION.md
---

# Documentation Index

## Purpose

Use this index to find the smallest authoritative document set. Do not scan
every document by default. Repository documents are authoritative; Jira and
Notion are non-authoritative mirrors.

## Two-minute project context

Read in order:

1. `../AGENTS.md`
2. `../.factory/repository-map.json`
3. `../.factory/project-context.json`
4. `STATUS.md`
5. `ARCHITECTURE.md`
6. only the task-relevant documents below

## Canonical documents

| Topic | Canonical document | Authority |
|---|---|---|
| Project identity and type | `../.factory/project-context.json` | Machine-readable project classification |
| Standards and catalog versions | `../.factory/standard-lock.json` | Installed central versions |
| Repository navigation | `../.factory/repository-map.json` | Reading and location map |
| Product/cultural boundaries | `../ProductGuardrails.md` | Binding product and content rules |
| Current status | `STATUS.md` | Current progress, blockers, next action |
| Current architecture | `ARCHITECTURE.md` | Implemented architecture |
| Feature inventory | `FEATURES.md` | Current feature state |
| Required feature behavior | `../quality/feature-contracts/` | Acceptance and state contracts |
| Current release tasks | `TESTFLIGHT_TASKS.md` | Canonical backlog, order, dependencies, status |
| Detailed task procedures | `tasks/testflight/` | Executable task instructions |
| Apple beta requirements | `APPLE_TESTFLIGHT_REQUIREMENTS.md` | Official-source research baseline |
| Current bugs | `BUGS.md` | Known defects and blockers |
| Decisions | `DECISIONS.md` | Approved and explicitly pending decisions |
| Risks and assumptions | `RISKS.md`, `ASSUMPTIONS.md` | Active uncertainty and mitigation |
| Testing | `TEST_PLAN.md` | Environments and required coverage |
| Latest UI workflow audit | `../quality/evidence/UI-WORKFLOW-AUDIT-2026-07-30.md` | Simulator workflow results, defects, and blocked combinations |
| Release gates | `RELEASE_CHECKLIST.md` | Gate-oriented checklist |
| App Store copy | `../AppStore/metadata.md` | Repository-owned metadata source |
| Content/audio approval | `CONTENT_REVIEW_SIGNOFF.md`, `AUDIO_PROVENANCE.md` | Human review records |
| Reusable code | `REUSABLE_COMPONENTS.md` | Catalog review and local candidates |
| Handoff | `HANDOFF.md` | Next-agent context |

## Task-based reading routes

### Execute one TestFlight task

1. `TESTFLIGHT_TASKS.md`
2. `tasks/testflight/README.md`
3. the assigned `TF-###` file
4. only its listed inputs and evidence template

### Implement or change a feature

1. `STATUS.md`
2. `ARCHITECTURE.md`
3. `FEATURES.md` and the relevant feature contract
4. `../ProductGuardrails.md`
5. `TEST_PLAN.md`

### Fix a bug

1. `BUGS.md`
2. the owning `TF-###` task, if present
3. the relevant feature contract
4. `ARCHITECTURE.md`
5. `TEST_PLAN.md`

### Add infrastructure or a dependency

1. `../.factory/library-catalog.json`
2. `REUSABLE_COMPONENTS.md`
3. `ARCHITECTURE.md`
4. `DECISIONS.md`

### Prepare or operate the beta

1. `STATUS.md`
2. `TESTFLIGHT_TASKS.md`
3. `APPLE_TESTFLIGHT_REQUIREMENTS.md`
4. `RELEASE_CHECKLIST.md`
5. current bugs, risks, assumptions, and waivers

## Historical and superseded documents

| Document | Status | Superseded by | Reason retained |
|---|---|---|---|
| `PROJECT_DOCUMENTATION.md` | superseded | `README.md` | Redirect for older links |
| `../quality/completion-reports/` | historical evidence | current canonical docs | Records prior completed work |
| `../quality/evidence/TESTFLIGHT-READINESS-2026-07-29.md` | baseline evidence | per-task evidence under `../quality/evidence/testflight/` | Preserves the initial local audit |

## Documentation gaps

- `DEC-005` remains pending until `TF-001` records owner-approved release
  configuration.
- Apple account, signing, App Store Connect, and product state require
  authorized external verification.
- Cultural/content and audio-rights evidence require assigned human reviewers.
- Current legal source is corrected but production deployment remains
  unverified.
