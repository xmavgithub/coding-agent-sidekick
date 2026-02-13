#!/bin/sh
set -eu

REGEX='^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([a-z0-9._/-]+\))?(!)?: .+'

validate_message() {
  MSG="$1"

  if printf '%s\n' "$MSG" | grep -Eq '^Merge '; then
    return 0
  fi

  if ! printf '%s\n' "$MSG" | grep -Eq "$REGEX"; then
    printf 'Invalid commit message: %s\n' "$MSG" >&2
    printf 'Expected Conventional Commits format.\n' >&2
    return 1
  fi

  return 0
}

if [ "${1:-}" = "--range" ]; then
  RANGE="${2:-}"
  if [ "$RANGE" = "" ]; then
    printf 'Usage: %s --range <git-range>\n' "$0" >&2
    exit 1
  fi

  TMP_FILE=$(mktemp)
  git log --format=%s "$RANGE" > "$TMP_FILE"

  FAILED=0
  while IFS= read -r LINE; do
    if [ "$LINE" = "" ]; then
      continue
    fi
    if ! validate_message "$LINE"; then
      FAILED=1
    fi
  done < "$TMP_FILE"
  rm -f "$TMP_FILE"

  if [ "$FAILED" -ne 0 ]; then
    exit 1
  fi

  printf 'Commit message check passed for range: %s\n' "$RANGE"
  exit 0
fi

if [ "${1:-}" != "" ] && [ -f "${1:-}" ]; then
  FIRST_LINE=$(head -n 1 "$1")
  validate_message "$FIRST_LINE"
  exit $?
fi

if [ "${1:-}" = "" ]; then
  printf 'Usage:\n' >&2
  printf '  %s <commit-msg-file>\n' "$0" >&2
  printf '  %s --range <git-range>\n' "$0" >&2
  printf '  %s "<commit subject>"\n' "$0" >&2
  exit 1
fi

validate_message "$*"
