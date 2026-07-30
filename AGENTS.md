# Agent Instructions

<!-- APP-FACTORY:BEGIN -->
This repository is registered with the App Factory.

Use this context path before editing:

1. `AGENTS.md`
2. `.factory/repository-map.json`
3. `.factory/project-context.json`
4. `.factory/standard-lock.json`
5. `docs/README.md`
6. Only the canonical documents and feature contracts relevant to the task

Do not recursively read the entire repository by default. Use the repository
map and documentation index to retrieve the smallest authoritative context set.

The `projectType` in `.factory/project-context.json` is authoritative.
Before implementing cross-cutting infrastructure, read
`.factory/library-catalog.json` and `docs/REUSABLE_COMPONENTS.md`.
Do not mark work `done` unless required evidence exists. Use `code_complete`,
`verification_pending`, or `human_review_required` while gates remain.
<!-- APP-FACTORY:END -->

`ProductGuardrails.md` is binding for cultural framing, product boundaries,
tone, symbols, and gamification.

For TestFlight work, `docs/TESTFLIGHT_TASKS.md` and the matching file under
`docs/tasks/testflight/` are the canonical implementation instructions. Update
repository status and evidence before mirroring a task to Jira or Notion.
Repository state wins if an external copy disagrees.
