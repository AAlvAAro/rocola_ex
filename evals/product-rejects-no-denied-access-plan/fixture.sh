#!/usr/bin/env bash
# Flaw: nothing handles the host pressing "Cancel" on Spotify's consent screen
# (callback with error=access_denied). The branch and its test are removed and
# the remaining tests renumbered so the gap isn't obvious.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_design_setup

f=docs/tdd/ROC-002.md

replace_once "$f" \
'  - `error` param present: flashes the error "Spotify login cancelled".
' \
''

replace_once "$f" \
'19. A callback with `error=access_denied` flashes "Spotify login cancelled" and leaves the server disconnected.
' \
''

for n in 20 21 22 23 24; do
  replace_once "$f" "
$n. " "
$((n - 1)). "
done

replace_once "$f" \
'Tests 12, 13, 20 and 22 guard this.' \
'Tests 12, 13, 19 and 21 guard this.'

commit "docs: ROC-002 TDD"
