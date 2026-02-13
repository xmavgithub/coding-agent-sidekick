# AGENTS

This project uses a multi-agent model. The rules below apply to all agents.

## Shared objective
- Follow the workflow: `Research -> Planning -> Annotation -> Implementation`.
- Do not introduce code outside the approved plan scope.
- Keep artifacts and code aligned: the plan is the source of truth.

## Recommended operating model
- Use one implementation agent for execution against the approved plan.
- Use a different validation agent for review, risk detection, and quality checks.
- Keep both roles vendor-agnostic: any coding agent can fill either role.

## Operating rules
1. No implementation without an approved plan.
2. Every feature must include at least:
   - `docs/research/<name>-research.md`
   - `docs/plans/<name>-plan.md`
3. Architecture decisions go to `docs/decisions/`.
4. PRs must follow the template and pass CI checks.
5. Commits must follow Conventional Commits.
6. Beginner contributors must use the guided path in `docs/process/start-here.md`.
7. In `existing` mode, use baseline/context-pack artifacts and refresh baseline after coding-agent changes.

## Agent handoff format
- Context: what was decided and why.
- Status: done/in-progress/blocked tasks.
- Artifacts: updated files with full paths.
- Risks: impacts, assumptions, pending clarifications.
