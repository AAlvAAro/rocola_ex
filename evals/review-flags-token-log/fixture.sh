#!/usr/bin/env bash
# Bug: TokenServer logs the Spotify access token (CLAUDE.md rule 5).
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_setup

replace_once lib/rocola/spotify/token_server.ex \
'    timer = Process.send_after(self(), :refresh, max(ms - s.margin_ms, 0))
' \
'    timer = Process.send_after(self(), :refresh, max(ms - s.margin_ms, 0))
    Logger.debug("Spotify token stored: #{a}, expires in #{exp}s")
'

commit "chore(token_server): debug log when tokens are stored"
write_review_inputs
