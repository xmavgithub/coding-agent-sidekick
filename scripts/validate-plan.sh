#!/bin/sh
set -eu

PLAN_FILE="${1:-}"
if [ "$PLAN_FILE" = "" ]; then
  printf 'Usage: %s <plan-file>\n' "$0" >&2
  exit 1
fi

if [ ! -f "$PLAN_FILE" ]; then
  printf 'Error: file not found: %s\n' "$PLAN_FILE" >&2
  exit 1
fi

MISSING=0

require_heading() {
  HEADING="$1"
  if ! grep -Fq "$HEADING" "$PLAN_FILE"; then
    printf 'Missing heading: %s\n' "$HEADING" >&2
    MISSING=1
  fi
}

require_heading '## 1. Business Requirement'
require_heading '## 2. Technical Scope'
require_heading '## 3. Constraints'
require_heading '## 4. Technical Approach and Trade-Offs'
require_heading '## 5. Implementation Plan'
require_heading '## 6. Existing Codebase Impact (Mode: existing only)'
require_heading '## 7. Data and API Changes'
require_heading '## 8. Test Plan'
require_heading '## 9. Monitoring and Rollout'
require_heading '## 10. Token Efficiency Plan'
require_heading '## 11. TODO'
require_heading '## 12. Annotation Notes'
require_heading '## 13. Baseline Maintenance (Mode: existing only)'

if ! grep -Eq '^- \[ \] ' "$PLAN_FILE"; then
  printf 'Missing TODO checkboxes in %s\n' "$PLAN_FILE" >&2
  MISSING=1
fi

if ! grep -Eq 'Out of scope|Out-of-scope|Out of Scope' "$PLAN_FILE"; then
  printf 'Missing explicit out-of-scope section content in %s\n' "$PLAN_FILE" >&2
  MISSING=1
fi

PROJECT_MODE=$(sed -n 's/^- Project Mode:[[:space:]]*//p' "$PLAN_FILE" | head -n 1 | tr '[:upper:]' '[:lower:]')
if [ "$PROJECT_MODE" = "" ]; then
  printf 'Missing metadata field "- Project Mode:" in %s\n' "$PLAN_FILE" >&2
  MISSING=1
fi

case "$PROJECT_MODE" in
  greenfield|existing)
    ;;
  *)
    printf 'Invalid project mode in %s: %s\n' "$PLAN_FILE" "${PROJECT_MODE:-<empty>}" >&2
    MISSING=1
    ;;
esac

if [ "$PROJECT_MODE" = "existing" ]; then
  has_non_placeholder_line() {
    LABEL="$1"
    if ! grep -Eq "^- ${LABEL}:[[:space:]]*[^[:space:]].*" "$PLAN_FILE"; then
      printf 'Existing mode requires field "%s" with a value in %s\n' "$LABEL" "$PLAN_FILE" >&2
      MISSING=1
      return
    fi

    if grep -Eq "^- ${LABEL}:[[:space:]]*(N/A|TBD)[[:space:]]*$" "$PLAN_FILE"; then
      printf 'Existing mode field "%s" cannot be N/A or TBD in %s\n' "$LABEL" "$PLAN_FILE" >&2
      MISSING=1
    fi
  }

  has_non_placeholder_line 'Baseline Reference \(commit/tag\)'
  has_non_placeholder_line 'Compatibility Constraints'
  has_non_placeholder_line 'Baseline Artifact Set'
  has_non_placeholder_line 'Context Pack'
  has_non_placeholder_line 'Impacted modules'
  has_non_placeholder_line 'Backward compatibility strategy'
  has_non_placeholder_line 'Rollback plan'
  has_non_placeholder_line 'Regression test focus'

  BASELINE_ARTIFACT_SET=$(sed -n 's/^- Baseline Artifact Set:[[:space:]]*//p' "$PLAN_FILE" | head -n 1)
  CONTEXT_PACK=$(sed -n 's/^- Context Pack:[[:space:]]*//p' "$PLAN_FILE" | head -n 1)

  if [ "$BASELINE_ARTIFACT_SET" != "" ] && [ ! -f "$BASELINE_ARTIFACT_SET" ]; then
    printf 'Existing mode baseline artifact set path not found: %s\n' "$BASELINE_ARTIFACT_SET" >&2
    MISSING=1
  fi

  if [ "$CONTEXT_PACK" != "" ] && [ ! -f "$CONTEXT_PACK" ]; then
    printf 'Existing mode context pack path not found: %s\n' "$CONTEXT_PACK" >&2
    MISSING=1
  fi
fi

if [ "$MISSING" -ne 0 ]; then
  printf 'Plan validation failed: %s\n' "$PLAN_FILE" >&2
  exit 1
fi

printf 'Plan validation passed: %s\n' "$PLAN_FILE"
