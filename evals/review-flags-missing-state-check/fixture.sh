#!/usr/bin/env bash
# Bug: the OAuth callback no longer checks `state` (login CSRF).
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_setup

replace_once lib/rocola_web/controllers/spotify_auth_controller.ex \
'  defp handle_callback(conn, expected, %{"state" => state, "code" => code})
       when is_binary(expected) and is_binary(state) and is_binary(code) do
    if Plug.Crypto.secure_compare(expected, state) do
      case Jukebox.connect_spotify(code) do
        :ok -> put_flash(conn, :info, "Spotify connected")
        {:error, _} -> put_flash(conn, :error, "Couldn'"'"'t connect Spotify")
      end
    else
      expired(conn)
    end
  end' \
'  defp handle_callback(conn, _expected, %{"code" => code}) when is_binary(code) do
    case Jukebox.connect_spotify(code) do
      :ok -> put_flash(conn, :info, "Spotify connected")
      {:error, _} -> put_flash(conn, :error, "Couldn'"'"'t connect Spotify")
    end
  end'

commit "refactor(auth): flatten the Spotify callback"
write_review_inputs
