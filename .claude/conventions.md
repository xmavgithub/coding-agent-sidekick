# Conventions

## Mandatory workflow
- Session kickoff command first when user starts with a short start intent (`Iniziamo`, `Let's start`, or equivalent in their language).
- Research first.
- Planning second.
- Iterative annotation.
- Implementation only on approved plans.
- In `existing` mode, baseline/context-pack usage is mandatory.
- In `existing` mode, baseline refresh after coding-agent changes is mandatory.
- During Sidekick adoption into other repositories, existing files must never be overwritten.

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

## Language continuity
- During kickoff and execution, keep the user's language unless they ask to switch.
