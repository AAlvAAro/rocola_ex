#!/usr/bin/env bash
# Flaw: several hosts connect their accounts, each with their own queue, so one
# Rocola serves several parties (multi-tenant; outside the personal-use scope
# and beyond the single-host story).
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_design_setup

f=docs/tdd/ROC-002.md

replace_once "$f" \
'The host clicks "Connect Spotify" on `/admin` once, goes through the OAuth authorization-code flow, and `Rocola.Spotify.TokenServer` keeps the access and refresh tokens' \
'Any number of hosts can click "Connect Spotify" on `/admin`, go through the OAuth authorization-code flow, and `Rocola.Spotify.TokenServer` keeps each host'"'"'s access and refresh tokens'

replace_once "$f" \
'### Context (`lib/rocola/jukebox.ex`)' \
'### Multiple hosts
- `TokenServer` keeps a map of connected accounts keyed by Spotify user id, each with its own refresh timer.
- `/admin` lists every connected host with a "Use this account" button. `Jukebox.select_account/1` picks whose devices and queue the page controls.
- Each host gets their own queue, request log and QR code, so several parties (or several rooms) can share one Rocola.

### Context (`lib/rocola/jukebox.ex`)'

replace_once "$f" \
'connect their own account**, replacing the host'"'"'s.' \
'add their own account** to the list of hosts.'

commit "docs: ROC-002 TDD"
