#!/bin/sh
set -eu

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'Git repository already initialized.\n'
else
  git init -b main
  printf 'Initialized git repository with main branch.\n'
fi

chmod +x scripts/*.sh
chmod +x .githooks/commit-msg

cat <<'EOF'
Next steps:
1. scripts/install-hooks.sh
2. git add .
3. git commit -m "chore(repo): bootstrap coding-agent-sidekick"
4. Create GitHub repository and push.
EOF
