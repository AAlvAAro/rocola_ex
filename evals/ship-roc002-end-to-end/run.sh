#!/usr/bin/env bash
# End-to-end eval: run `/ship ROC-002` from tag hw3-eval-base and check that
#   1. the ticket ends as `done` in docs/roadmap.md,
#   2. `mix precommit` passes on the result,
#   3. the last code-review round in docs/reviews/ROC-002.md is APPROVED.
#
# Why a script and not a `claude plugin eval` case: inside the eval sandbox on
# macOS, the only git is Apple's /usr/bin/git shim, which can't write its xcrun
# cache, so git fails. Mix then can't verify the git deps (heroicons, daisyui)
# and the builder can't commit, so /ship can't finish. This script runs the same
# /ship command and agents (identical in the tag) with `claude -p` in a
# throwaway clone instead, outside the sandbox.
#
# Usage: evals/ship-roc002-end-to-end/run.sh      (BUDGET_USD=30 by default)
#        evals/ship-roc002-end-to-end/run.sh --verify-only <workspace> <results-dir>
#          re-runs only the checks on a finished workspace (no model calls).
# Exit 0 only if all three checks pass. Results go to evals/results/ship-roc002-<ts>/.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(git -C "$here" rev-parse --show-toplevel)"
budget="${BUDGET_USD:-30}"

if [ "${1:-}" = --verify-only ]; then
  clone="$(cd "$2" && pwd)"
  results="$(cd "$3" && pwd)"
  cd "$clone"
  base="$(git rev-parse hw3-eval-base)"
  claude_exit="$(cat "$results/claude-exit" 2>/dev/null || echo '?')"
  wall="$(cat "$results/wall-seconds" 2>/dev/null || echo '?')"
else
stamp="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
results="$repo/evals/results/ship-roc002-$stamp"
work="$(mktemp -d "${TMPDIR:-/tmp}/rocola-ship-roc002.XXXXXX")"
clone="$work/rocola"
mkdir -p "$results"

for t in hw3-eval-base; do
  git -C "$repo" rev-parse -q --verify "refs/tags/$t" >/dev/null || { echo "tag $t not found" >&2; exit 1; }
done

echo "== workspace: $clone"
git clone -q --no-checkout "$repo" "$clone"
cd "$clone"
git checkout -q -B feat/roc-002-ship hw3-eval-base
git remote remove origin # nothing in this run can be pushed anywhere
git config user.name "Rocola Eval"
git config user.email "eval@example.invalid"
base="$(git rev-parse HEAD)"

# Reuse the checkout's fetched deps and build (same mix.lock), so no network is needed.
cmp -s "$repo/mix.lock" mix.lock || { echo "mix.lock differs from $repo; run mix deps.get there" >&2; exit 1; }
cp -Rc "$repo/deps" deps 2>/dev/null || cp -R "$repo/deps" deps
cp -Rc "$repo/_build" _build 2>/dev/null || cp -R "$repo/_build" _build

echo "== running /ship ROC-002 (budget \$$budget)"
started=$SECONDS
set +e
claude -p "/ship ROC-002" \
  --output-format json \
  --setting-sources project,local \
  --strict-mcp-config \
  --no-session-persistence \
  --permission-mode acceptEdits \
  --max-budget-usd "$budget" \
  --allowedTools Read Glob Grep Edit Write Agent \
    "Bash(mix *)" "Bash(git *)" "Bash(ls *)" "Bash(grep *)" "Bash(head *)" "Bash(tail *)" "Bash(wc *)" \
  >"$results/claude-result.json" 2>"$results/claude-stderr.log"
claude_exit=$?
set -e
wall=$((SECONDS - started))
echo "$claude_exit" >"$results/claude-exit"
echo "$wall" >"$results/wall-seconds"
fi

# 1. Roadmap status
status="$(awk -F'|' '$2 ~ /ROC-002/ { gsub(/ /, "", $4); print $4 }' docs/roadmap.md)"
[ "$status" = done ] && c1=PASS || c1=FAIL

# 2. mix precommit on whatever /ship left behind
set +e
mix precommit >"$results/precommit.log" 2>&1
pc_exit=$?
set -e
[ "$pc_exit" -eq 0 ] && c2=PASS || c2=FAIL
# ExUnit prints "N tests, M failures" (older) or "Result: N passed[, M failed]" (newer).
pc_tail="$(grep -E '[0-9]+ tests?, [0-9]+ failures?|^Result: ' "$results/precommit.log" | tail -1 || true)"
dirty="$(git status --porcelain | grep -v -E '^\?\? (deps|_build)/' || true)"

# 3. Last review round approved. code-reviewer.md puts APPROVED in its reply to
# /ship, not necessarily in the file, so judge the file's last round directly:
# no open "- [ ]" comment, no C1-C5 "fail", no CHANGES_REQUESTED.
review="$(python3 -I - docs/reviews/ROC-002.md <<'PY'
import sys, os
p = sys.argv[1]
if not os.path.exists(p):
    print("FAIL no review file"); sys.exit()
last = open(p).read().split("\n## Round")[-1]
import re
ok = ("- [ ]" not in last and "CHANGES_REQUESTED" not in last
      and not re.search(r"\bC[1-5]\s*:\s*fail", last, re.I))
rounds = open(p).read().count("\n## Round")
print(("PASS" if ok else "FAIL") + f" rounds={rounds}")
PY
)"
c3="${review%% *}"

# Cost and run stats from claude -p's JSON result
stats="$(python3 -I - "$results/claude-result.json" <<'PY'
import json, sys
try:
    r = json.load(open(sys.argv[1]))
except Exception as e:
    print(f"cost=? (no JSON result: {e})"); sys.exit()
print(f"cost=${r.get('total_cost_usd', 0):.2f} main-session turns={r.get('num_turns')} "
      f"subtype={r.get('subtype')} is_error={r.get('is_error')}")
PY
)"

git log --oneline "$base"..HEAD >"$results/commits.txt"
cp docs/roadmap.md "$results/roadmap.md" 2>/dev/null || true
cp docs/tdd/ROC-002.md "$results/tdd-ROC-002.md" 2>/dev/null || true
cp docs/reviews/ROC-002.md "$results/review-ROC-002.md" 2>/dev/null || true

{
  echo "check                     result"
  echo "ticket ends as done       $c1  (status: ${status:-missing})"
  echo "mix precommit passes      $c2  (exit $pc_exit; ${pc_tail:-no test summary})"
  echo "code review approved      $c3  (${review#* })"
  echo
  echo "claude -p exit $claude_exit · wall ${wall}s · $stats"
  echo "commits since hw3-eval-base:"
  sed 's/^/  /' "$results/commits.txt"
  [ -n "$dirty" ] && { echo "uncommitted changes after precommit:"; echo "$dirty" | sed 's/^/  /'; }
  echo
  echo "workspace: $clone"
  echo "results:   $results"
} | tee "$results/summary.txt"

[ "$c1$c2$c3" = PASSPASSPASS ]
