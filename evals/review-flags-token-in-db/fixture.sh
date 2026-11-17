#!/usr/bin/env bash
# Bug: tokens are persisted to SQLite (CLAUDE.md rule 5: only TokenServer state).
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_setup

cat > priv/repo/migrations/20261117120000_create_spotify_tokens.exs <<'EOF'
defmodule Rocola.Repo.Migrations.CreateSpotifyTokens do
  use Ecto.Migration

  def change do
    create table(:spotify_tokens) do
      add :access_token, :string, null: false
      add :refresh_token, :string
      add :expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
EOF

cat > lib/rocola/spotify/token.ex <<'EOF'
defmodule Rocola.Spotify.Token do
  @moduledoc "The host's Spotify tokens, so a restart keeps the host connected."
  use Ecto.Schema

  schema "spotify_tokens" do
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end
end
EOF

replace_once lib/rocola/spotify/token_server.ex \
'    timer = Process.send_after(self(), :refresh, max(ms - s.margin_ms, 0))
' \
'    timer = Process.send_after(self(), :refresh, max(ms - s.margin_ms, 0))

    Rocola.Repo.insert!(
      %Rocola.Spotify.Token{
        id: 1,
        access_token: a,
        refresh_token: r,
        expires_at: DateTime.add(DateTime.utc_now(:second), exp)
      },
      on_conflict: :replace_all,
      conflict_target: :id
    )

'

commit "feat(token_server): keep the host connected across restarts"
write_review_inputs
