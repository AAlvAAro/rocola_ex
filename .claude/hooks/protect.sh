#!/usr/bin/env bash
# PreToolUse guardrail. Exit 2 = block, stderr goes back to Claude.
# Blocks: secrets (.env, config/*.secret.exs, token cache), editing EXISTING migrations,
# git push --force, mix ecto.reset. Needs jq.
in=$(cat)
tool=$(jq -r '.tool_name // ""' <<<"$in")
block() { echo "BLOCKED by protect.sh: $1" >&2; exit 2; }
cwd=$(jq -r '.cwd // ""' <<<"$in"); cwd=${cwd:-$PWD}
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
on_main() { [[ $branch == main || $branch == master ]]; }
WT="use EnterWorktree to create a feature-branch worktree (one per task, so work can run in parallel)"

SECRET='(^|[/ "'"'"'=<>])\.env($|[^.]|\.(local|dev|prod|test)\b)|\.secret\.exs|token_cache'
MIG='priv/repo/migrations/'

case "$tool" in
  Edit|Write|MultiEdit|Read|NotebookEdit)
    f=$(jq -r '.tool_input.file_path // ""' <<<"$in")
    [[ $f =~ $SECRET ]] && block "'$f' is a secret/token file"
    # skills, hooks, settings, CLAUDE.md etc. go in the project's .claude/, never ~/.claude*
    # (auto-memory under projects/*/memory/ is the one exception)
    if [[ $tool != Read && $f == "$HOME"/.claude*/* && $f != */projects/*/memory/* ]]; then
      block "'$f' is global Claude config; create it in the project (./.claude/ or ./CLAUDE.md) instead"
    fi
    # no edits to the repo while on main
    if [[ $tool != Read && -n $top && ( $f == "$top"/* || $f == "$cwd"/* ) ]] && on_main; then
      block "on '$branch', never edit here: $WT"
    fi
    # new migrations are fine; overwriting or editing an existing one is not
    [[ $f == *$MIG* && -e $f && $tool != Read ]] && block "migration '$f' already exists; create a new one"
    ;;
  Bash)
    c=$(jq -r '.tool_input.command // ""' <<<"$in")
    [[ ${c//.env.example/} =~ $SECRET ]] && block "command touches a secret/token file"
    [[ $c =~ git[[:space:]]+push([[:space:]].*)?[[:space:]](-f|--force|--force-with-lease)([[:space:]]|=|$) ]] && block "force push"
    # shell writes to global Claude config (same write-op list as the migration check)
    if [[ ( $c == *"~/.claude"* || $c == *"$HOME/.claude"* || $c == *'$HOME/.claude'* ) && $c != *projects/*/memory/* \
          && $c =~ (sed[[:space:]]+-i|>|tee|mv[[:space:]]|cp[[:space:]]|mkdir|touch|ln[[:space:]]|rm[[:space:]]) ]]; then
      block "command writes to global Claude config; use the project's ./.claude/ instead"
    fi
    if [[ $c =~ git[[:space:]]+commit ]]; then
      on_main && block "commit on '$branch': $WT"
      # test gate: same checks as precommit, minus the mutating format/deps.unlock
      if [[ -f $cwd/mix.exs ]]; then
        out=$(cd "$cwd" && MIX_ENV=test mix compile --warnings-as-errors 2>&1 \
          && MIX_ENV=test mix format --check-formatted 2>&1 \
          && MIX_ENV=test mix test 2>&1) || { tail -40 <<<"$out" >&2; block "checks failed; fix them before committing"; }
      fi
    fi
    # push naming main/master (also HEAD:main), or a bare push while on main
    if [[ $c =~ git[[:space:]]+push([[:space:]]|$) ]]; then
      [[ $c =~ [[:space:]:/](main|master)([[:space:]]|$) ]] && block "push to main/master; push a feature branch instead"
      on_main && [[ ! $c =~ push[[:space:]].*[[:space:]][^-[:space:]]+[[:space:]]+[^-[:space:]]+ ]] && block "bare push on '$branch'; push a feature branch instead"
    fi
    [[ $c =~ mix[[:space:]]+ecto\.reset ]] && block "mix ecto.reset wipes the database"
    # writing to an existing migration through the shell (sed -i, >, mv, rm, tee, ...)
    if [[ $c == *$MIG* && $c =~ (sed[[:space:]]+-i|perl[[:space:]]+-i|>|tee|mv[[:space:]]|rm[[:space:]]|truncate|cp[[:space:]]) ]]; then
      block "command modifies files in $MIG"
    fi
    ;;
esac
exit 0
