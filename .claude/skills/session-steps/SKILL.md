---
name: session-steps
description: Scan the current chat for what was actually done (files created, decisions, commands, fixes), append it as numbered steps to the running Rocola steps log, and rebuild a shareable PowerPoint (general steps plus a code example per topic, no docx) in the sample deck's style. Use when asked to document, log, or share what was done in this session, update the steps deck, or make a presentation of it. Not for writing code, README or ADR content, or committing.
---

# session-steps

State lives in `docs/steps/` (gitignored, never commit):
- `steps.json`: source of truth
- `rocola-steps.pptx`: the only output, rebuilt from it every run, so it only grows

## Procedure
1. Read `docs/steps/steps.json` (create it with the schema below if missing). Never rewrite or drop existing entries.
2. Scan the chat since the last logged entry. Only things that really happened: files written/edited, commands run and their result, decisions with the reason. No invented steps, no secrets or tokens.
3. Add ONE entry per topic worked on, written as a guide someone could follow: `summary` (1-2 sentences), 3-6 steps, each with `title` (short verb phrase), `detail` (what to do), `why` (the reason) and `how` (command or file path, optional). Also `headline` (a claim, for the deck) and 2-3 `takeaways` (short, high level). Add `code`: a snippet that shows the topic, preferably read from the repo as `{"file":"CLAUDE.md","start":"^## Rules","end":"^## Tidewave","skip":1,"n":14}` (regexes), or literal `{"lines":[...]}`. The deck shows per topic: headline, step titles (general steps, keep them short), the code example and the summary. `detail`/`why`/`how` are kept in the log but not shown.
4. Update `topics[].status` (`done` | `in_progress` | `todo`). Topics for this homework: `CLAUDE.md`, `SKILL.md`, `Guardrail hook`. Add a topic only if the user starts a new one.
5. Run `uv run .claude/skills/session-steps/build.py`. Style rules are in `style.md`.
6. Reply with the output path and a 2-line summary of what was added. Nothing else.

## Schema
```json
{"topics":[{"name":"CLAUDE.md","status":"done"}],
 "entries":[{"date":"2026-11-03","topic":"CLAUDE.md","title":"Wrote the project rules",
             "headline":"One file keeps the agent on the rails","summary":"...","takeaways":["..."],
             "steps":[{"title":"Define scope","detail":"...","why":"...","how":"CLAUDE.md"}],
             "code":{"file":"CLAUDE.md","start":"^## Rules","end":"^## Tidewave","skip":1}}]}
```
