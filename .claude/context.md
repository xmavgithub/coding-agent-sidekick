# Project Context

This repository is an operational template for coding-agent-driven projects.
It starts without application code and focuses on process, standards, and guardrails.

## Priorities
1. Code quality.
2. Strict adherence to the approved plan.
3. Token efficiency.
4. Smooth first-session onboarding.

## Supported modes
- `greenfield`: build a new app or isolated subsystem.
- `existing`: evolve an existing codebase with compatibility safeguards.

In `existing` mode:
- Reuse baseline artifacts (`docs/baseline/*`) and context packs.
- Refresh baseline after coding-agent changes.

## Main rule
Never implement before research + plan + annotation cycle are completed.

## Session kickoff
If the user opens with a short start command (`Iniziamo`, `Let's start`, or equivalent intent in their language):
- keep the same user language,
- run guided intake first,
- then transition to workflow artifacts.
