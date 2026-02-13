# Contributing

## Required process
1. Create research artifacts under `docs/research/`.
2. Create a plan under `docs/plans/`.
3. Run annotation cycles until the plan is approved.
4. Implement only after explicit approval.
5. If you are a beginner, start with `docs/process/start-here.md` and use `make kickoff` + `make coach`.
6. Select `Project Mode` (`greenfield` or `existing`) and keep it consistent across research, plan, and PR.
7. In `existing` mode, maintain baseline docs after coding-agent changes with `make update-baseline`.
8. In `existing` mode, PR policy expects baseline changelog updated in the same PR.

## Commit convention
Use Conventional Commits:
- `feat(scope): ...`
- `fix(scope): ...`
- `docs: ...`
- `chore: ...`
- `refactor: ...`
- `test: ...`
- `ci: ...`

Format:
`type(scope)!: short description`

## Enforcement level: Medium
- PR CI checks are blocking.
- Local hooks are optional but recommended (`scripts/install-hooks.sh`).
- Branch protection is configured in GitHub settings.

## Pull request
- Use `.github/pull_request_template.md`.
- Include research/plan paths.
- Verify locally:
  - `make validate-pr`
  - `make validate-plan FILE=docs/plans/<feature>-plan.md`
  - `make implementation-gate FEATURE=<feature>`
