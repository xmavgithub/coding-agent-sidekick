# Coding Agent Template

Operational template to start new projects with coding agents, with no application code at the beginning.
This repository defines process, governance, scripts, and GitHub automation for disciplined delivery.

## Goals
- Separate analysis/planning from implementation.
- Track decisions and artifacts (`research`, `plan`, `ADR`).
- Enforce quality and security standards from day 0.
- Keep the project GitHub-ready with "Medium" enforcement.

## Supported project modes
- `greenfield`: for new applications or isolated new subsystems.
- `existing`: for changes to existing codebases with compatibility, regression, rollback, and mandatory baseline maintenance.

## What Is Included
- Process documentation in English.
- Templates for research, planning, and implementation command.
- Scripts to create standard artifacts and validate plans.
- GitHub policy: issue/PR templates, CI workflows, commit checks.
- Multi-agent guidelines for any coding agent combination.

## Quick Start (before git init)
```bash
make help
make kickoff FEATURE="oauth-login" MODULE="auth" MODE="greenfield"
make kickoff FEATURE="oauth-login" MODULE="auth" MODE="existing"
make bootstrap-existing-baseline SOURCE_PATH="."
make new-context-pack FEATURE="oauth-login" TARGET_PATHS="src/auth,src/api"
make coach FEATURE="oauth-login"
make new-research MODULE="auth" MODE="greenfield"
make new-plan FEATURE="oauth-login" MODE="greenfield"
make update-baseline FEATURE="oauth-login" SUMMARY="updated auth flow" SOURCE_PATH="." TARGET_PATHS="src/auth,src/api"
make new-adr TITLE="Auth provider choice"
```

## When you create the GitHub repository
```bash
scripts/init-repo.sh
scripts/install-hooks.sh
```

Then configure branch protection using `docs/runbooks/github-setup.md`.

## Repository Map
```text
.claude/           Agent context and prompt templates
docs/              Process, templates, checklists, decisions
scripts/           Automation and validation scripts
.github/           GitHub templates and workflows
.githooks/         Optional local git hooks
```

## Governance Defaults
- Documentation language: English.
- License: Proprietary (All rights reserved).
- Commit convention: Conventional Commits.
- Initial enforcement: Medium (blocking CI on PR, local hooks optional).
- Agent model: vendor-agnostic.
- Project modes: `greenfield` and `existing`.

## Beginner Path
- Read `ONBOARDING.md`
- Read `docs/process/start-here.md`
- Start with `make kickoff FEATURE="<feature>" MODULE="<module>" MODE="<greenfield|existing>"`
- Use `make coach FEATURE="<feature>"` after every update
- Validate before implementation:
  - `make validate-plan FILE="docs/plans/<feature>-plan.md"`
  - `make implementation-gate FEATURE="<feature>"`
  - `make validate-pr`
- For `existing` mode:
  - run one-time baseline bootstrap
  - create/update context pack per feature
  - run `make update-baseline ...` after coding-agent changes

## License
Proprietary. See `LICENSE`.
