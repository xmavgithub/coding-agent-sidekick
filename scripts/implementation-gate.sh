#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

FEATURE_INPUT="${1:-}"
require_non_empty_arg "$FEATURE_INPUT"
FEATURE_SLUG=$(slugify "$FEATURE_INPUT")

RESEARCH_FILE="docs/research/${FEATURE_SLUG}-research.md"
PLAN_FILE="docs/plans/${FEATURE_SLUG}-plan.md"

if [ ! -f "$RESEARCH_FILE" ]; then
  printf 'Missing research file: %s\n' "$RESEARCH_FILE" >&2
  exit 1
fi

if [ ! -f "$PLAN_FILE" ]; then
  printf 'Missing plan file: %s\n' "$PLAN_FILE" >&2
  exit 1
fi

"$SCRIPT_DIR/validate-plan.sh" "$PLAN_FILE"

PLAN_MODE=$(sed -n 's/^- Project Mode:[[:space:]]*//p' "$PLAN_FILE" | head -n 1)
PLAN_MODE=$(resolve_mode "${PLAN_MODE:-greenfield}")

if ! grep -Eiq '^- Status:[[:space:]]*approved' "$PLAN_FILE"; then
  printf 'Plan status is not approved in %s\n' "$PLAN_FILE" >&2
  printf 'Set metadata line to: - Status: approved\n' >&2
  exit 1
fi

if ! grep -Fq -- '- [x] Iteration 1 completed' "$PLAN_FILE"; then
  printf 'Iteration 1 not marked complete in %s\n' "$PLAN_FILE" >&2
  exit 1
fi

if ! grep -Fq -- '- [x] Iteration 2 completed' "$PLAN_FILE"; then
  printf 'Iteration 2 not marked complete in %s\n' "$PLAN_FILE" >&2
  exit 1
fi

if [ "$PLAN_MODE" = "existing" ]; then
  require_filled_field() {
    FIELD_NAME="$1"
    VALUE=$(sed -n "s/^- ${FIELD_NAME}:[[:space:]]*//p" "$PLAN_FILE" | head -n 1)
    if [ "$VALUE" = "" ] || [ "$VALUE" = "N/A" ] || [ "$VALUE" = "TBD" ]; then
      printf 'Existing mode requires filled field "%s" in %s\n' "$FIELD_NAME" "$PLAN_FILE" >&2
      exit 1
    fi
  }

  require_filled_field "Baseline Reference (commit/tag)"
  require_filled_field "Compatibility Constraints"
  require_filled_field "Baseline Artifact Set"
  require_filled_field "Context Pack"

  require_filled_line() {
    LABEL="$1"
    VALUE=$(sed -n "s/^- ${LABEL}:[[:space:]]*//p" "$PLAN_FILE" | head -n 1)
    if [ "$VALUE" = "" ] || [ "$VALUE" = "N/A" ] || [ "$VALUE" = "TBD" ]; then
      printf 'Existing mode requires "%s" in %s\n' "$LABEL" "$PLAN_FILE" >&2
      exit 1
    fi
  }

  require_filled_line "Impacted modules"
  require_filled_line "Backward compatibility strategy"
  require_filled_line "Rollback plan"
  require_filled_line "Regression test focus"

  BASELINE_ARTIFACT_SET=$(sed -n 's/^- Baseline Artifact Set:[[:space:]]*//p' "$PLAN_FILE" | head -n 1)
  CONTEXT_PACK=$(sed -n 's/^- Context Pack:[[:space:]]*//p' "$PLAN_FILE" | head -n 1)

  if [ ! -f "$BASELINE_ARTIFACT_SET" ]; then
    printf 'Existing mode baseline artifact set path not found: %s\n' "$BASELINE_ARTIFACT_SET" >&2
    exit 1
  fi

  if [ ! -f "$CONTEXT_PACK" ]; then
    printf 'Existing mode context pack path not found: %s\n' "$CONTEXT_PACK" >&2
    exit 1
  fi
fi

printf 'Implementation gate passed for feature: %s (mode: %s)\n' "$FEATURE_INPUT" "$PLAN_MODE"
