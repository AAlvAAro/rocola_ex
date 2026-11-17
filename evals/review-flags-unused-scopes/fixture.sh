#!/usr/bin/env bash
# Bug: the authorize URL asks for scopes Rocola never uses (library, playlists,
# follows, email) on top of the playback ones it needs.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_setup

replace_once lib/rocola/spotify/web.ex \
'  @impl true
  def authorize_url(_), do: {:error, :not_implemented}' \
'  @scopes ~w(
    user-read-playback-state
    user-modify-playback-state
    user-read-currently-playing
    user-read-private
    user-read-email
    user-library-read
    user-library-modify
    playlist-read-private
    playlist-modify-public
    playlist-modify-private
    user-follow-modify
  )

  @impl true
  def authorize_url(state) do
    config = Application.get_env(:rocola, __MODULE__, [])

    query =
      URI.encode_query(%{
        response_type: "code",
        client_id: config[:client_id],
        redirect_uri: config[:redirect_uri],
        scope: Enum.join(@scopes, " "),
        state: state
      })

    {:ok, "https://accounts.spotify.com/authorize?" <> query}
  end'

commit "feat(spotify): build the real authorize URL"
write_review_inputs
