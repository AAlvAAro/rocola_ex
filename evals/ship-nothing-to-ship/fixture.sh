#!/usr/bin/env bash
# Feature branch at hw3-eval-base with every roadmap ticket marked done.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
ship_setup feat/next
sed -i.bak -E "s/^(\| ROC-[0-9]+ \| P[0-9] \| )[a-z-]+ \|/\1done |/" docs/roadmap.md
rm docs/roadmap.md.bak
grep -q "| open |" docs/roadmap.md && { echo "roadmap still has open tickets" >&2; exit 1; }
git commit -qam "docs: mark every roadmap ticket done"
