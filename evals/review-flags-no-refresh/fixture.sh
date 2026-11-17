#!/usr/bin/env bash
# Bug: store/2 no longer schedules the refresh, so the token expires after an hour.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_setup

replace_once lib/rocola/spotify/token_server.ex \
'    cancel(s.timer)
    ms = exp * 1000
    timer = Process.send_after(self(), :refresh, max(ms - s.margin_ms, 0))
    %{s | access_token: a, refresh_token: r, expires_at: now() + ms, timer: timer}' \
'    cancel(s.timer)
    ms = exp * 1000
    %{s | access_token: a, refresh_token: r, expires_at: now() + ms, timer: nil}'

commit "refactor(token_server): simplify store/2"
write_review_inputs
