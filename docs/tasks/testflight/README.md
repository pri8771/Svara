# TestFlight Task Execution Rules

Each `TF-###` file is executable work instruction for one bounded task.

## Task and subtask contract

Every task owns numbered subtasks in the form `TF-###.N`. The task file is the
only authority for those subtasks. Jira and Notion may copy them but must retain
the exact IDs.

Each task and subtask description must concisely answer all five implementation
questions:

1. **Summary:** What bounded outcome is required?
2. **What are we doing?** What actions and repository/external surfaces are in
   scope?
3. **Why are we doing it?** What release risk or user need does it address?
4. **What change do we expect?** What observable repository or external state
   must exist afterward?
5. **How are we doing it?** What ordered procedure, inputs, checks, and stop
   conditions let a lower-capability agent execute without guessing?

The answers may be one cohesive paragraph rather than five labeled sections.
Every description must also name the evidence or artifact that proves the
expected change. A user story may supply the actor and need, but does not
replace any of the five answers.

A lower-capability agent executes subtasks in numeric order unless the task
explicitly permits parallel work. It performs only the stated action, verifies
the expected change, records evidence, and stops at the named boundary. The
parent task cannot be `done` until every subtask output and every parent
acceptance criterion exist.

## Before starting

1. Read `AGENTS.md` and all required factory files.
2. Read `docs/TESTFLIGHT_TASKS.md`.
3. Confirm every listed dependency is `done`; otherwise stop and record the
   exact blocker.
4. Record the starting branch, commit SHA, and worktree status.
5. Never overwrite unrelated user changes.
6. Locate the assigned `TF-###.N` subtask and execute only its stated scope.
7. If an input comes from TF-001, an owner, Apple, or a secure record, never
   invent a replacement value.

## While executing

- Repository files are authoritative. App Store Connect, Jira, and Notion are
  external systems that mirror or consume repository decisions.
- Do not invent owner names, phone numbers, legal entity details, tax answers,
  SKU values, territories, prices, licenses, reviewer identity, or consent.
- Do not expose certificates, private keys, provisioning profiles, App Store
  Connect tokens, tax data, banking data, tester email lists, or phone numbers
  in committed evidence.
- Use the exact bundle/product IDs already recorded unless TF-001 explicitly
  changes them.
- If the live Apple UI differs from the documented route, use the equivalent
  current field, capture the difference in evidence, and update
  `docs/APPLE_TESTFLIGHT_REQUIREMENTS.md`.
- A successful click is not completion. Verify the resulting state.

## Evidence

Create or update `quality/evidence/testflight/TF-###.md` using the template in
`quality/evidence/testflight/README.md`. Evidence may reference secure external
records, but must not copy secrets or sensitive personal/business data.
Use one evidence heading per subtask, for example `## TF-003.2`, and record its
inputs, actions, observed result, and artifact reference.

## Finishing a task

1. Check every acceptance criterion in the task file.
2. Update the task status in both its file and `docs/TESTFLIGHT_TASKS.md`.
3. Update applicable rows in `docs/RELEASE_CHECKLIST.md`, `docs/BUGS.md`,
   `docs/RISKS.md`, and `docs/ASSUMPTIONS.md`.
4. Update `docs/STATUS.md` and `docs/HANDOFF.md`.
5. Update the feature contract/completion report if behavior or verification
   changed.
6. Only after the repository is updated, copy the same status and repository
   link to Jira/Notion.

## Jira/Notion mirror contract

Every mirror contains:

- exact task ID and title;
- repository path to the task file;
- repository commit SHA last synchronized;
- status copied from the repository;
- owner and dependencies;
- no acceptance criteria that are absent from the repository.

If a mirror disagrees with the repository, the repository wins and the mirror
must be corrected.
