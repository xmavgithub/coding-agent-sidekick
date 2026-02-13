#!/bin/sh
set -eu

if [ -n "${PR_BODY_FILE:-}" ]; then
  BODY=$(cat "$PR_BODY_FILE")
elif [ -n "${GITHUB_EVENT_PATH:-}" ] && command -v jq >/dev/null 2>&1; then
  BODY=$(jq -r '.pull_request.body // ""' "$GITHUB_EVENT_PATH")
else
  printf 'PR validation skipped (local mode without PR body).\n'
  printf 'Set PR_BODY_FILE=<path> to validate a PR description locally.\n'
  exit 0
fi

MISSING=0
require_field() {
  FIELD="$1"
  if ! printf '%s\n' "$BODY" | grep -Eq "$FIELD"; then
    printf 'Missing required PR field pattern: %s\n' "$FIELD" >&2
    MISSING=1
  fi
}

require_field 'Research File:'
require_field 'Plan File:'
require_field 'Mode:'
require_field 'Out of Scope:'
require_field 'Token Efficiency:'
require_field 'Validation:'
require_field 'Implementation gate'
require_field 'Baseline Reference:'
require_field 'Compatibility Constraints:'
require_field 'Baseline Artifact Set:'
require_field 'Context Pack:'

extract_path() {
  KEY="$1"
  printf '%s\n' "$BODY" \
    | sed -n "s/^${KEY}[[:space:]]*//p" \
    | head -n 1
}

is_placeholder() {
  VALUE=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  [ "$VALUE" = "" ] || [ "$VALUE" = "n/a" ] || [ "$VALUE" = "tbd" ]
}

check_optional_path() {
  LABEL="$1"
  VALUE="$2"
  if [ "$VALUE" = "" ] || [ "$VALUE" = "N/A" ]; then
    return 0
  fi

  if [ ! -f "$VALUE" ]; then
    printf 'Referenced %s file does not exist: %s\n' "$LABEL" "$VALUE" >&2
    MISSING=1
  fi
}

RESEARCH_PATH=$(extract_path 'Research File:')
PLAN_PATH=$(extract_path 'Plan File:')
MODE_VALUE=$(extract_path 'Mode:')
BASELINE_VALUE=$(extract_path 'Baseline Reference:')
COMPAT_VALUE=$(extract_path 'Compatibility Constraints:')
BASELINE_ARTIFACT_SET_VALUE=$(extract_path 'Baseline Artifact Set:')
CONTEXT_PACK_VALUE=$(extract_path 'Context Pack:')

check_optional_path 'Research' "$RESEARCH_PATH"
check_optional_path 'Plan' "$PLAN_PATH"

MODE_VALUE=$(printf '%s' "$MODE_VALUE" | tr '[:upper:]' '[:lower:]')
if [ "$MODE_VALUE" != "greenfield" ] && [ "$MODE_VALUE" != "existing" ]; then
  printf 'Invalid Mode value. Use "greenfield" or "existing".\n' >&2
  MISSING=1
fi

if [ "$MODE_VALUE" = "existing" ]; then
  require_field '^Impact Summary:[[:space:]]*[^[:space:]].*$'
  require_field '^Regression Plan:[[:space:]]*[^[:space:]].*$'
  require_field '^Rollback Plan:[[:space:]]*[^[:space:]].*$'
  require_field '^Baseline Update Summary:[[:space:]]*[^[:space:]].*$'
  require_field '^Baseline Changelog:[[:space:]]*[^[:space:]].*$'

  IMPACT_VALUE=$(extract_path 'Impact Summary:')
  REGRESSION_VALUE=$(extract_path 'Regression Plan:')
  ROLLBACK_VALUE=$(extract_path 'Rollback Plan:')
  BASELINE_UPDATE_VALUE=$(extract_path 'Baseline Update Summary:')
  BASELINE_CHANGELOG_VALUE=$(extract_path 'Baseline Changelog:')

  if is_placeholder "$BASELINE_VALUE"; then
    printf 'Existing mode requires a concrete Baseline Reference.\n' >&2
    MISSING=1
  fi

  if is_placeholder "$COMPAT_VALUE"; then
    printf 'Existing mode requires concrete Compatibility Constraints.\n' >&2
    MISSING=1
  fi

  if is_placeholder "$BASELINE_ARTIFACT_SET_VALUE"; then
    printf 'Existing mode requires a concrete Baseline Artifact Set.\n' >&2
    MISSING=1
  elif [ ! -f "$BASELINE_ARTIFACT_SET_VALUE" ]; then
    printf 'Baseline Artifact Set path does not exist: %s\n' "$BASELINE_ARTIFACT_SET_VALUE" >&2
    MISSING=1
  fi

  if is_placeholder "$CONTEXT_PACK_VALUE"; then
    printf 'Existing mode requires a concrete Context Pack.\n' >&2
    MISSING=1
  elif [ ! -f "$CONTEXT_PACK_VALUE" ]; then
    printf 'Context Pack path does not exist: %s\n' "$CONTEXT_PACK_VALUE" >&2
    MISSING=1
  fi

  if is_placeholder "$IMPACT_VALUE"; then
    printf 'Existing mode requires a concrete Impact Summary.\n' >&2
    MISSING=1
  fi

  if is_placeholder "$REGRESSION_VALUE"; then
    printf 'Existing mode requires a concrete Regression Plan.\n' >&2
    MISSING=1
  fi

  if is_placeholder "$ROLLBACK_VALUE"; then
    printf 'Existing mode requires a concrete Rollback Plan.\n' >&2
    MISSING=1
  fi

  if is_placeholder "$BASELINE_UPDATE_VALUE"; then
    printf 'Existing mode requires a concrete Baseline Update Summary.\n' >&2
    MISSING=1
  fi

  if is_placeholder "$BASELINE_CHANGELOG_VALUE"; then
    printf 'Existing mode requires a concrete Baseline Changelog path.\n' >&2
    MISSING=1
  elif [ ! -f "$BASELINE_CHANGELOG_VALUE" ]; then
    printf 'Baseline Changelog path does not exist: %s\n' "$BASELINE_CHANGELOG_VALUE" >&2
    MISSING=1
  fi

  if [ "${BASE_SHA:-}" != "" ] && [ "${HEAD_SHA:-}" != "" ]; then
    if ! git diff --name-only "$BASE_SHA" "$HEAD_SHA" | grep -Fxq "$BASELINE_CHANGELOG_VALUE"; then
      printf 'Existing mode requires baseline changelog to be updated in this PR: %s\n' "$BASELINE_CHANGELOG_VALUE" >&2
      MISSING=1
    fi
  fi
fi

if [ "$MISSING" -ne 0 ]; then
  printf 'PR validation failed.\n' >&2
  exit 1
fi

printf 'PR validation passed.\n'
