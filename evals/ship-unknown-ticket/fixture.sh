#!/usr/bin/env bash
# Workspace on a feature branch at hw3-eval-base. ROC-999 is not in the roadmap.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
ship_setup feat/next

