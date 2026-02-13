# Plan Template

## Metadata
- Feature:
- Owner:
- Date:
- Status: draft | approved
- Project Mode: <greenfield|existing>
- Target Paths:
- Related research:
- Baseline Reference (commit/tag): N/A
- Compatibility Constraints: N/A
- Baseline Artifact Set: N/A
- Context Pack: N/A

## 1. Business Requirement
Describe user story and acceptance criteria.

## 2. Technical Scope
- In scope:
- Out of scope:

## 3. Constraints
- Performance:
- Security:
- Compatibility:
- Accessibility:

## 4. Technical Approach and Trade-Offs
Describe options and chosen approach.

## 5. Implementation Plan
List concrete steps and file-level intent.

## 6. Existing Codebase Impact (Mode: existing only)
For `existing` mode, replace `N/A` with concrete values before approval.
- Impacted modules: N/A
- Backward compatibility strategy: N/A
- Migration strategy: N/A
- Rollback plan: N/A
- Regression test focus: N/A

## 7. Data and API Changes
Document schema/payload changes and compatibility.

## 8. Test Plan
- Unit:
- Integration:
- End-to-end:

## 9. Monitoring and Rollout
Metrics, logs, alerts, feature flags, rollout phases.

## 10. Token Efficiency Plan
- Prompt scope limits:
- Reusable references:
- Stop conditions to avoid rework:

## 11. TODO
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## 12. Annotation Notes
Track review notes and how they were addressed.
- [ ] Iteration 1 completed
- [ ] Iteration 2 completed

## 13. Baseline Maintenance (Mode: existing only)
- [ ] Run baseline refresh after code changes:
  `make update-baseline FEATURE="<feature>" SUMMARY="<summary>" SOURCE_PATH="."`
- [ ] If touched paths changed, run with `TARGET_PATHS="path/a,path/b"` to refresh context pack
