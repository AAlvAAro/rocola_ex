# HW3 · Eval set for `/ship` + week 2 re-run

Plan for Claude Code. Read this file and `CLAUDE.md`, then work through the phases in order.
Stop and ask Alvaro at each **[ASK]**. Don't push anything.

## The homework (Week 3 · Memory & Evals, shown live at Office Hours 3)
1. **An eval set**: 20+ cases that test in both directions (should act / should refuse), for something I built. `claude plugin eval` or my own harness.
2. **Week 2 re-run**: before and after on the same suite, reporting pass rate and cost per run.
3. *(Optional)* **A promotion**: a repeated correction promoted to a rule, skill or hook, with its diff.

The thing under test is the **`/ship` workflow** from week 2:
`.claude/commands/ship.md` plus four agents in `.claude/agents/` (tech-lead, product-reviewer, builder, code-reviewer).
**Don't change those files' content while building the suite.** We're measuring them as they are.
If the eval finds a real defect, the fix becomes deliverable 3 (Phase 5).

## Where things stand (already committed)
| Ref | What |
|---|---|
| `main` @ `8691908` | Landing page; ROC-001 not implemented |
| `hw2/agentic-workflow` | `/ship` + agents (all `model: inherit`), `docs/roadmap.md` (ROC-001..003 open), `docs/bench/hw2/`, `scripts/hw2_*.sh` |
| tag **`hw3-eval-base`** | Same commit. **Every eval workspace is cloned from this tag.** It contains no `evals/`, so the agent under test can't read the cases. |
| `hw3/evals` | This branch: `hw3-eval-base` + this plan. Build the suite here. |
| `hw2/run0-single` | Week 2 run 0: ROC-001 done by one agent, no subagents |
| `feat/roc-001-admin-device-picker` | ROC-001 done by `/ship` (`941347f` feat, `f64da44` docs: TDD + review APPROVED). Source for fixtures. |

The week 2 **change** is the model lever in `scripts/hw2_lever.sh`:
product-reviewer and code-reviewer go to `haiku`, tech-lead and builder go to `sonnet`. Nothing else changes.
**[ASK]** Do you have the week 2 numbers (per-agent tables and `/usage` totals for run 1 and run 2)? Put them in `docs/homework-3.md` if so. Either way, this suite re-runs both arms fresh.

## How `claude plugin eval` constrains us (docs: code.claude.com/docs/en/plugin-evals)
- Needs a plugin: `.claude-plugin/plugin.json` (or a skills-dir plugin). It loads the plugin's skills, hooks and **agents**.
- Each run starts in an **empty temp workspace**. Workspace files come from `context.scaffold_script` (in `case.yaml`), which only runs with `--scaffold`. It runs outside the sandbox with a 120 s limit and a minimal env.
- **No project config loads in a run**: no `CLAUDE.md`, `.claude/`, `.mcp.json` or hooks, even if the scaffold wrote them. Agents can still `Read` `CLAUDE.md` as a plain file.
- Only `EVAL_*` env vars reach the run. Bash runs under the OS sandbox: writes stay inside the workspace, **`$HOME` is unreadable**, and the network is off unless granted.
- Graders (no custom code): `regex` (target `last_message` | `trace` | `files` | `{source: file, path: ...}`), `tool_used`, `tool_order`, `file_exists` (only files created during the run), `llm` (3 votes; PASS on 2 of 3), `baseline`.
- Use `--ablation none`. Without the plugin, `/ship` and its agents don't exist, so with/without Δ is meaningless.
  The comparison we care about is **arm A (inherit) vs arm B (lever)**.

## Phase 0 · Spike (timebox 45 min, go/no-go)
Goal: prove the mechanics on 2 throwaway cases before writing 22.
1. `claude --version` (need ≥ 2.1.269) and `git --version` (≥ 2.31).
2. Add `.claude-plugin/plugin.json` at the repo root, named `rocola`, pointing at the existing folders
   (`"commands": "./.claude/commands/"`, `"agents": "./.claude/agents/"`). Leave hooks out.
   Run `claude plugin validate .`. Don't move or copy the agent files.
3. Spike case 1 (product-reviewer, read-mostly): the scaffold clones `hw3-eval-base` into the workspace and adds a fixture TDD.
   The prompt dispatches `rocola:product-reviewer`. Check that the agent resolves (namespaced name), that `Edit` works with
   `--allow-tools Edit`, and that a `regex` grader on `{source: file, path: docs/tdd/X.md}` sees `Decision: ...`.
4. Spike case 2 (orchestrator): prompt `/ship ROC-002` (try `/rocola:ship ROC-002` if the bare name fails) on a workspace branch
   that isn't `main`, with `max_turns: 6`. Check that the command expands in `-p` mode and that the first `Agent` call is tech-lead with ROC-002.
5. Elixir in the sandbox: from inside a run, try `mix --version` and `mix test` (`--allow-tools "Bash(mix *)"`).
   Expect failures because `$HOME` (`~/.mix`, `~/.hex`, and any mise/asdf install) is unreadable.
   Try copying `MIX_HOME`/`HEX_HOME` into the workspace from the scaffold and setting them via `append_system_prompt`.
   Don't spend more than 15 min on this.

**Decision rule.** Tiers A–C don't need `mix`, so they go into `claude plugin eval` if steps 3–4 work.
Tier D (end-to-end, needs `mix precommit`) uses plugin eval only if step 5 works. Otherwise it uses the **fallback harness** below.
Write the findings into `docs/homework-3.md` § "Setup notes" (that's demo material too).
**[ASK]** Report the go/no-go and the cost of the two spike runs before Phase 1.

## Phase 1 · The suite (22 cases, both directions)
Layout: `evals/A_gates/<case>/`, `evals/B_product/<case>/`, `evals/C_review/<case>/`, `evals/D_e2e/<case>/`,
plus `evals/_lib/workspace.sh`, a shared helper the scaffolds source.
- Clone `hw3-eval-base` into the cwd (find the repo from the script's own path), set `user.name`/`email`,
  check out the branch the case needs, then apply the case's fixture.
- Fixtures live in each case dir as files or patches. Generate them from `git show feat/roc-001-admin-device-picker:<path>`,
  never by hand-copying long content.
- Every grader should be deterministic where possible. Use `llm` only for short text, with explicit PASS/FAIL conditions.

### A · Orchestrator gates and routing (`/ship`) — 7 cases
| Case | Setup | Pass when |
|---|---|---|
| A1 refuses-on-main | workspace on `main` | reply says it won't run on main; `tool_used Agent` min 0 / max 0; no `docs/tdd/*` created |
| A2 unknown-ticket | `/ship ROC-999` | reply says not found; no Agent call |
| A3 nothing-open | roadmap with every ticket `done` | says nothing to ship; no Agent call |
| A4 picks-priority | add ROC-004 **P1** open; ROC-001 marked done | first Agent call's input mentions ROC-004, none mentions ROC-002 (`max_turns` low; grade the dispatch) |
| A5 explicit-id-wins | `/ship ROC-003` while ROC-002 is P2 open | first Agent call mentions ROC-003 |
| A6 skips-non-open | ROC-001 `tdd`, ROC-002 `rejected`, ROC-003 open | dispatch mentions ROC-003 only |
| A7 no-workflow-on-question | "How does the device picker decide which devices to show?" | no Agent call, no Write/Edit (should-NOT-act) |

### B · Product gate (`rocola:product-reviewer` on a fixture TDD) — 6 cases
Pass when the TDD file has the expected `Decision:` and nothing outside `## Product review` changed (`regex` on the file).
For rejections, one short `llm` grader checks that the reason names the real problem.
| Case | Fixture TDD | Expected |
|---|---|---|
| B1 clean-roc001 | the approved ROC-001 TDD with its review section stripped | APPROVED |
| B2 tip-jar | guests tip the host via a payment link | REJECTED (scope: payments) |
| B3 multi-venue | one server for several cafés | REJECTED (scope: commercial / multi-venue) |
| B4 missing-edge-cases | ROC-001 TDD without the restricted / empty / error states | REJECTED (edge cases) |
| B5 gold-plating | ROC-003 TDD that also adds play history export + analytics | REJECTED (scope creep) |
| B6 clean-roc003 | a tight now-playing banner TDD | APPROVED |

### C · Code reviewer (`rocola:code-reviewer` on a planted diff) — 6 cases
Workspace = `hw3-eval-base` + ROC-001 implementation (`941347f`) + the TDD, then one planted commit on top.
The brief gives the base SHA. Grant `"Bash(git diff *)" "Bash(git log *)" "Bash(git show *)" Write`.
`mix test` won't run (see Phase 0); note that in the writeup. Pass when `docs/reviews/ROC-001.md` has the right `Cn: fail` and the reply says `CHANGES_REQUESTED`, or APPROVED for C6.
| Case | Planted change | Expected |
|---|---|---|
| C1 liveview-calls-adapter | `AdminLive` calls `Rocola.Spotify.Fake.devices/0` directly | C1 fail |
| C2 callback-without-fake | new `skip/0` callback, no Fake impl / Web stub | C2 fail |
| C3 test-hits-network | a test that `Req.get`s api.spotify.com | C3 fail |
| C4 restricted-gets-command | `select_device/1` drops the `is_restricted` check | C4 fail |
| C5 no-tests | new behaviour with its test file deleted | C5 fail |
| C6 clean | the real approved ROC-001 commit, nothing planted | APPROVED, all pass, 0 open comments (no false positives) |

C1–C5 are where the Haiku lever is most likely to hurt. A reviewer that misses a planted violation is the headline finding if it happens.

### D · End-to-end `/ship` — 3 cases
ROC-001 (same ticket as week 2), ROC-002, ROC-003, each from `hw3-eval-base`.
Pass when: roadmap Status `done`; `docs/tdd/<ID>.md` has `Decision: APPROVED`; `docs/reviews/<ID>.md` final round `Decision: APPROVED` with all C1–C5 `pass`; ≤ 2 review rounds; a `docs: ship <ID>` commit exists; `mix precommit` passes.

**Count:** 7 + 6 + 6 + 3 = 22. Should-act / should-refuse split: 11 / 11 (A1–A3, A7, B2–B5, C1–C5 refuse or reject).

### Fallback harness (only for what plugin eval can't run)
`scripts/eval_ship.sh <arm> <case> <trial>`:
1. `git worktree add /tmp/rocola-eval/<arm>-<case>-<trial> hw3-eval-base`, then apply the fixture.
2. Copy the arm's agent files in.
3. `claude -p "/ship <ID>" --output-format json --model <MAIN_MODEL> --permission-mode acceptEdits` with a turn cap.
4. Grade with the same checks as above in bash.
5. Append one row to `docs/bench/hw3/e2e.csv`: `arm,case,trial,pass,checks_passed,cost_usd,turns,duration_s`.

Reuse the JSON-array parsing fix from `scripts/measure_skill.sh`. The real `~/.mix` toolchain is available here.

## Phase 2 · Calibrate before the real runs
- Run each case once on arm A: `claude plugin eval . --scaffold --ablation none --runs 1 --allow-tools ...`.
- **Read the transcripts of every failure** before blaming the agent. A 0% case usually means a broken case or grader.
- Fix the cases and graders, not `/ship`. Write a reference solution for any grader you doubt.
- Re-check that 11/11 balance still holds.

## Phase 3 · The two arms (same everything else)
Pin these for both arms and record them in the writeup: `--model <MAIN_MODEL>`, `--judge-model claude-haiku-4-5`, Claude Code version, `--runs 3`.
**[ASK]** Confirm `<MAIN_MODEL>` (default: whatever week 2 run 1 used, probably Opus) and the budget below before starting.
- **Arm A (before):** on `hw3/evals` (agents `inherit`):
  `claude plugin eval . --scaffold --trust-plugin --ablation none --runs 3 --model <MAIN_MODEL> --judge-model claude-haiku-4-5 --threshold 0.8 --no-publish --json docs/bench/hw3/armA.json --max-cost-usd <cap>`
- **Arm B (after):** create branch `hw3/lever` from `hw3/evals` and change only the four `model:` lines (same sed as `scripts/hw2_lever.sh`).
  Run the same command from a worktree of `hw3/lever`, with `--json docs/bench/hw3/armB.json`.
  The plugin loads from the checked-out tree, so the workspace clone stays identical across arms.
- Tier D: 1 trial per arm first; add a second trial only if the budget allows. Say so in the writeup.
- **Budget:** run tiers A–C, report the actual cost, then **[ASK]** before tier D.
  Never exceed a `--max-cost-usd` I approved. Use `-j 3` to save wall time.

## Phase 4 · Writeup: `docs/homework-3.md` (5-minute demo)
1. **Eval set**: tree of `evals/`, the 22-case table (tier, direction, graders), one case shown in full (prompt.md, case.yaml, graders).
2. **Results**: per tier and overall, a table with columns: arm, pass rate, mean score, cost per run, total cost, wall time.
   Add pass@3 vs pass^3 for tier D if it has 3 trials.
3. **Honesty box**: n, a 95% interval (±1.96·√(p(1−p)/n)), and whether the A vs B intervals overlap.
   If they overlap, the conclusion is "no evidence of a difference," not "B is just as good."
4. **Decision**: ship the lever or not, and per agent if the data says so (e.g. keep code-reviewer on inherit).
5. **Setup notes**: what Phase 0 found (sandbox, `mix`, namespaced agents) and what went to the fallback harness.
6. Slots for screenshots: summary tables for both arms, one failing transcript, the report.html.

Commit in small Conventional Commits on `hw3/evals` (`test: add eval cases ...`, `docs: homework 3 results`).
Never commit `evals/results/` (it's in `.gitignore`); copy the two `aggregate-result.json` files into `docs/bench/hw3/` instead.

## Phase 5 · (Optional) promotion
If a case exposes a defect that's a repeated pattern (e.g. the Haiku reviewer keeps missing restricted-device commands), promote the fix to the right layer:
- an agent prompt change → a skill or `CLAUDE.md` rule
- something that must always hold → a hook or `permissions.deny`

Show the diff, re-run only the affected cases on both arms, and add a before/after line to the writeup.
If nothing failed, use the week 1 protect-hook story instead: the bypass, then the wider matcher plus `permissions.deny`.
Its diff is in `git log -p .claude/settings.json`.

## Done when
- [ ] `claude plugin eval . --scaffold --ablation none` loads 22 cases with no load errors (or 19 plus the D harness)
- [ ] Arm A and arm B results are saved in `docs/bench/hw3/`, with the same pinned models
- [ ] `docs/homework-3.md` has the tables, the interval check and a decision
- [ ] `mix precommit` still passes on `hw3/evals` (the suite didn't break the app)
- [ ] Everything is committed on `hw3/evals` and `hw3/lever`; nothing pushed
