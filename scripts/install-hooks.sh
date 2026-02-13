#!/bin/sh
set -eu

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'Error: not a git repository. Run scripts/init-repo.sh first.\n' >&2
  exit 1
fi

chmod +x scripts/check-conventional-commits.sh
chmod +x .githooks/commit-msg
git config core.hooksPath .githooks

printf 'Installed git hooks with core.hooksPath=.githooks\n'
