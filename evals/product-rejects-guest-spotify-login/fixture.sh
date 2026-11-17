#!/usr/bin/env bash
# Flaw: every guest logs in with their own Spotify account. The story says
# "Guests never log in to Spotify" and ROC-004 says guests join "with no account".
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_design_setup

f=docs/tdd/ROC-002.md

replace_once "$f" \
'Guests never touch any of this.' \
'Every guest also logs in with their own Spotify account when they join, so each request is made with the guest'"'"'s own account.'

replace_once "$f" \
'### Context (`lib/rocola/jukebox.ex`)' \
'### Guest login
- `RequestLive` shows a "Log in with Spotify" button before a guest can search. It uses the same `/auth/spotify` flow with `?as=guest`.
- `TokenServer` state becomes `%{tokens: %{session_id => %{access_token, refresh_token, expires_at, timer}}}`: one token pair and one refresh timer per guest, keyed by the guest'"'"'s session id. The host keeps the `:host` key.
- `Jukebox.request_song/2` adds the track with the requesting guest'"'"'s token, so Spotify shows who queued it.
- A guest who skips the login can browse the queue but can'"'"'t request songs.

### Context (`lib/rocola/jukebox.ex`)'

replace_once "$f" \
'- Guest login of any kind.
' \
''

commit "docs: ROC-002 TDD"
