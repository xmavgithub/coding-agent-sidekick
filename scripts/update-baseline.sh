#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

FEATURE_INPUT="${1:-}"
require_non_empty_arg "$FEATURE_INPUT"
FEATURE_SLUG=$(slugify "$FEATURE_INPUT")

SUMMARY_INPUT="${2:-}"
require_non_empty_arg "$SUMMARY_INPUT"

SOURCE_PATH="${3:-.}"
if [ "$SOURCE_PATH" = "" ]; then
  SOURCE_PATH="."
fi

TARGET_PATHS="${4:-}"

"$SCRIPT_DIR/bootstrap-existing-baseline.sh" "$SOURCE_PATH"

if [ "$TARGET_PATHS" != "" ]; then
  "$SCRIPT_DIR/new-context-pack.sh" "$FEATURE_INPUT" "$TARGET_PATHS"
fi

CHANGELOG_FILE="docs/baseline/CHANGELOG.md"
CONTEXT_PACK_FILE="docs/baseline/context-packs/${FEATURE_SLUG}-context-pack.md"
DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

if [ -f "$CONTEXT_PACK_FILE" ]; then
  CONTEXT_PACK_STATUS="present (${CONTEXT_PACK_FILE})"
else
  CONTEXT_PACK_STATUS="missing (${CONTEXT_PACK_FILE})"
fi

CONTEXT_PACK_REFRESHED="no"
if [ "$TARGET_PATHS" != "" ]; then
  CONTEXT_PACK_REFRESHED="yes"
fi

cat >> "$CHANGELOG_FILE" <<EOF

## ${DATE_UTC} - ${FEATURE_INPUT}
- Summary: ${SUMMARY_INPUT}
- Baseline inventory refreshed: yes
- Context pack refreshed in this run: ${CONTEXT_PACK_REFRESHED}
- Context pack status: ${CONTEXT_PACK_STATUS}
- Follow-up: update context pack if touched paths changed
EOF

printf 'Baseline updated and changelog entry appended.\n'
printf 'Changelog: %s\n' "$CHANGELOG_FILE"
