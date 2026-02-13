#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

FEATURE_INPUT="${1:-}"
require_non_empty_arg "$FEATURE_INPUT"
FEATURE_SLUG=$(slugify "$FEATURE_INPUT")

TARGET_PATHS_INPUT="${2:-TBD}"
OUT_FILE="docs/baseline/context-packs/${FEATURE_SLUG}-context-pack.md"

if [ ! -f "docs/baseline/INDEX.md" ]; then
  printf 'Error: baseline not found. Run:\n' >&2
  printf '  make bootstrap-existing-baseline SOURCE_PATH="."\n' >&2
  exit 1
fi

ACTION="Created"
if [ -f "$OUT_FILE" ]; then
  ACTION="Updated"
fi

TARGET_BULLETS=$(printf '%s' "$TARGET_PATHS_INPUT" | tr ',' '\n' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; /^$/d; s/^/- /')
if [ "$TARGET_BULLETS" = "" ]; then
  TARGET_BULLETS="- TBD"
fi

DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

cat > "$OUT_FILE" <<EOF
# Context Pack: ${FEATURE_INPUT}

## Metadata
- Date (UTC): ${DATE_UTC}
- Project Mode: existing
- Baseline Artifact Set: docs/baseline/INDEX.md
- Target Paths:
${TARGET_BULLETS}

## Load Order (Selective)
1. \`docs/baseline/INDEX.md\`
2. \`docs/baseline/architecture-summary.md\`
3. \`docs/baseline/module-catalog.md\`
4. \`docs/baseline/conventions-and-constraints.md\`
5. \`docs/baseline/context-packs/${FEATURE_SLUG}-context-pack.md\`

## Include
- Only files in target paths.
- Only direct dependencies of touched modules.
- Only tests relevant to changed behavior.

## Exclude
- Full-repo scans.
- Unrelated modules.
- Historical files not tied to current behavior.

## Token Strategy
- Reuse baseline docs instead of re-describing architecture.
- Keep prompts scoped to target paths and direct dependencies.
- Ask for concise file outputs, not long chat explanations.

## Prompt Snippet
\`Use docs/baseline/INDEX.md and docs/baseline/context-packs/${FEATURE_SLUG}-context-pack.md. Analyze only listed target paths and direct dependencies. Avoid full-repo scans.\`
EOF

printf '%s context pack: %s\n' "$ACTION" "$OUT_FILE"
