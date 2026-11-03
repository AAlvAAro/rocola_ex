---
name: session-steps
description: Scan the current chat for what was actually done (files created, decisions, commands, fixes), append it as numbered steps to the running Rocola steps log, and rebuild a formatted, shareable .docx. With the argument `deck`, also generate a "what's new" PowerPoint (only steps not yet presented) in the sample deck's style. Use when asked to document, log, or share what was done in this session, update the steps doc, or make a presentation of what's new. Not for writing code, README or ADR content, or committing.
argument-hint: "[deck]"
---

# session-steps

Argument: `$ARGUMENTS` (empty, or `deck`).

State lives in `docs/steps/` (gitignored, never commit):
- `steps.json`: source of truth
- `rocola-steps.docx`: rebuilt from it every run, so it only grows
- `whats-new-YYYYMMDD.pptx`: only with `deck`

## Procedure
1. Read `docs/steps/steps.json` (create it with the schema below if missing). Never rewrite or drop existing entries.
2. Scan the chat since the last logged entry. Only things that really happened: files written/edited, commands run and their result, decisions with the reason. No invented steps, no secrets or tokens.
3. Add ONE entry per topic worked on, written as a guide someone could follow: `summary` (1-2 sentences), 3-6 steps, each with `title` (short verb phrase), `detail` (what to do), `why` (the reason) and `how` (command or file path, optional). Also `headline` (a claim, for the deck) and 2-3 `takeaways` (short, high level). Docx = the full step-by-step; deck = only headline, takeaways and summary.
4. Update `topics[].status` (`done` | `in_progress` | `todo`). Topics for this homework: `CLAUDE.md`, `SKILL.md`, `Guardrail hook`. Add a topic only if the user starts a new one.
5. Run `uv run .claude/skills/session-steps/build.py docx`.
6. If the argument is `deck`: run `uv run .claude/skills/session-steps/build.py deck`. It uses entries with `"deck": false` and flips them to true, so the next deck only has what's new. Style rules are in `style.md`.
7. Reply with the output path(s) and a 2-line summary of what was added. Nothing else.

## Schema
```json
{"topics":[{"name":"CLAUDE.md","status":"done"}],
 "entries":[{"date":"2026-11-03","topic":"CLAUDE.md","title":"Wrote the project rules",
             "headline":"One file keeps the agent on the rails","summary":"...","takeaways":["..."],
             "steps":[{"title":"Define scope","detail":"...","why":"...","how":"CLAUDE.md"}],
             "deck":false}]}
```
