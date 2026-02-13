# Workflow Standard

## Principle
Separate thinking from execution.

## Modes
- `greenfield`: for new applications or new isolated subsystems.
- `existing`: for modifications to existing codebases.

Pipeline:
`Research -> Planning -> Annotation -> Implementation -> Verification`

Existing-mode extension:
`One-time Baseline Bootstrap -> Context Pack -> Research -> Planning -> Annotation -> Implementation -> Baseline Refresh -> Verification`

## Stage gates
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
