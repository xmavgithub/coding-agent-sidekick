# Conventions

## Mandatory workflow
- Research first.
- Planning second.
- Iterative annotation.
- Implementation only on approved plans.
- In `existing` mode, baseline/context-pack usage is mandatory.
- In `existing` mode, baseline refresh after coding-agent changes is mandatory.

## Quality
- Avoid undocumented workarounds.
- No unjustified `any`/`unknown`.
- Tests and verification must be planned.
- Security and performance must be explicit.

## Token efficiency
- Keep request scope narrow.
- Use standard templates (`.claude/templates/`).
- Give precise, surgical feedback.
- Avoid unnecessary broad requests.
