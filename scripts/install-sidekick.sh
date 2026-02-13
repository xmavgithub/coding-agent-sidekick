#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
ROOT_DIR=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)

MODE="audit"
PROFILE="auto"
TARGET_PATH="."
REPORT_PATH=""
MANIFEST_PATH=""

usage() {
  cat <<'EOF'
Usage:
  scripts/install-sidekick.sh [options]

Options:
  --mode <audit|install|rollback>    Operation mode (default: audit)
  --profile <auto|new|existing>      Install profile for audit/install (default: auto)
  --target <path>                    Target repository path (default: .)
  --report <path>                    Optional report output path (create-only)
  --manifest <path>                  Manifest path for rollback or install output
  -h, --help                         Show this help

Examples:
  scripts/install-sidekick.sh --mode audit --profile auto --target ../my-repo
  scripts/install-sidekick.sh --mode install --profile existing --target ../my-repo
  scripts/install-sidekick.sh --mode rollback --target ../my-repo
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --profile)
      PROFILE="${2:-}"
      shift 2
      ;;
    --target)
      TARGET_PATH="${2:-}"
      shift 2
      ;;
    --report)
      REPORT_PATH="${2:-}"
      shift 2
      ;;
    --manifest)
      MANIFEST_PATH="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Error: unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$MODE" in
  audit|install|rollback)
    ;;
  *)
    printf 'Error: invalid mode "%s". Use audit, install, or rollback.\n' "$MODE" >&2
    exit 1
    ;;
esac

case "$PROFILE" in
  auto|new|existing)
    ;;
  *)
    printf 'Error: invalid profile "%s". Use auto, new, or existing.\n' "$PROFILE" >&2
    exit 1
    ;;
esac

if [ "$TARGET_PATH" = "" ]; then
  TARGET_PATH="."
fi

if [ "$MODE" = "install" ] && [ ! -d "$TARGET_PATH" ]; then
  mkdir -p "$TARGET_PATH"
fi

if [ ! -d "$TARGET_PATH" ]; then
  printf 'Error: target path not found: %s\n' "$TARGET_PATH" >&2
  exit 1
fi

TARGET_ABS=$(CDPATH='' cd -- "$TARGET_PATH" && pwd)

TMP_DIR=$(mktemp -d)
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT HUP TERM

MAPPING_FILE="$TMP_DIR/mapping.tsv"
ACTION_FILE="$TMP_DIR/actions.tsv"
MANIFEST_RECORDS="$TMP_DIR/manifest-records.tsv"

file_hash() {
  FILE_PATH="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$FILE_PATH" | awk '{print $1}'
    return
  fi

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$FILE_PATH" | awk '{print $1}'
    return
  fi

  if command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$FILE_PATH" | awk '{print $NF}'
    return
  fi

  printf 'Error: unable to compute SHA-256 (sha256sum/shasum/openssl not found).\n' >&2
  exit 1
}

is_empty_repo_candidate() {
  ENTRY_COUNT=$(
    find "$TARGET_ABS" -mindepth 1 -maxdepth 1 \
      ! -name '.git' \
      ! -name '.DS_Store' \
      | wc -l | tr -d ' '
  )

  if [ "$ENTRY_COUNT" = "0" ]; then
    return 0
  fi

  return 1
}

resolve_profile() {
  if [ "$PROFILE" != "auto" ]; then
    printf '%s' "$PROFILE"
    return
  fi

  if is_empty_repo_candidate; then
    printf 'new'
  else
    printf 'existing'
  fi
}

list_package_files() {
  if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$ROOT_DIR" ls-files
  else
    (
      cd "$ROOT_DIR"
      find . -type f | sed 's#^\./##'
    )
  fi | while IFS= read -r REL_PATH; do
    [ "$REL_PATH" = "" ] && continue

    case "$REL_PATH" in
      docs/research/*.md)
        if [ "$REL_PATH" != "docs/research/README.md" ]; then
          continue
        fi
        ;;
      docs/plans/*.md)
        if [ "$REL_PATH" != "docs/plans/README.md" ]; then
          continue
        fi
        ;;
      docs/baseline/context-packs/*)
        continue
        ;;
      */.DS_Store|.DS_Store)
        continue
        ;;
    esac

    printf '%s\n' "$REL_PATH"
  done
}

create_mapping() {
  RESOLVED_PROFILE="$1"
  list_package_files | while IFS= read -r SRC_REL; do
    if [ "$RESOLVED_PROFILE" = "new" ]; then
      DEST_REL="$SRC_REL"
    else
      DEST_REL=".sidekick/template/$SRC_REL"
    fi
    printf '%s\t%s\n' "$SRC_REL" "$DEST_REL"
  done > "$MAPPING_FILE"
}

record_action() {
  ACTION_TYPE="$1"
  PATH_REL="$2"
  DETAIL="${3:-}"
  printf '%s\t%s\t%s\n' "$ACTION_TYPE" "$PATH_REL" "$DETAIL" >> "$ACTION_FILE"
}

safe_copy_file() {
  SRC_REL="$1"
  DEST_REL="$2"

  SRC="$ROOT_DIR/$SRC_REL"
  DEST="$TARGET_ABS/$DEST_REL"

  if [ -e "$DEST" ]; then
    record_action "SKIPPED_EXISTS" "$DEST_REL" "already exists"
    return
  fi

  mkdir -p "$(dirname "$DEST")"
  cp -p "$SRC" "$DEST"
  HASH=$(file_hash "$DEST")
  printf 'FILE\t%s\t%s\n' "$DEST_REL" "$HASH" >> "$MANIFEST_RECORDS"
  record_action "CREATED" "$DEST_REL" "copied from $SRC_REL"
}

safe_write_generated() {
  DEST_REL="$1"
  SOURCE_TMP="$2"
  MODE_OCTAL="${3:-644}"

  DEST="$TARGET_ABS/$DEST_REL"
  if [ -e "$DEST" ]; then
    record_action "SKIPPED_EXISTS" "$DEST_REL" "already exists"
    return
  fi

  mkdir -p "$(dirname "$DEST")"
  cp -p "$SOURCE_TMP" "$DEST"
  chmod "$MODE_OCTAL" "$DEST"
  HASH=$(file_hash "$DEST")
  printf 'FILE\t%s\t%s\n' "$DEST_REL" "$HASH" >> "$MANIFEST_RECORDS"
  record_action "CREATED" "$DEST_REL" "generated"
}

write_existing_profile_helpers() {
  SIDEKICK_README_TMP="$TMP_DIR/sidekick-readme.md"
  cat > "$SIDEKICK_README_TMP" <<'EOF'
# Sidekick Overlay

This repository uses a namespaced Sidekick install under `.sidekick/template/`.
Installer policy: existing files are never overwritten.

## Next steps
1. Review `.sidekick/integration/AGENTS-snippet.md`.
2. If you already have `AGENTS.md`, merge the snippet manually.
3. If you do not have `AGENTS.md`, the installer creates a minimal one automatically.
4. Start a session with `Iniziamo` / `Let's start` (or equivalent in your language).

## Commands
- Sidekick template scripts are available in `.sidekick/template/scripts/`.
- You can also use `./.sidekick/bin/sidekick help` for command forwarding.
EOF
  safe_write_generated ".sidekick/README.md" "$SIDEKICK_README_TMP" "644"

  AGENTS_SNIPPET_TMP="$TMP_DIR/agents-snippet.md"
  cat > "$AGENTS_SNIPPET_TMP" <<'EOF'
## Sidekick Overlay Protocol
- Follow `.sidekick/template/AGENTS.md` for workflow and process rules.
- Session kickoff starts with a short intent command (e.g. `Iniziamo` / `Let's start`).
- Keep user language during kickoff and execution unless the user asks to switch.
- No implementation without approved research + plan artifacts.
EOF
  safe_write_generated ".sidekick/integration/AGENTS-snippet.md" "$AGENTS_SNIPPET_TMP" "644"

  if [ ! -e "$TARGET_ABS/AGENTS.md" ]; then
    ROOT_AGENTS_TMP="$TMP_DIR/root-agents.md"
    cat > "$ROOT_AGENTS_TMP" <<'EOF'
# AGENTS

This repository uses Coding Agent Sidekick as an overlay.

## Source of truth
- `.sidekick/template/AGENTS.md`
- `.sidekick/integration/AGENTS-snippet.md`

If this repository already had internal agent rules, merge them manually with the snippet.
EOF
    safe_write_generated "AGENTS.md" "$ROOT_AGENTS_TMP" "644"
  fi

  SIDEKICK_BIN_TMP="$TMP_DIR/sidekick-bin.sh"
  cat > "$SIDEKICK_BIN_TMP" <<'EOF'
#!/bin/sh
set -eu

BASE_DIR=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
SCRIPTS_DIR="$BASE_DIR/template/scripts"

CMD="${1:-help}"
shift || true

case "$CMD" in
  help)
    cat <<'OUT'
Usage: ./.sidekick/bin/sidekick <command> [args]

Commands:
  kickoff <feature> <module> <greenfield|existing>
  coach <feature>
  implementation-gate <feature>
  bootstrap-existing-baseline <source-path>
  new-context-pack <feature> <target-paths>
  update-baseline <feature> <summary> <source-path> [target-paths]
  new-research <module> <greenfield|existing>
  new-plan <feature> <greenfield|existing>
  new-adr <title>
  validate-plan <file>
  validate-pr
  install-hooks
  check-commits --range <git-range>
OUT
    ;;
  kickoff) "$SCRIPTS_DIR/kickoff.sh" "$@" ;;
  coach) "$SCRIPTS_DIR/coach.sh" "$@" ;;
  implementation-gate) "$SCRIPTS_DIR/implementation-gate.sh" "$@" ;;
  bootstrap-existing-baseline) "$SCRIPTS_DIR/bootstrap-existing-baseline.sh" "$@" ;;
  new-context-pack) "$SCRIPTS_DIR/new-context-pack.sh" "$@" ;;
  update-baseline) "$SCRIPTS_DIR/update-baseline.sh" "$@" ;;
  new-research) "$SCRIPTS_DIR/new-research.sh" "$@" ;;
  new-plan) "$SCRIPTS_DIR/new-plan.sh" "$@" ;;
  new-adr) "$SCRIPTS_DIR/new-adr.sh" "$@" ;;
  validate-plan) "$SCRIPTS_DIR/validate-plan.sh" "$@" ;;
  validate-pr) "$SCRIPTS_DIR/validate-pr.sh" "$@" ;;
  install-hooks) "$SCRIPTS_DIR/install-hooks.sh" "$@" ;;
  check-commits) "$SCRIPTS_DIR/check-conventional-commits.sh" "$@" ;;
  *)
    printf 'Error: unknown sidekick command: %s\n' "$CMD" >&2
    exit 1
    ;;
esac
EOF
  safe_write_generated ".sidekick/bin/sidekick" "$SIDEKICK_BIN_TMP" "755"
}

write_manifest() {
  RESOLVED_PROFILE="$1"
  MANIFEST_FINAL="$2"

  if [ -e "$MANIFEST_FINAL" ]; then
    printf 'Error: manifest path already exists (overwrite blocked): %s\n' "$MANIFEST_FINAL" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$MANIFEST_FINAL")"
  {
    printf 'META\tversion\t1\n'
    printf 'META\ttimestamp_utc\t%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf 'META\tmode\tinstall\n'
    printf 'META\tprofile\t%s\n' "$RESOLVED_PROFILE"
    printf 'META\tsource_repo\t%s\n' "$ROOT_DIR"
    printf 'META\ttarget_repo\t%s\n' "$TARGET_ABS"
    if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      printf 'META\tsource_ref\t%s\n' "$(git -C "$ROOT_DIR" rev-parse --short HEAD)"
    else
      printf 'META\tsource_ref\tN/A\n'
    fi
    cat "$MANIFEST_RECORDS"
  } > "$MANIFEST_FINAL"
}

write_report() {
  REPORT_TARGET="$1"
  RESOLVED_PROFILE="$2"
  MANIFEST_FINAL="$3"

  CREATE_COUNT=$(awk -F'\t' '$1=="CREATED"{c++} END{print c+0}' "$ACTION_FILE")
  SKIP_COUNT=$(awk -F'\t' '$1=="SKIPPED_EXISTS"{c++} END{print c+0}' "$ACTION_FILE")

  {
    printf '# Sidekick Installer Report\n\n'
    printf '- Mode: `%s`\n' "$MODE"
    if [ "$MODE" != "rollback" ]; then
      printf '- Profile: `%s`\n' "$RESOLVED_PROFILE"
    fi
    printf '- Target: `%s`\n' "$TARGET_ABS"
    if [ "$MANIFEST_FINAL" != "" ]; then
      printf '- Manifest: `%s`\n' "$MANIFEST_FINAL"
    fi
    printf '- Created files: `%s`\n' "$CREATE_COUNT"
    printf '- Skipped existing files: `%s`\n\n' "$SKIP_COUNT"

    if [ "$MODE" = "rollback" ]; then
      printf '## Rollback Actions\n'
    else
      printf '## Install/Audit Actions\n'
    fi

    if [ ! -s "$ACTION_FILE" ]; then
      printf '- No actions recorded.\n'
    else
      awk -F'\t' '{printf "- `%s` `%s` (%s)\n", $1, $2, $3}' "$ACTION_FILE"
    fi
  } > "$REPORT_TARGET"
}

print_summary_stdout() {
  CREATE_COUNT=$(awk -F'\t' '$1=="CREATED"{c++} END{print c+0}' "$ACTION_FILE")
  SKIP_COUNT=$(awk -F'\t' '$1=="SKIPPED_EXISTS"{c++} END{print c+0}' "$ACTION_FILE")
  ROLLBACK_REMOVED=$(awk -F'\t' '$1=="REMOVED"{c++} END{print c+0}' "$ACTION_FILE")
  ROLLBACK_MODIFIED=$(awk -F'\t' '$1=="SKIPPED_MODIFIED"{c++} END{print c+0}' "$ACTION_FILE")

  if [ "$MODE" = "rollback" ]; then
    printf 'Rollback summary:\n'
    printf '  Removed files: %s\n' "$ROLLBACK_REMOVED"
    printf '  Skipped modified files: %s\n' "$ROLLBACK_MODIFIED"
  else
    printf '%s summary:\n' "$(printf '%s' "$MODE" | tr '[:lower:]' '[:upper:]')"
    printf '  Created files: %s\n' "$CREATE_COUNT"
    printf '  Skipped existing files: %s\n' "$SKIP_COUNT"
  fi
}

rollback_from_manifest() {
  MANIFEST_IN="$1"
  if [ ! -f "$MANIFEST_IN" ]; then
    printf 'Error: manifest not found: %s\n' "$MANIFEST_IN" >&2
    exit 1
  fi

  while IFS="$(printf '\t')" read -r RECORD_TYPE PATH_REL HASH_VALUE; do
    [ "${RECORD_TYPE:-}" = "" ] && continue
    if [ "$RECORD_TYPE" != "FILE" ]; then
      continue
    fi

    FILE_PATH="$TARGET_ABS/$PATH_REL"
    if [ ! -f "$FILE_PATH" ]; then
      record_action "SKIPPED_MISSING" "$PATH_REL" "file not found"
      continue
    fi

    CURRENT_HASH=$(file_hash "$FILE_PATH")
    if [ "$CURRENT_HASH" != "$HASH_VALUE" ]; then
      record_action "SKIPPED_MODIFIED" "$PATH_REL" "hash changed"
      continue
    fi

    rm -f "$FILE_PATH"
    record_action "REMOVED" "$PATH_REL" "hash matched manifest"

    CLEAN_DIR=$(dirname "$FILE_PATH")
    while [ "$CLEAN_DIR" != "$TARGET_ABS" ] && [ "$CLEAN_DIR" != "/" ]; do
      if rmdir "$CLEAN_DIR" >/dev/null 2>&1; then
        CLEAN_DIR=$(dirname "$CLEAN_DIR")
      else
        break
      fi
    done
  done < "$MANIFEST_IN"
}

resolve_manifest_for_install() {
  if [ "$MANIFEST_PATH" != "" ]; then
    printf '%s' "$MANIFEST_PATH"
    return
  fi

  printf '.sidekick/install-manifest-%s.tsv' "$(date -u '+%Y%m%dT%H%M%SZ')"
}

resolve_manifest_for_rollback() {
  if [ "$MANIFEST_PATH" != "" ]; then
    printf '%s' "$MANIFEST_PATH"
    return
  fi

  CANDIDATE=$(
    find "$TARGET_ABS/.sidekick" -maxdepth 1 -type f -name 'install-manifest-*.tsv' 2>/dev/null \
      | sort \
      | tail -n 1
  )

  if [ "$CANDIDATE" = "" ]; then
    printf 'Error: no manifest found in %s\n' "$TARGET_ABS/.sidekick" >&2
    printf 'Pass --manifest <path> or run install first.\n' >&2
    exit 1
  fi

  printf '%s' "$CANDIDATE"
}

if [ "$MODE" = "rollback" ]; then
  MANIFEST_IN=$(resolve_manifest_for_rollback)
  rollback_from_manifest "$MANIFEST_IN"
  print_summary_stdout

  if [ "$REPORT_PATH" != "" ]; then
    if [ -e "$REPORT_PATH" ]; then
      printf 'Error: report path already exists (overwrite blocked): %s\n' "$REPORT_PATH" >&2
      exit 1
    fi
    mkdir -p "$(dirname "$REPORT_PATH")"
    write_report "$REPORT_PATH" "" "$MANIFEST_IN"
    printf 'Rollback report written: %s\n' "$REPORT_PATH"
  fi

  exit 0
fi

RESOLVED_PROFILE=$(resolve_profile)
create_mapping "$RESOLVED_PROFILE"

if [ "$MODE" = "audit" ]; then
  while IFS="$(printf '\t')" read -r SRC_REL DEST_REL; do
    [ "$SRC_REL" = "" ] && continue
    if [ -e "$TARGET_ABS/$DEST_REL" ]; then
      record_action "SKIPPED_EXISTS" "$DEST_REL" "already exists"
    else
      record_action "CREATED" "$DEST_REL" "would copy from $SRC_REL"
    fi
  done < "$MAPPING_FILE"

  if [ "$RESOLVED_PROFILE" = "existing" ]; then
    for GENERATED_PATH in ".sidekick/README.md" ".sidekick/integration/AGENTS-snippet.md" ".sidekick/bin/sidekick"; do
      if [ -e "$TARGET_ABS/$GENERATED_PATH" ]; then
        record_action "SKIPPED_EXISTS" "$GENERATED_PATH" "already exists"
      else
        record_action "CREATED" "$GENERATED_PATH" "would generate"
      fi
    done

    if [ -e "$TARGET_ABS/AGENTS.md" ]; then
      record_action "SKIPPED_EXISTS" "AGENTS.md" "already exists (manual merge via snippet)"
    else
      record_action "CREATED" "AGENTS.md" "would generate minimal root AGENTS"
    fi
  fi

  print_summary_stdout

  if [ "$REPORT_PATH" != "" ]; then
    if [ -e "$REPORT_PATH" ]; then
      printf 'Error: report path already exists (overwrite blocked): %s\n' "$REPORT_PATH" >&2
      exit 1
    fi
    mkdir -p "$(dirname "$REPORT_PATH")"
    write_report "$REPORT_PATH" "$RESOLVED_PROFILE" ""
    printf 'Audit report written: %s\n' "$REPORT_PATH"
  fi

  exit 0
fi

# Install mode
while IFS="$(printf '\t')" read -r SRC_REL DEST_REL; do
  [ "$SRC_REL" = "" ] && continue
  safe_copy_file "$SRC_REL" "$DEST_REL"
done < "$MAPPING_FILE"

if [ "$RESOLVED_PROFILE" = "existing" ]; then
  write_existing_profile_helpers
fi

MANIFEST_FINAL_INPUT=$(resolve_manifest_for_install)
case "$MANIFEST_FINAL_INPUT" in
  /*) MANIFEST_FINAL="$MANIFEST_FINAL_INPUT" ;;
  *) MANIFEST_FINAL="$TARGET_ABS/$MANIFEST_FINAL_INPUT" ;;
esac
write_manifest "$RESOLVED_PROFILE" "$MANIFEST_FINAL"

print_summary_stdout
printf 'Manifest written: %s\n' "$MANIFEST_FINAL"

if [ "$REPORT_PATH" != "" ]; then
  if [ -e "$REPORT_PATH" ]; then
    printf 'Error: report path already exists (overwrite blocked): %s\n' "$REPORT_PATH" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$REPORT_PATH")"
  write_report "$REPORT_PATH" "$RESOLVED_PROFILE" "$MANIFEST_FINAL"
  printf 'Install report written: %s\n' "$REPORT_PATH"
fi
