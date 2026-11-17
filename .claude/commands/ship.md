---
description: Orchestrate the Rocola ticket-to-commit workflow. Picks the highest-priority open ticket, then tech-lead -> product-reviewer -> builder -> code-reviewer loop. Usage: /ship [ticket ID]
argument-hint: [ROC-NNN]
---
You are the orchestrator. You don't write code or docs yourself: you pick the ticket, write each brief, read the short returns, update the roadmap Status and decide the next step.

## 0. Setup
- Refuse to run on `main`. Record `BASE=$(git rev-parse HEAD)` and the current branch.
- Ticket = $ARGUMENTS if given, else the highest-priority `open` row in `docs/roadmap.md` (P1 > P2 > P3, then lowest ID).

## Pipeline (each step starts only when the previous one returns)
1. **tech-lead** -> set Status `tdd`.
2. **product-reviewer** (barrier / gate). REJECTED -> one more tech-lead pass with the reasons, then product-reviewer again. Rejected twice -> set Status `rejected` and stop.
3. Approved -> Status `approved` -> **builder** in BUILD mode -> Status `in-review`.
4. **code-reviewer** round 1. CHANGES_REQUESTED -> **builder** FIX mode -> code-reviewer round 2.
   Max 2 review rounds. Still open after round 2 -> stop and list them for a human.
5. APPROVED -> Status `done`, and commit `docs/roadmap.md`, `docs/tdd/<ID>.md` and `docs/reviews/<ID>.md` as `docs: ship <ID>`.

## Briefs
Subagents start with a fresh context: they don't see this conversation. Every brief uses this shape and stays under 150 words:
```
Task: ...
Context: ticket <ID> "<title>": <user story>. Files: <paths from the previous step>. Base commit: <BASE>.
Constraints: follow CLAUDE.md; <step-specific limits>.
Return: <exactly what that agent's file says to return>. No transcript.
```
Pass on only what the next step needs (paths, decisions, SHAs), never a previous agent's full output.

## Final report (in chat)
1. A table with one row per subagent call, in order, plus a Total row. Take the numbers from each Agent result (tokens, tool uses, duration):

| # | Agent | Model · effort | Tokens | Tool uses | Duration | Result |
|---|---|---|---|---|---|---|

2. One line: `Verdict: READY | BLOCKED · tests N/N passed · review rounds R/2 · open comments C · TDD revisions T`.
3. The commits created (`git log --oneline <BASE>..HEAD`) and the ticket's final Status.
4. Remind me to run `/usage` and `/tasks` and take screenshots.
