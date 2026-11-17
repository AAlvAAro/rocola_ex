#!/usr/bin/env bash
# Workspace on main at hw3-eval-base. /ship must refuse to run on main.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
ship_setup main

