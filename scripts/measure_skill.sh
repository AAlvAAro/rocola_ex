#!/usr/bin/env bash
# Usage: scripts/measure_skill.sh baseline|with_skill
# Runs 3 fixed prompts headless, each in a fresh git worktree of HEAD, and appends one CSV row per run
# to docs/bench/results.csv. with_skill copies .claude/skills/spotify-web-api into each worktree;
# baseline guarantees it is absent. The unrelated session-steps skill is removed from both.
set -uo pipefail
label=${1:?baseline|with_skill}
root=$(git rev-parse --show-toplevel)
base=/private/tmp/rocola-bench
out=$root/docs/bench; mkdir -p "$out" "$base"
csv=$out/results.csv
[[ -f $csv ]] || echo "label,prompt,cost_usd,turns,duration_s,precommit,via_behaviour,fake_updated,no_net_tests,add_only_queue" > "$csv"
[[ $label == with_skill && ! -d $root/.claude/skills/spotify-web-api ]] && { echo "create the skill first"; exit 1; }

P1="Create a guest page (RequestLive at /) with a live 'now playing' banner that updates automatically when the song changes. Finish with mix precommit passing."
P2="Let guests vote to skip the current song; when 2 distinct guests have voted, move on to the next song. Finish with mix precommit passing."
P3="Create an admin page (AdminLive at /admin) listing playback devices with a refresh button. Restricted devices must show as unavailable and must never be selectable. Finish with mix precommit passing."

i=0
for prompt in "$P1" "$P2" "$P3"; do
  i=$((i+1)); wt=$base/$label-$i; branch=bench/$label-$i
  git -C "$root" worktree remove --force "$wt" 2>/dev/null; git -C "$root" branch -D "$branch" 2>/dev/null
  git -C "$root" worktree add -q -b "$branch" "$wt" HEAD || exit 1
  rm -rf "$wt/.claude/skills/session-steps" "$wt/.claude/skills/spotify-web-api"
  [[ $label == with_skill ]] && cp -R "$root/.claude/skills/spotify-web-api" "$wt/.claude/skills/"
  (cd "$wt" && mix deps.get >/dev/null 2>&1 && mix compile >/dev/null 2>&1)
  json=$(cd "$wt" && claude -p "$prompt" --output-format json --permission-mode acceptEdits \
     --allowedTools "Bash(mix *)" "Bash(ls *)" "Bash(grep *)" Read Edit Write Glob Grep \
     --max-budget-usd 5 2>/dev/null)
  echo "$json" > "$out/$label-$i.json"
  cost=$(jq -r '.total_cost_usd // 0' <<<"$json"); turns=$(jq -r '.num_turns // 0' <<<"$json")
  dur=$(jq -r '((.duration_ms // 0)/1000|floor)' <<<"$json")
  cd "$wt"
  (mix precommit >/dev/null 2>&1 && pc=pass) || pc=fail
  git add -N . ; git diff HEAD > "$out/$label-$i.patch"
  # checklist, scored from the diff (1 = yes). add_only/restricted semantics are in docs/homework-1.md
  via=1; grep -rqE "Spotify\.(Fake|Web)" lib/rocola_web lib/rocola/jukebox 2>/dev/null && via=0
  cb=$(grep -cE '^\+\s*@callback' "$out/$label-$i.patch"); fk=0; grep -q '^+++ b/lib/rocola/spotify/fake.ex' "$out/$label-$i.patch" && fk=1
  fake=1; [[ $cb -gt 0 && $fk -eq 0 ]] && fake=0
  net=1; grep -E '^\+' "$out/$label-$i.patch" | grep -qE 'Req\.|:httpc|HTTPoison|itunes' && net=0
  addonly=1; grep -E '^\+' "$out/$label-$i.patch" | grep -qE 'remove_from_queue|reorder|delete_from_queue' && addonly=0
  cd "$root"
  echo "$label,P$i,$cost,$turns,$dur,$pc,$via,$fake,$net,$addonly" >> "$csv"
  git worktree remove --force "$wt"; git branch -D "$branch" >/dev/null
  echo "done P$i: cost=$cost turns=$turns precommit=$pc"
done
