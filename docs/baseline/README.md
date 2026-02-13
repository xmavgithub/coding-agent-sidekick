# Existing Codebase Baseline

This folder stores reusable repository-understanding artifacts for `existing` mode.

## One-time setup
```bash
make bootstrap-existing-baseline SOURCE_PATH="."
```

## Per-feature selective context
```bash
make new-context-pack FEATURE="<feature>" TARGET_PATHS="path/a,path/b"
```

## Mandatory maintenance after coding-agent changes
```bash
make update-baseline FEATURE="<feature>" SUMMARY="<summary>" SOURCE_PATH="."
```

If touched paths changed, use:
```bash
make update-baseline FEATURE="<feature>" SUMMARY="<summary>" SOURCE_PATH="." TARGET_PATHS="path/a,path/b"
```

If baseline is stale, token usage increases and plan quality degrades.
For `existing` mode PRs, baseline changelog update is expected in the same PR.
