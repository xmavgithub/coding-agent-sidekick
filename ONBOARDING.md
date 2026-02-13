# Onboarding

This guide is for first-time users of coding agents.
Goal: ship high-quality changes while minimizing token waste.

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

1. Read the process once:
`docs/process/start-here.md`

2. If mode is `existing`, bootstrap repository baseline (one-time per repository):
```bash
make bootstrap-existing-baseline SOURCE_PATH="."
make new-context-pack FEATURE="oauth-login" TARGET_PATHS="src/auth,src/api"
```

3. Create both required artifacts.
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

4. Check current status and next step:
```bash
make coach FEATURE="oauth-login"
```

5. Fill research and plan content, then run annotation cycles.
If mode is `existing`, do not leave these fields as `N/A` in the plan:
- `Baseline Reference (commit/tag)`
- `Baseline Artifact Set`
- `Context Pack`
- `Impacted modules`
- `Backward compatibility strategy`
- `Rollback plan`
- `Regression test focus`

6. Validate the plan structure:
```bash
make validate-plan FILE="docs/plans/oauth-login-plan.md"
```

7. Run the final pre-implementation gate:
```bash
make implementation-gate FEATURE="oauth-login"
```

8. Implement only after explicit plan approval.

9. After coding-agent changes in `existing` mode, refresh baseline:
```bash
make update-baseline FEATURE="oauth-login" SUMMARY="updated auth flow and session handling" SOURCE_PATH="."
```
This step is required before opening the PR.
If touched paths changed, pass `TARGET_PATHS="path/a,path/b"` to refresh the context pack in the same run.

## Daily operating rule
If you are not sure what to do next, do not implement.
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
