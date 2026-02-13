#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

MODULE_NAME="${1:-}"
require_non_empty_arg "$MODULE_NAME"
MODE=$(resolve_mode "${2:-greenfield}")

BASELINE_DEFAULT="N/A"
COMPAT_DEFAULT="N/A"
BASELINE_ARTIFACT_SET_DEFAULT="N/A"
CONTEXT_PACK_DEFAULT="N/A"
if [ "$MODE" = "existing" ]; then
  BASELINE_DEFAULT="TBD"
  COMPAT_DEFAULT="TBD"
  BASELINE_ARTIFACT_SET_DEFAULT="docs/baseline/INDEX.md"
  CONTEXT_PACK_DEFAULT="docs/baseline/context-packs/${SLUG}-context-pack.md"
fi

SLUG=$(slugify "$MODULE_NAME")
DATE=$(date '+%Y-%m-%d')
OUT_FILE="docs/research/${SLUG}-research.md"

if [ -f "$OUT_FILE" ]; then
  printf 'Error: file already exists: %s\n' "$OUT_FILE" >&2
  exit 1
fi

cat > "$OUT_FILE" <<EOF
# Research: ${MODULE_NAME}

## Metadata
- Module: ${MODULE_NAME}
- Date: ${DATE}
- Status: draft
- Project Mode: ${MODE}
- Target Paths:
- Baseline Reference (commit/tag): ${BASELINE_DEFAULT}
- Compatibility Constraints: ${COMPAT_DEFAULT}
- Baseline Artifact Set: ${BASELINE_ARTIFACT_SET_DEFAULT}
- Context Pack: ${CONTEXT_PACK_DEFAULT}

## 1. Context
Describe module purpose and why this research is needed.

## 2. Architecture
Explain patterns, boundaries, and data flow.

## 3. Dependencies
- Upstream:
- Downstream:
- External:

## 4. Edge Cases and Risks
List high-risk scenarios and failure paths.

## 5. Security and Performance
Document relevant controls and bottlenecks.

## 6. Test Coverage
Current coverage and testing gaps.

## 7. Issues
- Critical:
- Medium:
- Low:

## 8. Recommendations
Actionable recommendations for planning.

## 9. Mode-Specific Notes
- Greenfield:
  - New modules to create:
  - Initial architecture assumptions:
- Existing:
  - Current implementation baseline:
  - Legacy constraints and risks:
  - Selected baseline artifacts used:
EOF

printf 'Created: %s\n' "$OUT_FILE"
printf 'Project mode: %s\n' "$MODE"
printf 'Next: create a plan with `make new-plan FEATURE="%s" MODE="%s"`\n' "$SLUG" "$MODE"

if [ "$MODE" = "existing" ]; then
  if [ ! -f "$BASELINE_ARTIFACT_SET_DEFAULT" ]; then
    printf 'Warning: baseline artifact set not found: %s\n' "$BASELINE_ARTIFACT_SET_DEFAULT" >&2
    printf 'Run: make bootstrap-existing-baseline SOURCE_PATH="."\n' >&2
  fi
  if [ ! -f "$CONTEXT_PACK_DEFAULT" ]; then
    printf 'Warning: context pack not found: %s\n' "$CONTEXT_PACK_DEFAULT" >&2
    printf 'Run: make new-context-pack FEATURE="%s" TARGET_PATHS="path/a,path/b"\n' "$SLUG" >&2
  fi
fi
