#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

# Self-contained top-level agent_id detector (inlined from lib/agent-id.sh).
is_subagent() {
    local skeleton
    skeleton=$(printf '%s' "$1" \
        | sed 's/\\"//g' \
        | sed 's/"agent_id"\([[:space:]]*\):/\x01\1:/g' \
        | sed 's/"[^"]*"/""/g' \
        | tr -cd '{}\001')
    local i ch depth=0 n=${#skeleton}
    for (( i = 0; i < n; i++ )); do
        ch="${skeleton:i:1}"
        case "$ch" in
            '{') (( depth++ )) ;;
            '}') (( depth-- )) ;;
            $'\001') (( depth == 1 )) && return 0 ;;
        esac
    done
    return 1
}

cat <<'EOF'
(Full version in CLAUDE.md.) Don't claim past your evidence — verify, or say you haven't. Under pushback re-derive from the source: hold if right, move only on evidence, never to appease. Unclear? Ask — don't invent.
EOF
