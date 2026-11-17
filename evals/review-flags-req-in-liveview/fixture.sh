#!/usr/bin/env bash
# Bug: AdminLive calls Req directly instead of going through Jukebox/Spotify (rule 2).
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_setup

replace_once lib/rocola_web/live/admin_live.ex \
'     |> assign(spotify_connected: Jukebox.spotify_connected?())' \
'     |> assign(spotify_connected: Jukebox.spotify_connected?())
     |> assign(spotify_up: spotify_up?())'

replace_once lib/rocola_web/live/admin_live.ex \
'  defp load_devices(socket) do' \
'  defp spotify_up? do
    case Req.get("https://api.spotify.com/v1/", retry: false, receive_timeout: 2_000) do
      {:ok, %Req.Response{status: status}} -> status < 500
      {:error, _} -> false
    end
  end

  defp load_devices(socket) do'

replace_once lib/rocola_web/live/admin_live.ex \
'        <h2 class="text-lg font-semibold">Spotify</h2>' \
'        <h2 class="text-lg font-semibold">Spotify</h2>
        <span :if={!@spotify_up} class="badge badge-warning">Spotify is down</span>'

commit "feat(admin): warn when Spotify is down"
write_review_inputs
