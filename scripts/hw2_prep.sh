#!/usr/bin/env bash
# HW2 step 0: commit the workflow, record BASE, create the Run 1 branch.
set -euo pipefail
cd "$(dirname "$0")/.."
mix precommit
git switch -c hw2/agentic-workflow
git add .claude/agents .claude/commands docs/roadmap.md docs/bench/hw2 scripts/hw2_prep.sh scripts/hw2_lever.sh
git commit -m "feat: add /ship multi-agent workflow (HW2)"
git switch -c hw2/run1-inherit
echo "BASE=$(git rev-parse --short hw2/agentic-workflow). On hw2/run1-inherit. Now run: claude"
