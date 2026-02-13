# Pre-Implementation Checklist

## Research
- [ ] Research file created in `docs/research/`
- [ ] `Project Mode` declared (`greenfield` or `existing`)
- [ ] Architecture and dependencies documented
- [ ] Edge cases and risks identified
- [ ] Security/performance analyzed

## Planning
- [ ] Plan file created in `docs/plans/`
- [ ] `Project Mode` matches research artifact
- [ ] Trade-offs explicitly documented
- [ ] Granular TODO list included
- [ ] Test strategy defined
- [ ] Rollout strategy defined

## Existing Mode Only
- [ ] Baseline reference (commit/tag) is defined
- [ ] Baseline artifact set is defined and available
- [ ] Context pack is defined and available
- [ ] Impacted modules are listed
- [ ] Backward compatibility strategy is explicit
- [ ] Rollback plan is explicit
- [ ] Regression test focus is explicit

## Annotation
- [ ] At least 2 iterations completed
- [ ] All notes addressed
- [ ] No open ambiguities
- [ ] `- Status: approved` set in the plan
- [ ] `Iteration 1` and `Iteration 2` marked `[x]`

## Gate
- [ ] `make validate-plan FILE=...` passed
- [ ] `make implementation-gate FEATURE=...` passed
- [ ] Explicit approval received

## Post-Implementation (Existing Mode Only)
- [ ] `make update-baseline FEATURE=... SUMMARY=... SOURCE_PATH=.` executed
- [ ] If touched paths changed, `TARGET_PATHS=...` passed to refresh context pack
- [ ] Baseline changelog entry appended
