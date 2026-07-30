# Gemini Agent Instructions

Read `.factory/repository-map.json`, `.factory/project-context.json`,
`.factory/standard-lock.json`, `docs/README.md`, and only the canonical
documents and feature contracts routed for the current task.

Treat `projectType` as authoritative. Report checks run, checks not run, known
issues, and remaining placeholders. `code_complete` is not `done`.
Search `.factory/library-catalog.json` before implementing generic
infrastructure and record reusable candidates in `docs/REUSABLE_COMPONENTS.md`.
