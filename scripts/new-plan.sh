#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

FEATURE_NAME="${1:-}"
require_non_empty_arg "$FEATURE_NAME"
MODE=$(resolve_mode "${2:-greenfield}")
SLUG=$(slugify "$FEATURE_NAME")

BASELINE_DEFAULT="N/A"
COMPAT_DEFAULT="N/A"
BASELINE_ARTIFACT_SET_DEFAULT="N/A"
CONTEXT_PACK_DEFAULT="N/A"
IMPACTED_DEFAULT="N/A"
BACKCOMP_DEFAULT="N/A"
MIGRATION_DEFAULT="N/A"
ROLLBACK_DEFAULT="N/A"
REGRESSION_DEFAULT="N/A"
if [ "$MODE" = "existing" ]; then
  BASELINE_DEFAULT="TBD"
  COMPAT_DEFAULT="TBD"
  BASELINE_ARTIFACT_SET_DEFAULT="docs/baseline/INDEX.md"
  CONTEXT_PACK_DEFAULT="docs/baseline/context-packs/${SLUG}-context-pack.md"
  IMPACTED_DEFAULT="TBD"
  BACKCOMP_DEFAULT="TBD"
  MIGRATION_DEFAULT="TBD"
  ROLLBACK_DEFAULT="TBD"
  REGRESSION_DEFAULT="TBD"
fi

DATE=$(date '+%Y-%m-%d')
OUT_FILE="docs/plans/${SLUG}-plan.md"

if [ -f "$OUT_FILE" ]; then
  printf 'Error: file already exists: %s\n' "$OUT_FILE" >&2
  exit 1
fi

cat > "$OUT_FILE" <<EOF
# Plan: ${FEATURE_NAME}

## Metadata
- Feature: ${FEATURE_NAME}
- Date: ${DATE}
- Status: draft
- Project Mode: ${MODE}
- Target Paths:
- Related research: docs/research/${SLUG}-research.md
- Baseline Reference (commit/tag): ${BASELINE_DEFAULT}
- Compatibility Constraints: ${COMPAT_DEFAULT}
- Baseline Artifact Set: ${BASELINE_ARTIFACT_SET_DEFAULT}
- Context Pack: ${CONTEXT_PACK_DEFAULT}

## 1. Business Requirement
Describe user story and acceptance criteria.

## 2. Technical Scope
- In scope:
- Out of scope:

## 3. Constraints
- Performance:
- Security:
- Compatibility:
- Accessibility:

## 4. Technical Approach and Trade-Offs
Document options and chosen approach.

## 5. Implementation Plan
List concrete steps and expected file-level changes.

## 6. Existing Codebase Impact (Mode: existing only)
- Impacted modules: ${IMPACTED_DEFAULT}
- Backward compatibility strategy: ${BACKCOMP_DEFAULT}
- Migration strategy: ${MIGRATION_DEFAULT}
- Rollback plan: ${ROLLBACK_DEFAULT}
- Regression test focus: ${REGRESSION_DEFAULT}

## 7. Data and API Changes
Document schema and payload changes.

## 8. Test Plan
- Unit:
- Integration:
- End-to-end:

## 9. Monitoring and Rollout
Metrics, logs, alerts, feature flags, rollout strategy.

## 10. Token Efficiency Plan
- Prompt scope limits:
- Reusable references:
- Stop conditions to avoid rework:

## 11. TODO
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## 12. Annotation Notes
Record review notes and how each note was addressed.
- [ ] Iteration 1 completed
- [ ] Iteration 2 completed

## 13. Baseline Maintenance (Mode: existing only)
- [ ] Run: make update-baseline FEATURE="${SLUG}" SUMMARY="<summary>" SOURCE_PATH="."
- [ ] If touched paths changed, add TARGET_PATHS="path/a,path/b"
EOF

printf 'Created: %s\n' "$OUT_FILE"
printf 'Project mode: %s\n' "$MODE"
printf 'Next: run annotation cycles and then validate with:\n'
printf '  make validate-plan FILE="%s"\n' "$OUT_FILE"

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
