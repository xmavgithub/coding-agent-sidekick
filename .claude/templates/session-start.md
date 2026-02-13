# SESSION START REQUEST

The user started with a short kickoff command (example: "Iniziamo", "Let's start", or equivalent in their language).

## Rules
1. Keep the user's language throughout kickoff.
2. Do not implement yet.
3. Run guided intake with concise, high-signal questions.
4. Transition to standard workflow only after intake.

## Intake Questions
Ask:
1. First objective/feature.
2. Project mode (`greenfield` or `existing`).
3. Target modules/paths.
4. Non-negotiable constraints (security, performance, compatibility, timeline).
5. Done criteria for the first activity.
6. Existing mode only: baseline reference (branch/commit/tag).

## After user answers
1. Summarize scope and assumptions.
2. Propose a feature slug.
3. Start artifacts (`make kickoff FEATURE="<feature>" MODULE="<module>" MODE="<greenfield|existing>"`).
4. If mode is `existing`, include baseline/context-pack steps.
5. Continue with research/planning guidance only.
