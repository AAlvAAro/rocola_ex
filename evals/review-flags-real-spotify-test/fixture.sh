#!/usr/bin/env bash
# Bug: a test makes a real HTTP call to Spotify (CLAUDE.md rule 4).
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_setup

cat > test/rocola/spotify/web_test.exs <<'EOF'
defmodule Rocola.Spotify.WebTest do
  use ExUnit.Case, async: true

  setup_all do
    {:ok, _} = Application.ensure_all_started([:inets, :ssl])
    :ok
  end

  test "the Spotify accounts service answers the authorize endpoint" do
    url = ~c"https://accounts.spotify.com/authorize?response_type=code&client_id=rocola"

    {:ok, {{_, status, _}, _headers, _body}} =
      :httpc.request(:get, {url, []}, [timeout: 5_000], [])

    assert status in 200..499
  end
end
EOF

commit "test(spotify): smoke test for the accounts service"
write_review_inputs
