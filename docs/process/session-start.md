# Session Start Command

Use this protocol when a new session starts with a short natural-language command such as:
- `Iniziamo`
- `Let's start`
- equivalent phrasing in the user's language

The command is intent-based, not strict literal matching.

## Required behavior
1. Keep the same language used by the user.
2. Start guided intake before implementation.
3. Ask only high-signal questions needed for first-task setup.
4. Move to standard workflow after intake:
   `Research -> Planning -> Annotation -> Implementation`.

## Guided intake questions
Ask these in one concise message (merge only when the user already provided details):
1. What do you want to build or change first?
2. Is this `greenfield` or `existing` mode?
3. What are the target modules or paths?
4. What constraints are non-negotiable (security, performance, compatibility, deadlines)?
5. What is "done" for this first activity?
6. If mode is `existing`, what baseline reference should be used (branch/commit/tag)?

## Post-intake output contract
After answers are provided, the agent should:
1. Summarize assumptions and scope.
2. Propose or normalize a feature slug.
3. Execute/start artifact setup (`make kickoff ...`).
4. Continue with research and planning guidance.
5. Explicitly state that implementation starts only after plan approval.

## Existing mode additions
When mode is `existing`, the kickoff must include:
- baseline bootstrap check:
  `make bootstrap-existing-baseline SOURCE_PATH="."`
- context-pack setup/update:
  `make new-context-pack FEATURE="<feature>" TARGET_PATHS="path/a,path/b"`

## Failure handling
- If user answers are incomplete: ask focused follow-up questions.
- If user asks to skip planning: refuse and restate mandatory workflow.
- If language is unclear: ask once, then stay consistent.
