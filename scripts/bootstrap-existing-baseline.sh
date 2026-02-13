#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)

SOURCE_PATH="${1:-.}"
if [ "$SOURCE_PATH" = "" ]; then
  SOURCE_PATH="."
fi

if [ ! -d "$SOURCE_PATH" ]; then
  printf 'Error: source path not found: %s\n' "$SOURCE_PATH" >&2
  exit 1
fi

BASE_DIR="docs/baseline"
PACK_DIR="${BASE_DIR}/context-packs"
mkdir -p "$BASE_DIR" "$PACK_DIR"

TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
COMMIT_REF="N/A"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  COMMIT_REF=$(git rev-parse --short HEAD 2>/dev/null || printf 'N/A')
fi

if command -v rg >/dev/null 2>&1; then
  (
    cd "$SOURCE_PATH"
    rg --files \
      -g '!**/.git/**' \
      -g '!**/node_modules/**' \
      -g '!**/dist/**' \
      -g '!**/build/**' \
      -g '!**/.next/**' \
      -g '!**/.venv/**' \
      -g '!**/venv/**' \
      -g '!**/target/**' \
      -g '!**/coverage/**' \
      -g '!docs/baseline/**' \
      | sort
  ) > "${BASE_DIR}/file-inventory.txt"
else
  find "$SOURCE_PATH" \
    \( \
      -path "$SOURCE_PATH/.git" -o \
      -path "$SOURCE_PATH/node_modules" -o \
      -path "$SOURCE_PATH/dist" -o \
      -path "$SOURCE_PATH/build" -o \
      -path "$SOURCE_PATH/.next" -o \
      -path "$SOURCE_PATH/.venv" -o \
      -path "$SOURCE_PATH/venv" -o \
      -path "$SOURCE_PATH/target" -o \
      -path "$SOURCE_PATH/coverage" -o \
      -path "$SOURCE_PATH/docs/baseline" \
    \) -prune -o -type f -print \
    | sed -e "s#^${SOURCE_PATH}/##" -e 's#^\./##' \
    | sort \
    > "${BASE_DIR}/file-inventory.txt"
fi

find "$SOURCE_PATH" \
  \( \
    -path "$SOURCE_PATH/.git" -o \
    -path "$SOURCE_PATH/node_modules" -o \
    -path "$SOURCE_PATH/dist" -o \
    -path "$SOURCE_PATH/build" -o \
    -path "$SOURCE_PATH/.next" -o \
    -path "$SOURCE_PATH/.venv" -o \
    -path "$SOURCE_PATH/venv" -o \
    -path "$SOURCE_PATH/target" -o \
    -path "$SOURCE_PATH/coverage" -o \
    -path "$SOURCE_PATH/docs/baseline" \
  \) -prune -o -type d -print \
  | sed -e "s#^${SOURCE_PATH}/##" -e "s#^${SOURCE_PATH}\$#.#" -e 's#^\./##' \
  | sort \
  > "${BASE_DIR}/repository-tree.txt"

awk -F/ 'NF > 0 {count[$1]++} END {for (k in count) printf "%7d %s\n", count[k], k}' \
  "${BASE_DIR}/file-inventory.txt" \
  | sort -nr \
  > "${BASE_DIR}/top-level-file-counts.txt"

FILE_COUNT=$(wc -l < "${BASE_DIR}/file-inventory.txt" | tr -d ' ')
DIR_COUNT=$(wc -l < "${BASE_DIR}/repository-tree.txt" | tr -d ' ')

cat > "${BASE_DIR}/INDEX.md" <<EOF
# Existing Codebase Baseline Index

This baseline is the one-time repository understanding layer for coding agents.
Use it as the first source of truth in every existing-codebase session.

## Metadata
- Generated at (UTC): ${TIMESTAMP}
- Source path: ${SOURCE_PATH}
- Baseline reference: ${COMMIT_REF}
- File count snapshot: ${FILE_COUNT}
- Directory count snapshot: ${DIR_COUNT}

## Core Baseline Artifacts
- \`${BASE_DIR}/architecture-summary.md\`
- \`${BASE_DIR}/module-catalog.md\`
- \`${BASE_DIR}/dependency-survey.md\`
- \`${BASE_DIR}/conventions-and-constraints.md\`
- \`${BASE_DIR}/open-questions.md\`
- \`${BASE_DIR}/repository-tree.txt\`
- \`${BASE_DIR}/file-inventory.txt\`
- \`${BASE_DIR}/top-level-file-counts.txt\`
- \`${BASE_DIR}/CHANGELOG.md\`

## Selective Usage Rule (Token Efficiency)
1. Load \`${BASE_DIR}/INDEX.md\` first.
2. Load only the context pack for the feature.
3. Load only touched module files, not full-repo scans.
4. Reuse baseline artifacts instead of regenerating context in chat.

## Maintenance Rule (Required)
For \`existing\` mode, baseline must be updated after every coding-agent change:
\`\`\`bash
make update-baseline FEATURE="<feature>" SUMMARY="<what changed>" SOURCE_PATH="."
\`\`\`
If touched paths changed, include:
\`\`\`bash
make update-baseline FEATURE="<feature>" SUMMARY="<what changed>" SOURCE_PATH="." TARGET_PATHS="path/a,path/b"
\`\`\`
EOF

if [ ! -f "${BASE_DIR}/architecture-summary.md" ]; then
  cat > "${BASE_DIR}/architecture-summary.md" <<'EOF'
# Architecture Summary

## System Shape
Describe the macro architecture (layers, boundaries, core domains).

## Runtime Boundaries
Describe APIs, workers, jobs, cron, external systems.

## High-Risk Areas
List modules where regressions are most likely.
EOF
fi

if [ ! -f "${BASE_DIR}/module-catalog.md" ]; then
  cat > "${BASE_DIR}/module-catalog.md" <<'EOF'
# Module Catalog

List major modules with purpose, owners, and critical interfaces.

| Module | Purpose | Critical Interfaces | Notes |
|---|---|---|---|
| TBD | TBD | TBD | TBD |
EOF
fi

if [ ! -f "${BASE_DIR}/dependency-survey.md" ]; then
  cat > "${BASE_DIR}/dependency-survey.md" <<'EOF'
# Dependency Survey

## Internal Dependencies
Map important module-to-module dependencies.

## External Dependencies
List libraries/services that are architecture-critical.

## Upgrade/Compatibility Risks
Document known version and compatibility constraints.
EOF
fi

if [ ! -f "${BASE_DIR}/conventions-and-constraints.md" ]; then
  cat > "${BASE_DIR}/conventions-and-constraints.md" <<'EOF'
# Conventions and Constraints

## Coding Conventions
List style, structure, and naming patterns to preserve.

## API and Data Compatibility
List backward-compatibility constraints that must not be broken.

## Operational Constraints
List deployment, migration, and rollback limitations.
EOF
fi

if [ ! -f "${BASE_DIR}/open-questions.md" ]; then
  cat > "${BASE_DIR}/open-questions.md" <<'EOF'
# Open Questions

Track unresolved architecture or domain questions that impact planning.
EOF
fi

if [ ! -f "${BASE_DIR}/CHANGELOG.md" ]; then
  cat > "${BASE_DIR}/CHANGELOG.md" <<'EOF'
# Baseline Changelog

Every existing-mode change must append an entry here after code changes.
Use:
`make update-baseline FEATURE="<feature>" SUMMARY="<summary>" SOURCE_PATH="."`
EOF
fi

printf 'Baseline bootstrap completed.\n'
printf 'Generated index: %s\n' "${BASE_DIR}/INDEX.md"
printf 'Next: create a selective context pack with:\n'
printf '  make new-context-pack FEATURE="<feature>" TARGET_PATHS="path/a,path/b"\n'
