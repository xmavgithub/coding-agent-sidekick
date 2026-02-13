# Workflow

## Step 0 - Start Here
Read `docs/process/start-here.md` and execute commands in order.

If mode is `existing`, bootstrap baseline once:
```bash
make bootstrap-existing-baseline SOURCE_PATH="."
```

## Step 1 - Research
Create artifact:
```bash
make new-research MODULE="<module>" MODE="<greenfield|existing>"
```

## Step 2 - Plan
Create artifact:
```bash
make new-plan FEATURE="<feature>" MODE="<greenfield|existing>"
```

## Step 3 - Annotation
Review the plan, add notes, and iterate until approved.

## Step 4 - Validation Gate
```bash
make validate-plan FILE="docs/plans/<feature>-plan.md"
```

## Step 5 - Implementation Gate
Run final gate:
```bash
make implementation-gate FEATURE="<feature>"
```
Then implement only after explicit plan approval.

## Step 6 - Baseline Maintenance (Existing Mode)
After coding-agent changes:
```bash
make update-baseline FEATURE="<feature>" SUMMARY="<summary>" SOURCE_PATH="."
```
If touched paths changed, pass `TARGET_PATHS="path/a,path/b"` to refresh context pack.
