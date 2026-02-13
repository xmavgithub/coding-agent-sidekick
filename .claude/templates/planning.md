# PLANNING REQUEST: {{FEATURE_NAME}}

## Project Mode
`{{PROJECT_MODE}}` (`greenfield` or `existing`)

## Business Requirement
Describe user story and acceptance criteria.

## Technical Scope
Define what is in scope and what is explicitly out of scope.

## Constraints
- Performance targets
- Security constraints
- Backward compatibility
- Accessibility requirements

## Deliverable
Write plan to `docs/plans/{{SLUG}}-plan.md`.

The plan must include:
1. Technical approach and trade-offs
2. Concrete implementation details
3. Existing-codebase impact (when mode is `existing`)
4. Data/API changes
5. Security controls
6. Testing strategy
7. Monitoring/observability
8. Rollout strategy
9. Granular TODO checklist

If mode is `existing`, include:
- Baseline reference (commit/tag)
- Baseline artifact set and context pack references
- Impacted modules
- Backward compatibility strategy
- Rollback plan
- Regression test focus

Do not implement anything.
