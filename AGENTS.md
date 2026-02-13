# AGENTS

This project uses a multi-agent model. The rules below apply to all agents.

## Shared objective
- Follow the workflow: `Session Kickoff -> Research -> Planning -> Annotation -> Implementation`.
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
8. During template adoption into other repositories, never overwrite existing files; use safe installer audit/install flow.

## Session start protocol (mandatory)
- If a session opens with a short start-intent command (for example: `Iniziamo`, `Let's start`, or equivalent in the user's language), treat it as kickoff mode.
- Keep the user's language for all kickoff questions and answers.
- Run guided intake using `docs/process/session-start.md`.
- Ask only the minimum questions required to launch the first activity.
- After intake, continue with standard workflow artifacts and gates.
- Never skip `Research -> Planning -> Annotation` even when kickoff is conversational.

## Agent handoff format
- Context: what was decided and why.
- Status: done/in-progress/blocked tasks.
- Artifacts: updated files with full paths.
- Risks: impacts, assumptions, pending clarifications.
