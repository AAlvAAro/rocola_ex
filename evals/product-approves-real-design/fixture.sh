#!/usr/bin/env bash
# The real ROC-002 design, unchanged. The product reviewer should approve.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_design_setup

commit "docs: ROC-002 TDD"
