#!/usr/bin/env bash
# Feature branch at hw3-eval-base. A plain question must be answered without starting /ship or any agent.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
ship_setup feat/next

