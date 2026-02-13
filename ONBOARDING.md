# Onboarding

This guide is for first-time users of coding agents.
Goal: ship high-quality changes while minimizing token waste.

## One-command session start
At the beginning of a new session, type only:
- `Iniziamo`
- `Let's start`
- or the same intent in your language

Expected behavior:
- the agent keeps your language,
- asks the right kickoff questions,
- guides your first task using this repository workflow.

## Choose mode first
Use one mode per feature:
- `greenfield`: new app or new subsystem with no legacy constraints.
- `existing`: change to an existing codebase with compatibility/regression risks.

## What success looks like
Before implementation starts, you must have:
1. A research file in `docs/research/`.
2. A plan file in `docs/plans/`.
3. At least 2 annotation iterations completed in the plan.
4. A passing implementation gate.
5. For `existing` mode: baseline and context pack available.

## First 30 minutes (copy this flow)
Use one feature slug consistently in all commands.

Example slug: `oauth-login`

1. Start the session with one command:
`Iniziamo` (or equivalent in your language)

2. Read the process once:
`docs/process/start-here.md`

3. If mode is `existing`, bootstrap repository baseline (one-time per repository):
```bash
make bootstrap-existing-baseline SOURCE_PATH="."
make new-context-pack FEATURE="oauth-login" TARGET_PATHS="src/auth,src/api"
```

4. Create both required artifacts.
Greenfield:
```bash
make kickoff FEATURE="oauth-login" MODULE="auth" MODE="greenfield"
```

Existing codebase:
```bash
make kickoff FEATURE="oauth-login" MODULE="auth" MODE="existing"
```

Expected result:
- `docs/research/oauth-login-research.md` exists
- `docs/plans/oauth-login-plan.md` exists
- Both files include `Project Mode`.

5. Check current status and next step:
```bash
make coach FEATURE="oauth-login"
```

6. Fill research and plan content, then run annotation cycles.
If mode is `existing`, do not leave these fields as `N/A` in the plan:
- `Baseline Reference (commit/tag)`
- `Baseline Artifact Set`
- `Context Pack`
- `Impacted modules`
- `Backward compatibility strategy`
- `Rollback plan`
- `Regression test focus`

7. Validate the plan structure:
```bash
make validate-plan FILE="docs/plans/oauth-login-plan.md"
```

8. Run the final pre-implementation gate:
```bash
make implementation-gate FEATURE="oauth-login"
```

9. Implement only after explicit plan approval.

10. After coding-agent changes in `existing` mode, refresh baseline:
```bash
make update-baseline FEATURE="oauth-login" SUMMARY="updated auth flow and session handling" SOURCE_PATH="."
```
This step is required before opening the PR.
If touched paths changed, pass `TARGET_PATHS="path/a,path/b"` to refresh the context pack in the same run.

## Daily operating rule
If this is a new session and you are not sure where to begin, type:
```text
Iniziamo
```
If you are already mid-feature and not sure what to do next, do not implement.
Run:
```bash
make coach FEATURE="<feature>"
```

## Common beginner mistakes
1. Starting implementation before plan approval.
2. Using different names/slugs for the same feature.
3. Writing a generic plan without concrete steps.
4. Skipping the implementation gate.
5. Forgetting to refresh baseline/changelog after existing-mode changes.
