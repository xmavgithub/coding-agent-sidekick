#!/bin/sh
set -eu

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

require_non_empty_arg() {
  if [ "${1:-}" = "" ]; then
    printf 'Error: missing required argument.\n' >&2
    exit 1
  fi
}

resolve_mode() {
  MODE_INPUT="${1:-greenfield}"
  MODE=$(printf '%s' "$MODE_INPUT" | tr '[:upper:]' '[:lower:]')

  case "$MODE" in
    greenfield|existing)
      printf '%s' "$MODE"
      ;;
    *)
      printf 'Error: invalid mode "%s". Use "greenfield" or "existing".\n' "$MODE_INPUT" >&2
      exit 1
      ;;
  esac
}
