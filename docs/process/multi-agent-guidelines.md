# Multi-Agent Guidelines

This repository is agent-agnostic. Do not bind workflow quality to a specific vendor model.

## Recommended role split
- Implementation agent:
  - Execute approved plans.
  - Update code, scripts, and artifacts.
  - Keep implementation aligned with TODO order.
- Validation agent:
  - Review plans before implementation.
  - Review diffs for regressions, risk, security, and scope creep.
  - Request corrections before merge.

## Recommended sequence
1. Implementation agent: create research + first plan draft.
2. Validation agent: review and challenge the plan.
3. Implementation agent: implement approved plan.
4. Validation agent: perform final review before merge.

For `existing` mode, all agents should start from baseline/context-pack artifacts and avoid full-repo scans.
