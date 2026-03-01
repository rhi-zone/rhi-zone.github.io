#!/usr/bin/env bash
set -euo pipefail

# Ecosystem freshness check — git health and status indicator tracking.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$SCRIPT_DIR/../docs"
FRESHNESS_FILE="$DOCS_DIR/.freshness.json"

# Resolve jq — use PATH first, fall back to nix
if command -v jq &>/dev/null; then
  JQ="$(command -v jq)"
elif command -v nix-shell &>/dev/null; then
  JQ="$(nix-shell -p jq --run 'command -v jq' 2>/dev/null)"
else
  echo "jq is required but not found. Install it or use nix-shell -p jq."
  exit 1
fi
jq() { "$JQ" "$@"; }

# All ecosystem repos
declare -A REPOS=(
  # Code Intelligence
  [normalize]="$HOME/git/rhizone/normalize"
  [gels]="$HOME/git/rhizone/gels"
  [motif]="$HOME/git/rhizone/motif"
  # Generation
  [unshape]="$HOME/git/rhizone/unshape"
  [wick]="$HOME/git/rhizone/wick"
  # Games & Worlds
  [playmate]="$HOME/git/rhizone/playmate"
  [interconnect]="$HOME/git/rhizone/interconnect"
  # Data Transformation
  [tiltshift]="$HOME/git/rhizone/tiltshift"
  [paraphase]="$HOME/git/rhizone/paraphase"
  [rescribe]="$HOME/git/rhizone/rescribe"
  [concord]="$HOME/git/rhizone/concord"
  [reincarnate]="$HOME/git/rhizone/reincarnate"
  # Runtime & Interface
  [moonlet]="$HOME/git/rhizone/moonlet"
  [crescent]="$HOME/git/rhizone/crescent"
  [dusklight]="$HOME/git/rhizone/dusklight"
  [deskspace]="$HOME/git/rhizone/deskspace"
  # Infrastructure
  [myenv]="$HOME/git/rhizone/myenv"
  [portals]="$HOME/git/rhizone/portals"
  [zone]="$HOME/git/rhizone/zone"
  [server-less]="$HOME/git/rhizone/server-less"
  # External
  [hologram]="$HOME/git/exoplace/hologram"
  [aspect]="$HOME/git/exoplace/aspect"
  [existence]="$HOME/git/paragarden/existence"
  [keybinds]="$HOME/git/keybinds"
  [ooxml]="$HOME/git/ooxml"
  [claude-code-hub]="$HOME/git/claude-code-hub"
)

# Sorted repo names for consistent output
sorted_repos() {
  printf '%s\n' "${!REPOS[@]}" | sort
}

# Git health check — show unpushed, uncommitted, unpulled state
cmd_health() {
  local show_all=false
  [[ "${1:-}" == "--all" ]] && show_all=true

  printf "%-20s %-12s %5s  %5s  %6s\n" "REPO" "BRANCH" "DIRTY" "AHEAD" "BEHIND"
  printf "%-20s %-12s %5s  %5s  %6s\n" "----" "------" "-----" "-----" "------"

  for name in $(sorted_repos); do
    local dir="${REPOS[$name]}"
    if [[ ! -d "$dir/.git" ]]; then
      printf "%-20s (not found)\n" "$name"
      continue
    fi

    local branch dirty ahead behind
    branch="$(git -C "$dir" branch --show-current 2>/dev/null || echo "detached")"
    dirty="$(git -C "$dir" status --porcelain 2>/dev/null | wc -l)"

    # Ahead/behind only work if there's an upstream
    if git -C "$dir" rev-parse '@{u}' &>/dev/null; then
      ahead="$(git -C "$dir" log '@{u}..HEAD' --oneline 2>/dev/null | wc -l)"
      behind="$(git -C "$dir" log 'HEAD..@{u}' --oneline 2>/dev/null | wc -l)"
    else
      ahead="-"
      behind="-"
    fi

    if $show_all || [[ "$dirty" -gt 0 || "$ahead" != "0" || "$behind" != "0" || "$ahead" == "-" ]]; then
      printf "%-20s %-12s %5s  %5s  %6s\n" "$name" "$branch" "$dirty" "$ahead" "$behind"
    fi
  done
}

# Status staleness check — compare .freshness.json against current repo HEADs
cmd_status() {
  if [[ ! -f "$FRESHNESS_FILE" ]]; then
    echo "No $FRESHNESS_FILE found. Run --update <project> to initialize."
    exit 1
  fi

  local stale="" uptodate=""

  for name in $(sorted_repos); do
    local dir="${REPOS[$name]}"

    # Only check projects that have entries in .freshness.json
    local checked_at status label
    checked_at="$(jq -r --arg n "$name" '.[$n].checked_at // empty' "$FRESHNESS_FILE" 2>/dev/null)"
    [[ -z "$checked_at" ]] && continue

    status="$(jq -r --arg n "$name" '.[$n].status // "?"' "$FRESHNESS_FILE")"
    label="$(jq -r --arg n "$name" '.[$n].label // "?"' "$FRESHNESS_FILE")"

    if [[ ! -d "$dir/.git" ]]; then
      stale+="$(printf "  %-20s %s %-18s (repo not found)\n" "$name" "$status" "$label")"$'\n'
      continue
    fi

    # Count commits since last check
    local count
    if git -C "$dir" cat-file -t "$checked_at" &>/dev/null; then
      count="$(git -C "$dir" rev-list "$checked_at..HEAD" --count 2>/dev/null)"
    else
      count="?"
    fi

    if [[ "$count" == "0" ]]; then
      uptodate+="$(printf "  %-20s %s %-18s checked at %s (%s commits ago)\n" "$name" "$status" "$label" "$checked_at" "$count")"$'\n'
    else
      stale+="$(printf "  %-20s %s %-18s checked at %s (%s commits ago)\n" "$name" "$status" "$label" "$checked_at" "$count")"$'\n'
    fi
  done

  if [[ -n "$stale" ]]; then
    echo "STALE STATUS INDICATORS:"
    printf '%s' "$stale"
    echo
  fi
  if [[ -n "$uptodate" ]]; then
    echo "UP TO DATE:"
    printf '%s' "$uptodate"
  fi
  if [[ -z "$stale" && -z "$uptodate" ]]; then
    echo "No projects tracked in .freshness.json yet."
  fi
}

# Update a project's checked_at to current HEAD
cmd_update() {
  local name="$1"
  if [[ -z "${REPOS[$name]+x}" ]]; then
    echo "Unknown project: $name"
    echo "Known projects: $(sorted_repos | tr '\n' ' ')"
    exit 1
  fi

  local dir="${REPOS[$name]}"
  if [[ ! -d "$dir/.git" ]]; then
    echo "Repo not found: $dir"
    exit 1
  fi

  local head_short head_full
  head_short="$(git -C "$dir" rev-parse --short HEAD)"
  head_full="$(git -C "$dir" rev-parse HEAD)"
  local today
  today="$(date +%Y-%m-%d)"

  # Read existing status/label from .freshness.json if present
  local status label
  if [[ -f "$FRESHNESS_FILE" ]]; then
    status="$(jq -r --arg n "$name" '.[$n].status // empty' "$FRESHNESS_FILE" 2>/dev/null)"
    label="$(jq -r --arg n "$name" '.[$n].label // empty' "$FRESHNESS_FILE" 2>/dev/null)"
  fi

  # Fall back to extracting from index.md hero features
  if [[ -z "$status" ]]; then
    local hero_line
    hero_line="$(grep -oP "\"$name \K[◐●○◔]" "$DOCS_DIR/index.md" 2>/dev/null || true)"
    status="${hero_line:-?}"
  fi
  if [[ -z "$label" ]]; then
    local page_label
    page_label="$(grep -oP 'Status: \K[^◐●○◔]+' "$DOCS_DIR/projects/$name.md" 2>/dev/null | sed 's/ *$//' || true)"
    label="${page_label:-unknown}"
  fi

  # Create or update .freshness.json
  local tmp
  if [[ -f "$FRESHNESS_FILE" ]]; then
    tmp="$(jq --arg n "$name" --arg s "$status" --arg l "$label" --arg c "$head_short" --arg cf "$head_full" --arg d "$today" \
      '.[$n] = (.[$n] // {}) * { status: $s, label: $l, checked_at: $c, checked_at_full: $cf, checked_date: $d }' "$FRESHNESS_FILE")"
  else
    tmp="$(jq -n --arg n "$name" --arg s "$status" --arg l "$label" --arg c "$head_short" --arg cf "$head_full" --arg d "$today" \
      '{ ($n): { status: $s, label: $l, checked_at: $c, checked_at_full: $cf, checked_date: $d } }')"
  fi
  echo "$tmp" > "$FRESHNESS_FILE"

  echo "Updated $name: $status $label @ $head_short ($today)"
}

usage() {
  cat <<EOF
Usage: freshness.sh [OPTIONS]

Ecosystem git health and status indicator tracking.

Modes:
  (default)           Git health check — dirty, ahead, behind for all repos
  --all               Include clean repos in health check
  --status            Check status indicator staleness against .freshness.json
  --update <project>  Mark a project's status indicator as reviewed at current HEAD

EOF
}

case "${1:-}" in
  --status)
    cmd_status
    ;;
  --update)
    if [[ -z "${2:-}" ]]; then
      echo "Usage: freshness.sh --update <project>"
      exit 1
    fi
    cmd_update "$2"
    ;;
  --help|-h)
    usage
    ;;
  --all)
    cmd_health --all
    ;;
  "")
    cmd_health
    ;;
  *)
    echo "Unknown option: $1"
    usage
    exit 1
    ;;
esac
