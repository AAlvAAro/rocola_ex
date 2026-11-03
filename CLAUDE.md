# Rocola

Personal hobby project: a jukebox for home and get-togethers. Guests scan a QR,
search Spotify, and request songs. The server runs on a Raspberry Pi and controls
playback on a Spotify Connect device (Sonos, phone, smart speaker) through the
Spotify Web API. The Pi never plays audio.

## Scope (read before adding features)
- Personal, non-commercial use only. Spotify's consumer accounts and Developer Terms
  don't allow playing Spotify in businesses or public venues. See README → "Usage".
- Don't build features aimed at commercial or public use: payments, tips,
  multi-venue/multi-tenant support, ads, or anything that monetizes Spotify content.
- If a request points that way, stop and ask first.

## Stack
- Elixir + Phoenix LiveView, SQLite (`ecto_sqlite3`), Tailwind
- Spotify behind the `Rocola.Spotify` behaviour, chosen by config:
  - `Rocola.Spotify.Fake` (dev/test default): in-memory catalog, fake devices, simulated playback. No Spotify account or token needed.
  - `Rocola.Spotify.Web` (later): real Web API via `Req` + `TokenServer`.
- Deployed as a `mix release` built for `aarch64` (Raspberry Pi 4/5), run by systemd
- Tidewave (dev only) exposes the running app to the agent over MCP

## Commands
- `mix setup` — deps, DB, assets
- `iex -S mix phx.server` — dev server on http://localhost:4000
- `mix test` — run tests
- `mix precommit` — compile with warnings as errors, format, test (run before finishing any task)

## Layout
- `lib/rocola/spotify.ex` — the behaviour (callbacks: search, devices, add_to_queue, now_playing, ...)
- `lib/rocola/spotify/fake.ex` — fake adapter; `lib/rocola/spotify/web.ex` — real adapter
- `lib/rocola/jukebox/` — queue rules, rate limits, request log (context module)
- `lib/rocola/spotify/token_server.ex` — (real adapter only) holds and refreshes the access token
- `lib/rocola_web/live/` — LiveViews: `RequestLive` (guests), `AdminLive` (device picker)
- `docs/adr/` — architecture decisions; read before changing structure

## Rules
1. Run `mix precommit` and make it pass before saying a task is done.
2. All Spotify access goes through the `Rocola.Spotify` behaviour; never call an adapter module directly. LiveViews call contexts, never `Req` or `Repo` directly.
3. A new Spotify capability = new behaviour callback + `Fake` implementation (+ `Web` stub) in the same change. The Fake must mirror real API limits (add-only queue, `is_restricted`).
4. Tests never hit the network: use the Fake or fixtures.
5. Never log, print, or store Spotify tokens or client secrets outside `TokenServer` state.
6. Devices with `is_restricted: true` are shown as unavailable and never sent commands.
7. Guests get at most 3 queued songs per session per 30 min, and a song already in the queue is rejected. These rules live in `Rocola.Jukebox` and have tests.
8. Never edit a migration that already exists; create a new one.
9. Don't add a dependency without saying why in the reply.

## Tidewave (use it before guessing)
The dev server exposes Tidewave MCP at `http://localhost:4000/tidewave/mcp`.
- Use `project_eval` to try code inside the running app instead of writing throwaway scripts.
- Use `get_docs` for Elixir/Phoenix/dependency docs and `get_source_location` to find definitions.
- Use `execute_sql_query` to inspect data; read-only queries unless asked.
- Use `get_logs` when debugging a LiveView or Spotify error.
- If the MCP tools aren't available, the dev server isn't running: ask me to start it.

## Git
- Work on a feature branch; never commit directly to `main`.
- Small commits, Conventional Commits style (`feat:`, `fix:`, `test:`, `docs:`, `chore:`).
- Commit only after `mix precommit` passes.
- Never push, force-push, rebase shared branches, or amend pushed commits without asking.
- Never commit `.env`, `config/*.secret.exs`, or the token cache.
