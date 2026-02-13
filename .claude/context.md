# Project Context

This repository is an operational template for coding-agent-driven projects.
It starts without application code and focuses on process, standards, and guardrails.

## Priorities
1. Code quality.
2. Strict adherence to the approved plan.
3. Token efficiency.

## Supported modes
- `greenfield`: build a new app or isolated subsystem.
- `existing`: evolve an existing codebase with compatibility safeguards.

In `existing` mode:
- Reuse baseline artifacts (`docs/baseline/*`) and context packs.
- Refresh baseline after coding-agent changes.

## Main rule
Never implement before research + plan + annotation cycle are completed.
