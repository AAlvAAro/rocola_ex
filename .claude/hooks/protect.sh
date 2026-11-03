#!/usr/bin/env bash
# PreToolUse guardrail. Exit 2 = block, stderr goes back to Claude.
# Blocks: secrets (.env, config/*.secret.exs, token cache), editing EXISTING migrations,
# git push --force, mix ecto.reset. Needs jq.
in=$(cat)
tool=$(jq -r '.tool_name // ""' <<<"$in")
block() { echo "BLOCKED by protect.sh: $1" >&2; exit 2; }

SECRET='(^|[/ "'"'"'=<>])\.env($|[^.]|\.(local|dev|prod|test)\b)|\.secret\.exs|token_cache'
MIG='priv/repo/migrations/'

case "$tool" in
  Edit|Write|MultiEdit|Read|NotebookEdit)
    f=$(jq -r '.tool_input.file_path // ""' <<<"$in")
    [[ $f =~ $SECRET ]] && block "'$f' is a secret/token file"
    # new migrations are fine; overwriting or editing an existing one is not
    [[ $f == *$MIG* && -e $f && $tool != Read ]] && block "migration '$f' already exists; create a new one"
    ;;
  Bash)
    c=$(jq -r '.tool_input.command // ""' <<<"$in")
    [[ ${c//.env.example/} =~ $SECRET ]] && block "command touches a secret/token file"
    [[ $c =~ git[[:space:]]+push([[:space:]].*)?[[:space:]](-f|--force|--force-with-lease)([[:space:]]|=|$) ]] && block "force push"
    [[ $c =~ mix[[:space:]]+ecto\.reset ]] && block "mix ecto.reset wipes the database"
    # writing to an existing migration through the shell (sed -i, >, mv, rm, tee, ...)
    if [[ $c == *$MIG* && $c =~ (sed[[:space:]]+-i|perl[[:space:]]+-i|>|tee|mv[[:space:]]|rm[[:space:]]|truncate|cp[[:space:]]) ]]; then
      block "command modifies files in $MIG"
    fi
    ;;
esac
exit 0
