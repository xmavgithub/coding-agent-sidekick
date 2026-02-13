# Sidekick Adoption (No Overwrite)

Use this guide to install Coding Agent Sidekick into any repository without overwriting existing files.

## Guarantee
- Installer never overwrites existing files.
- Existing paths are always skipped and reported.
- Rollback removes only files created by installer and only if unchanged.

## Modes
- `audit`: dry-run. Shows what would be created vs skipped.
- `install`: creates only missing files.
- `rollback`: removes files created by a previous install manifest.

## Profiles
- `auto`: detects repository shape:
  - empty/near-empty target -> `new`
  - populated target -> `existing`
- `new`: installs files at repository root paths (create-only).
- `existing`: installs under `.sidekick/template/` and adds integration helpers.

## Recommended flow
1. Audit first:
```bash
make install-sidekick TARGET_PATH="../my-repo" INSTALL_MODE="audit" INSTALL_PROFILE="auto"
```

2. Install:
```bash
make install-sidekick TARGET_PATH="../my-repo" INSTALL_MODE="install" INSTALL_PROFILE="auto"
```

3. Optional report file:
```bash
make install-sidekick TARGET_PATH="../my-repo" INSTALL_MODE="audit" REPORT_PATH="../my-repo/docs/sidekick/adoption-report.md"
```

4. Rollback (latest manifest auto-detected):
```bash
make install-sidekick TARGET_PATH="../my-repo" INSTALL_MODE="rollback"
```

5. Rollback from explicit manifest:
```bash
make install-sidekick TARGET_PATH="../my-repo" INSTALL_MODE="rollback" MANIFEST_PATH="../my-repo/.sidekick/install-manifest-20260213T120000Z.tsv"
```

## Existing repository notes
- If root `AGENTS.md` already exists, installer will not modify it.
- Merge guidance is generated at:
  - `.sidekick/integration/AGENTS-snippet.md`
- Sidekick helper command is generated at:
  - `.sidekick/bin/sidekick`

## First session after install
Start a new session with:
- `Iniziamo`
- `Let's start`
- or equivalent phrasing in your language
