# 001: Architecture

## Decisions
- **Spotify behind a behaviour.** `Rocola.Spotify` defines the callbacks; `Fake` (default in dev/test)
  and `Web` (real API + `TokenServer`, stub) implement them. Switching is config plus credentials.
  Why: build and test with no account, token or network.
- **Own queue.** Spotify's API can add to its queue but not remove or reorder, so Rocola keeps its
  queue in SQLite (skips, votes, per-guest limits) and feeds Spotify one song ahead.
- **Fake mirrors real limits** (add-only queue, restricted devices, active device required) so
  behaviour proven against it carries over to the real adapter.
- **Stack:** Phoenix LiveView, SQLite (`ecto_sqlite3`), `mix release` for aarch64 on a Raspberry Pi.
- **Tidewave** (dev only) gives the coding agent access to the running app over MCP.
