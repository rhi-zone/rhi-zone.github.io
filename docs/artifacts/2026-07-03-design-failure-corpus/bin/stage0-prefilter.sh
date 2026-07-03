#!/usr/bin/env bash
# stage0-prefilter.sh — ripgrep-based neutral-marker pre-filter for the
# design-failure corpus. Scans all .md files under docs/introspection/
# (recursive) plus any repo file (tracked or untracked-but-not-ignored)
# whose name matches H-DECOMPOSITION-FAILURE, and emits one JSON line per
# doc to ledger/index.jsonl:
#   {"path": ..., "hash": sha256-of-content, "markers": [{"marker","line"}], "marker_count": N}
set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
ARTIFACT_DIR="$REPO_ROOT/docs/artifacts/2026-07-03-design-failure-corpus"
LEDGER_DIR="$ARTIFACT_DIR/ledger"
OUT="$LEDGER_DIR/index.jsonl"

MARKERS=(decided decision design rename revert postmortem fail success shipped
  complete abandon oscillat overrid correction converge stall broken cost tokens)

mkdir -p "$LEDGER_DIR"

# Resolve a ripgrep implementation. Prefer a real `rg` binary; fall back to the
# ripgrep bundled with Claude Code (dispatched via argv0=rg); finally fall back
# to GNU grep, whose -i -n -o -F output ("line:match" per occurrence) is
# identical for our fixed-string, per-occurrence use.
if command -v rg > /dev/null 2>&1; then
  search() { rg --no-config -i -n -o --fixed-strings "$1" "$2"; }
elif [ -n "${CLAUDE_CODE_EXECPATH:-}" ] && [ -x "${CLAUDE_CODE_EXECPATH:-}" ]; then
  search() { ( exec -a rg "$CLAUDE_CODE_EXECPATH" --no-config -i -n -o --fixed-strings "$1" "$2" ); }
else
  search() { grep -i -n -o -F "$1" "$2"; }
fi

cd "$REPO_ROOT"

# Collect scan set (repo-relative paths), deduplicated.
{
  find docs/introspection -type f -name '*.md'
  git ls-files --cached --others --exclude-standard | grep -i 'H-DECOMPOSITION-FAILURE' || true
} | sort -u > "$LEDGER_DIR/.scanset.tmp"

: > "$OUT"

while IFS= read -r path; do
  hash="$(sha256sum "$path" | cut -d' ' -f1)"
  markers_json="$(
    for m in "${MARKERS[@]}"; do
      { search "$m" "$path" 2>/dev/null || true; } \
        | cut -d: -f1 \
        | awk -v m="$m" '{print m "\t" $0}'
    done | jq -R -s '
      split("\n")
      | map(select(length > 0) | split("\t") | {marker: .[0], line: (.[1] | tonumber)})
      | sort_by(.line)
    '
  )"
  jq -c -n --arg path "$path" --arg hash "$hash" --argjson markers "$markers_json" \
    '{path: $path, hash: $hash, markers: $markers, marker_count: ($markers | length)}' >> "$OUT"
done < "$LEDGER_DIR/.scanset.tmp"

rm -f "$LEDGER_DIR/.scanset.tmp"

echo "wrote $(wc -l < "$OUT") records to $OUT" >&2
