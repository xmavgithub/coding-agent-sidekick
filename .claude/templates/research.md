# RESEARCH REQUEST: {{MODULE_NAME}}

## Project Mode
`{{PROJECT_MODE}}` (`greenfield` or `existing`)

## Context
Explain why this module matters and what decision this research must support.

## Scope
Analyze `{{TARGET_PATH}}` deeply:
1. Architecture and patterns
2. Dependencies (upstream/downstream)
3. Error handling and edge cases
4. Security and performance considerations
5. Test coverage and gaps
6. Issues by severity

## Constraints
- Read all relevant files in scope.
- Avoid assumptions; mark unknowns explicitly.
- Keep output concise but complete.

## Deliverable
Write report to `docs/research/{{SLUG}}-research.md`.

Ensure metadata includes:
- Project Mode
- Target Paths
- Baseline Reference (commit/tag)
- Compatibility Constraints
- Baseline Artifact Set
- Context Pack

If mode is `existing`:
- Reuse baseline artifacts first.
- Analyze only context-pack target paths and direct dependencies.
- Avoid full-repo scans.

Do not implement anything.
