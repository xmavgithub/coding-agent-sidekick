# IMPLEMENTATION COMMAND

Implement `docs/plans/{{SLUG}}-plan.md`.

## Rules
1. Follow TODO order exactly.
2. Do not introduce extra scope.
3. Update plan task status while working.
4. Stop and report when blocked or ambiguous.
5. Respect `Project Mode` constraints from the approved plan.

## Quality Gates
- Keep style consistent.
- No unjustified `any`/`unknown`.
- Add or update tests as planned.
- Keep typecheck/lint/tests passing.

## Completion Criteria
- Plan TODO items all completed.
- Verification checklist completed.
- No unresolved blockers.
- For `existing` mode: regression and rollback checks completed.
- For `existing` mode: baseline refreshed and changelog updated.
