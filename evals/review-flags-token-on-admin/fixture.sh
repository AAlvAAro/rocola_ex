#!/usr/bin/env bash
# Bug: /admin renders the access token (CLAUDE.md rule 5).
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_setup

replace_once lib/rocola/jukebox.ex \
'  @spec disconnect_spotify() :: :ok' \
'  @doc "The current access token, for the admin page."
  @spec spotify_access_token() :: String.t() | nil
  def spotify_access_token do
    case TokenServer.access_token() do
      {:ok, token} -> token
      {:error, _} -> nil
    end
  end

  @spec disconnect_spotify() :: :ok'

replace_once lib/rocola_web/live/admin_live.ex \
'     |> assign(spotify_connected: Jukebox.spotify_connected?())' \
'     |> assign(spotify_connected: Jukebox.spotify_connected?())
     |> assign(access_token: Jukebox.spotify_access_token())'

replace_once lib/rocola_web/live/admin_live.ex \
'            <span class="badge badge-success">Spotify connected</span>' \
'            <span class="badge badge-success">Spotify connected</span>
            <code :if={@access_token} class="text-xs opacity-60">{@access_token}</code>'

commit "feat(admin): show connection details in the Spotify panel"
write_review_inputs
