---
name: spotify-web-api
description: Rocola's Spotify know-how. Use when adding or changing anything that searches songs, lists devices, queues or skips tracks, or shows now-playing, including the Rocola.Spotify behaviour and its Fake and Web adapters. Not for UI-only styling, renames or non-Spotify work.
---

# Spotify in Rocola

All Spotify access goes through the `Rocola.Spotify` behaviour (`lib/rocola/spotify.ex`).
Adapters: `Fake` (dev/test default, no token) and `Web` (real API, stub). Never call an adapter directly.

## Recipe for a new Spotify capability
1. Add a `@callback` and a delegating function in `Rocola.Spotify`.
2. Implement it in `Fake` AND stub it in `Web` (`{:error, :not_implemented}`), same change.
3. Put queue/limit/vote rules in `Rocola.Jukebox`, never in the adapter.
4. LiveViews call `Rocola.Jukebox`/`Rocola.Spotify`, never `Req` or `Repo`.
5. Tests use the Fake (`Rocola.Spotify.Fake.reset/0` in `setup`), never the network.
6. `mix precommit` must pass.

## Real API rules the Fake must mirror
- The queue is add-only: no remove, no reorder. Skips, votes and per-guest limits live in Rocola's own
  SQLite queue; send Spotify one song ahead. Never add a "remove from queue" callback.
- Playback commands need Premium and an active device. Devices only appear while awake.
- Devices with `is_restricted: true` are shown unavailable and never get commands.
- Success is often `204 No Content` with no body: don't pattern-match on a body.
- `429` carries a `Retry-After` header (seconds): wait that long, then retry once.
- There is no push for track changes: poll `now_playing` (or broadcast over PubSub from the context that owns playback).

## Real adapter (later)
Authorization Code flow; access token refreshed only by `Rocola.Spotify.TokenServer`; never log or store
tokens elsewhere. Scopes: `user-read-playback-state`, `user-modify-playback-state`,
`user-read-currently-playing`. Endpoint details: `reference/endpoints.md`.
