#!/usr/bin/env bash
# HW2 step 2: after Run 1, branch from BASE and change only the model: lines.
set -euo pipefail
cd "$(dirname "$0")/.."
BASE=$(git rev-parse hw2/agentic-workflow)
if [ -n "$(git status --porcelain)" ]; then
  git add -A && git commit -m "chore: run 1 leftovers"
fi
echo "Run 1 commits:"; git log --oneline "$BASE"..HEAD
git switch -c hw2/run2-model-per-agent "$BASE"
sed -i '' 's/^model: inherit/model: sonnet/' .claude/agents/tech-lead.md .claude/agents/builder.md
sed -i '' 's/^model: inherit/model: haiku/'  .claude/agents/product-reviewer.md .claude/agents/code-reviewer.md
git --no-pager diff
read -r -p "Take screenshot F of the diff above, then press Enter to commit... "
git commit -am "chore: model per agent (HW2 run 2)"
echo "Lever SHA: $(git rev-parse --short HEAD). On hw2/run2-model-per-agent. Now run: claude"
