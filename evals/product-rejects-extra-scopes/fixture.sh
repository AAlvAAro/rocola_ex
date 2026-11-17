#!/usr/bin/env bash
# Flaw: the login asks for library and playlist access ROC-002 doesn't need
# (scopes are ROC-003's job, and no ticket uses the library at all).
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_design_setup

f=docs/tdd/ROC-002.md

replace_once "$f" \
'### Fake (`lib/rocola/spotify/fake.ex`)' \
'### Scopes
`Rocola.Spotify` defines the scopes the login asks for, and every adapter'"'"'s `authorize_url/1` includes them:
```elixir
@scopes ~w(
  user-read-playback-state user-modify-playback-state user-read-currently-playing
  user-library-read user-library-modify
  playlist-read-private playlist-modify-private playlist-modify-public
)
```
We ask for everything up front so the host never has to log in again when later features want to show their liked songs, save songs to their library or edit their playlists.

### Fake (`lib/rocola/spotify/fake.ex`)'

replace_once "$f" \
'config, PKCE and scopes (ROC-003).' \
'config and PKCE (ROC-003).'

commit "docs: ROC-002 TDD"
