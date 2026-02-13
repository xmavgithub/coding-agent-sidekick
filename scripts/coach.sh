#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

FEATURE_INPUT="${1:-}"
require_non_empty_arg "$FEATURE_INPUT"
FEATURE_SLUG=$(slugify "$FEATURE_INPUT")

RESEARCH_FILE="docs/research/${FEATURE_SLUG}-research.md"
PLAN_FILE="docs/plans/${FEATURE_SLUG}-plan.md"
PROJECT_MODE="unknown"

print_status() {
  FILE_PATH="$1"
  LABEL="$2"
  if [ -f "$FILE_PATH" ]; then
    printf '[OK] %s: %s\n' "$LABEL" "$FILE_PATH"
  else
    printf '[MISSING] %s: %s\n' "$LABEL" "$FILE_PATH"
  fi
}

printf 'Feature coaching status: %s\n' "$FEATURE_INPUT"
print_status "$RESEARCH_FILE" "Research"
print_status "$PLAN_FILE" "Plan"

if [ ! -f "$RESEARCH_FILE" ]; then
  cat <<'EOF'
Next action:
- Run: make new-research MODULE="<module>" MODE="<greenfield|existing>"
EOF
  exit 0
fi

if [ ! -f "$PLAN_FILE" ]; then
  RESEARCH_MODE=$(sed -n 's/^- Project Mode:[[:space:]]*//p' "$RESEARCH_FILE" | head -n 1 | tr '[:upper:]' '[:lower:]')
  if [ "$RESEARCH_MODE" = "greenfield" ] || [ "$RESEARCH_MODE" = "existing" ]; then
    printf 'Next action:\n'
    printf '- Run: make new-plan FEATURE="%s" MODE="%s"\n' "$FEATURE_SLUG" "$RESEARCH_MODE"
    exit 0
  fi

  cat <<'EOF'
Next action:
- Run: make new-plan FEATURE="<feature>" MODE="<greenfield|existing>"
EOF
  exit 0
fi

PROJECT_MODE=$(sed -n 's/^- Project Mode:[[:space:]]*//p' "$PLAN_FILE" | head -n 1 | tr '[:upper:]' '[:lower:]')
if [ "$PROJECT_MODE" = "" ]; then
  PROJECT_MODE="unknown"
fi

cat <<EOF
Next action:
- Mode detected: ${PROJECT_MODE}
- Complete annotation cycles on ${PLAN_FILE}
- Validate:
  make validate-plan FILE="${PLAN_FILE}"
- Gate:
  make implementation-gate FEATURE="${FEATURE_SLUG}"
- Implement only after explicit approval.
EOF

if [ "$PROJECT_MODE" = "existing" ]; then
  cat <<EOF
- After coding-agent changes, refresh baseline:
  make update-baseline FEATURE="${FEATURE_SLUG}" SUMMARY="<summary>" SOURCE_PATH="."
  (add TARGET_PATHS="path/a,path/b" if touched paths changed)
EOF
fi
