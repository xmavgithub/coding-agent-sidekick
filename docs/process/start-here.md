# Start Here

If you are new to coding agents, use only this path.
Do not skip steps.

## Step -1: Session start command
Open a new session and type a short start command:
- `Iniziamo`
- `Let's start`
- equivalent phrasing in your language

The agent must:
- keep your language,
- ask guided kickoff questions,
- move to the standard workflow after intake.

Reference: `docs/process/session-start.md`

## Step 0: Select project mode
- `greenfield`: new application or new subsystem.
- `existing`: changes on an existing codebase.

If mode is `existing`, run one-time baseline bootstrap:
- `make bootstrap-existing-baseline SOURCE_PATH="."`
- `make new-context-pack FEATURE="<feature>" TARGET_PATHS="path/a,path/b"`

## Mandatory guided flow
1. Read:
   - `docs/process/workflow.md`
   - `docs/process/session-start.md`
   - `docs/checklists/pre-implementation.md`
2. Start the feature:
   - `make new-research MODULE="<module>" MODE="<greenfield|existing>"`
   - `make new-plan FEATURE="<feature>" MODE="<greenfield|existing>"`
   - or use one command: `make kickoff FEATURE="<feature>" MODULE="<module>" MODE="<greenfield|existing>"`
3. Fill research and plan with templates.
4. Run annotation cycles (at least 2 iterations).
5. Validate the plan:
   - `make validate-plan FILE="docs/plans/<feature>-plan.md"`
6. Final gate before implementation:
   - `make implementation-gate FEATURE="<feature>"`
7. Implement only after explicit approval.
8. If mode is `existing`, update baseline after coding-agent changes:
   - `make update-baseline FEATURE="<feature>" SUMMARY="<summary>" SOURCE_PATH="."`
   - if touched paths changed, also pass `TARGET_PATHS="path/a,path/b"`

## Ready-to-use prompts
Session kickoff:
`Use .claude/templates/session-start.md and keep the user's language. Do not implement.`

Research:
`Use .claude/templates/research.md with PROJECT_MODE=<greenfield|existing> MODULE_NAME=<module> TARGET_PATH=<path> SLUG=<slug>. Do not implement.`

Planning:
`Use .claude/templates/planning.md with PROJECT_MODE=<greenfield|existing> FEATURE_NAME=<feature> SLUG=<slug>. Do not implement.`

Implementation:
`Use .claude/templates/implementation.md with SLUG=<slug> and implement only the approved plan.`

For `existing` mode, include:
- `Baseline Artifact Set` (usually `docs/baseline/INDEX.md`)
- `Context Pack` (`docs/baseline/context-packs/<feature>-context-pack.md`)
- Explicit instruction: "Use baseline/context-pack selectively. No full-repo scan."

## New-user anti-mistake rules
- If the agent starts coding during research/planning: stop it immediately.
- If the plan is generic: request concrete snippets.
- If a new library appears unexpectedly: stop and update the plan first.
- If mode is `existing`: require compatibility, regression, and rollback details before implementation.
