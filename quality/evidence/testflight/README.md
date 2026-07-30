# TestFlight Task Evidence

Create one file per task: `TF-###.md`.

Use this structure:

```markdown
# TF-### Evidence

- Date:
- Executor:
- Repository commit:
- Environment:
- Result: passed | failed | blocked | human_review_required

## Preconditions checked

- ...

## Actions performed

- ...

## TF-###.1 — Subtask title

- Inputs:
- Actions:
- Output:
- Result:

## Verification

| Check | Expected | Actual | Result |
|---|---|---|---|

## Artifacts

- Durable CI/App Store Connect/secure-record reference:

## Checks not run

- ...

## Remaining blockers

- ...
```

Never commit credentials, certificate material, provisioning profiles, API
keys, banking/tax data, private tester lists, private phone numbers, or
copyrighted source evidence that cannot legally be redistributed.
