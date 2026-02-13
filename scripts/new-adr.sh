#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

TITLE="${1:-}"
require_non_empty_arg "$TITLE"

DATE=$(date '+%Y%m%d')
DATE_LONG=$(date '+%Y-%m-%d')
SLUG=$(slugify "$TITLE")
OUT_FILE="docs/decisions/${DATE}-${SLUG}.md"

if [ -f "$OUT_FILE" ]; then
  printf 'Error: file already exists: %s\n' "$OUT_FILE" >&2
  exit 1
fi

cat > "$OUT_FILE" <<EOF
# ADR: ${TITLE}

- Date: ${DATE_LONG}
- Status: Proposed

## Context
Describe the problem and constraints.

## Decision
Describe the chosen approach.

## Consequences
- Positive:
- Negative:
- Neutral:

## Alternatives Considered
List rejected options and why they were rejected.
EOF

printf 'Created: %s\n' "$OUT_FILE"
