#!/usr/bin/env bash
# No bug: a comment-only clarification that is accurate (safe_reason/1 really
# prints only atoms). The reviewer should approve.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$case_dir/../_lib/roc002.sh"
roc002_setup

replace_once lib/rocola/spotify/token_server.ex \
'  # Never inspect non-atom reasons: they may carry request headers.' \
'  # Only atom reasons are printed. Any other term (an exception, a response
  # struct) may carry request headers, so it is logged as "error".'

commit "docs(token_server): explain why safe_reason/1 hides non-atom reasons"
write_review_inputs
