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
1. Implementation agent: handle session kickoff if user starts with a short start command (`Iniziamo`, `Let's start`, or equivalent), preserving user language and gathering intake data.
2. Implementation agent: create research + first plan draft.
3. Validation agent: review and challenge the plan.
4. Implementation agent: implement approved plan.
5. Validation agent: perform final review before merge.

For `existing` mode, all agents should start from baseline/context-pack artifacts and avoid full-repo scans.
