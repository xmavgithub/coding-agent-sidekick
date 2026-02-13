# Workflow Standard

## Principle
Separate thinking from execution.

## Session kickoff
- Start with a short natural-language command (`Iniziamo`, `Let's start`, or equivalent).
- Agent runs guided intake as defined in `docs/process/session-start.md`.
- Agent must keep user's language during kickoff.

## Optional adoption stage
If Sidekick is being installed into an already populated repository:
- run installer in `audit` mode first,
- then `install` mode,
- never overwrite existing files.
Reference: `docs/process/adoption-existing-repo.md`

## Modes
- `greenfield`: for new applications or new isolated subsystems.
- `existing`: for modifications to existing codebases.

Pipeline:
`Session Kickoff -> Research -> Planning -> Annotation -> Implementation -> Verification`

Existing-mode extension:
`Session Kickoff -> (Optional Safe Adoption) -> One-time Baseline Bootstrap -> Context Pack -> Research -> Planning -> Annotation -> Implementation -> Baseline Refresh -> Verification`

## Stage gates
- Session kickoff to Research:
  - kickoff intent recognized
  - user language preserved
  - first-task intake questions answered
  - feature slug and mode clarified
- Research to Planning:
  - complete research artifact
  - dependencies and edge cases identified
  - if `existing` mode: baseline artifacts and context pack available
- Planning to Implementation:
  - approved detailed plan
  - granular TODO list
  - pre-implementation checklist completed
  - `make implementation-gate FEATURE="<feature>"` passed
  - if `existing` mode: baseline, compatibility, rollback, and regression sections completed
- Implementation to Verification:
  - if `existing` mode: baseline updated with
    `make update-baseline FEATURE="<feature>" SUMMARY="<summary>" SOURCE_PATH="."`
  - if touched paths changed: include `TARGET_PATHS` to refresh context pack

## Operational target
- Maximum quality: explicit, testable, verifiable decisions.
- Maximum token efficiency: focused requests and reusable templates.
