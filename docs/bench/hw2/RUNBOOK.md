# HW2 runbook: two /ship runs, with screenshots

Do the git steps in a normal terminal, NOT inside Claude Code, so they don't count in a run's /usage.
Claude Code prompts are marked with `>`.

## Screenshots on macOS
- **Cmd + Ctrl + Shift + 4, then Space, then click the terminal window**: copies that window to the clipboard. Paste it straight into the Claude Doc (Cmd + V).
- Without Ctrl it saves a PNG to the Desktop instead.
- Make the terminal tall before /usage so the whole screen fits (Subagents section included). If it doesn't fit, take two shots.

## 0 · Prep (terminal, once, about 3 min)
```bash
cd ~/Projects/Ballastlane/Rocola
mix precommit                        # must pass BEFORE the runs, or both runs fix old failures
git switch -c hw2/agentic-workflow
git add .claude/agents .claude/commands docs/roadmap.md docs/bench/hw2
git commit -m "feat: add /ship multi-agent workflow (HW2)"
git rev-parse --short HEAD           # BASE, write it down: __________
git switch -c hw2/run1-inherit
```

## 1 · Run 1, every agent on inherit (about 10-15 min)
```bash
claude
```
> /model
Pick the model you'll use in BOTH runs (e.g. Opus), and don't change it, /clear or /compact during the run.

> /agents
**Screenshot A**: the four agents listed (for part 01).

> /ship ROC-001
Approve permission prompts as they come (or press Shift+Tab once for auto-accept edits before sending). Don't type anything else while it runs.
**Screenshot B**: the screen while agents run (the tech-lead/builder progress lines).
**Screenshot C**: the final report table (per agent: model, tokens, tool uses, duration) + Verdict line.

> /usage
**Screenshot D**: total cost, usage by model, cache, and the "Subagents % of usage" section.

> /tasks
**Screenshot E**: each subagent with its model.

> /exit

Then in the terminal:
```bash
git status                           # should be clean; if not: git add -A && git commit -m "chore: run 1 leftovers"
git log --oneline BASE..HEAD         # replace BASE; copy this into the doc
```

## 2 · The lever (terminal, 1 min)
```bash
git switch -c hw2/run2-model-per-agent BASE      # replace BASE
sed -i '' 's/^model: inherit/model: sonnet/' .claude/agents/tech-lead.md .claude/agents/builder.md
sed -i '' 's/^model: inherit/model: haiku/'  .claude/agents/product-reviewer.md .claude/agents/code-reviewer.md
git diff
```
**Screenshot F**: the git diff (only four `model:` lines changed).
```bash
git commit -am "chore: model per agent (HW2 run 2)"
git rev-parse --short HEAD           # lever SHA for part 02: __________
```

## 3 · Run 2 (about 10 min)
Same workflow, same ticket: only the four `model:` lines changed. Exactly the same as step 1, in a fresh `claude` session with the same /model, and the SAME first prompt you used in Run 1 (the context prompt or `/ship ROC-001`).

**Screenshots G, H, I**: the final report table, /usage and /tasks (same as C, D, E).
Then `/exit` and `git status` / `git log --oneline` as in step 1.

## 4 · Fill the doc (about 10 min)
- Part 01: prompt `/ship ROC-001`, screenshots A, B, C, E; copy Run 1's per-agent table.
- Part 02: lever SHA, screenshot F, the /usage table from D and H (total, Opus, Sonnet, Haiku, API duration), screenshots D and H.
- Part 03: decision log, and what you'd cut next time.
- Paste both per-agent tables and both /usage totals back to Claude in chat, and it writes the "where the saving came from" paragraph.

Keep both branches (`hw2/run1-inherit`, `hw2/run2-model-per-agent`) for week 3.
