#!/usr/bin/env bash
# Bug: the Spotify client secret is committed in config/dev.exs (rule 5).
# The values are made up; they only need to look real.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_setup

cat >> config/dev.exs <<'EOF'

# Spotify app credentials for local testing against the real API (ROC-003).
config :rocola, Rocola.Spotify.Web,
  client_id: "3f1c2a9b8e7d4c6fa1b2c3d4e5f60718",
  client_secret: "9b7e4d2c1a0f8e6d5c4b3a291807f6e5",
  redirect_uri: "http://127.0.0.1:4000/auth/spotify/callback"
EOF

commit "chore(config): Spotify app settings for dev"
write_review_inputs
