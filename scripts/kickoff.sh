#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

FEATURE_NAME="${1:-}"
require_non_empty_arg "$FEATURE_NAME"

MODULE_NAME="${2:-$FEATURE_NAME}"
MODE=$(resolve_mode "${3:-greenfield}")
FEATURE_SLUG=$(slugify "$FEATURE_NAME")

"$SCRIPT_DIR/new-research.sh" "$MODULE_NAME" "$MODE"
"$SCRIPT_DIR/new-plan.sh" "$FEATURE_NAME" "$MODE"

cat <<EOF

Guided next steps:
Mode: ${MODE}
1. Fill docs/research/${FEATURE_SLUG}-research.md
2. Fill docs/plans/${FEATURE_SLUG}-plan.md
3. Run at least two annotation cycles
4. Validate plan:
   make validate-plan FILE="docs/plans/${FEATURE_SLUG}-plan.md"
5. Final gate:
   make implementation-gate FEATURE="${FEATURE_SLUG}"
6. Only after explicit approval, implement.
EOF

if [ "$MODE" = "existing" ]; then
  cat <<EOF
7. Ensure baseline + context pack are ready:
   make bootstrap-existing-baseline SOURCE_PATH="."
   make new-context-pack FEATURE="${FEATURE_SLUG}" TARGET_PATHS="path/a,path/b"
8. After coding-agent changes:
   make update-baseline FEATURE="${FEATURE_SLUG}" SUMMARY="<summary>" SOURCE_PATH="."
   (add TARGET_PATHS="path/a,path/b" if touched paths changed)
EOF
fi
