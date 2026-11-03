# Rocola

A jukebox for home and get-togethers. Guests scan a QR code, search for songs and request them.
The server (a Raspberry Pi) controls playback on a Spotify Connect device; the Pi never plays audio.

Elixir + Phoenix LiveView, SQLite. Spotify sits behind the `Rocola.Spotify` behaviour: the
default `Fake` adapter needs no account; the real Web API adapter is a stub for now.

## Run
```
mix setup
iex -S mix phx.server   # http://localhost:4000
mix precommit
```

## Usage
Personal, non-commercial use only. Spotify's consumer terms and Developer Terms don't allow
playing Spotify in businesses or public venues. To use real playback you need your own Spotify
Premium account and your own developer app. Rocola is not affiliated with or endorsed by Spotify.

## Docs
Architecture decisions: [`docs/adr/`](docs/adr). Agent rules: [`CLAUDE.md`](CLAUDE.md).
