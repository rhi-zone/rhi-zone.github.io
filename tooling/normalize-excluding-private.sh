#!/usr/bin/env bash
# Run `normalize sessions ...` with private projects excluded from
# --all-projects entirely, before anything is ever read into an agent's
# context -- not filtered/redacted after the fact.
#
# How: normalize's --all-projects walks a flat "sessions root" dir (one
# subdir per project, name-mangled from the project's absolute path -- see
# `list_all_project_dirs` in normalize's source) via $CLAUDE_SESSIONS_DIR
# (or its own default). We build a scratch dir of symlinks to every project
# subdir EXCEPT the private ones, then point CLAUDE_SESSIONS_DIR at that
# instead. normalize itself never sees the excluded dirs exist.
#
# Source of truth for exclusions: .git/info/private-names (machine-local,
# gitignored-by-design, one directory basename per line, `#` comments ok).
#
# Usage: same as normalize itself, e.g.:
#   tooling/normalize-excluding-private.sh sessions messages --all-projects --role user --since 2026-08-20 --until 2026-08-21 --limit 0 --show-usage
#
# Env:
#   CLAUDE_SESSIONS_DIR   real sessions root to filter (default: ~/.claude/projects)
#   NORMALIZE_BIN         path to the normalize binary (default: ~/git/rhizone/normalize/target/debug/normalize)
#   PRIVATE_NAMES_FILE    override the private-names list path (default: resolved via `git rev-parse --git-dir` from cwd)

set -euo pipefail

real_sessions_dir="${CLAUDE_SESSIONS_DIR:-$HOME/.claude/projects}"
normalize_bin="${NORMALIZE_BIN:-$HOME/git/rhizone/normalize/target/debug/normalize}"

if [ -n "${PRIVATE_NAMES_FILE:-}" ]; then
  private_names_file="$PRIVATE_NAMES_FILE"
else
  git_dir="$(git rev-parse --git-dir 2>/dev/null || true)"
  if [ -z "$git_dir" ]; then
    echo "normalize-excluding-private: not in a git repo and PRIVATE_NAMES_FILE not set" >&2
    exit 2
  fi
  private_names_file="$git_dir/info/private-names"
fi

if [ ! -d "$real_sessions_dir" ]; then
  echo "normalize-excluding-private: sessions dir not found: $real_sessions_dir" >&2
  exit 2
fi

if [ ! -x "$normalize_bin" ]; then
  echo "normalize-excluding-private: normalize binary not found/executable: $normalize_bin" >&2
  exit 2
fi

# Mangle an absolute path the same way Claude Code names its project dirs
# under ~/.claude/projects: every '/' and '.' becomes '-'.
mangle() {
  local p="$1"
  p="${p//\//-}"
  p="${p//./-}"
  printf '%s\n' "$p"
}

# Collect mangled dir-name(s) to exclude, one per matching real directory
# found anywhere under ~/git for each private basename. A private name with
# no matching directory today contributes nothing (nothing to exclude yet)
# but stays harmless in the list for when/if it reappears.
declare -A exclude_names=()
if [ -f "$private_names_file" ]; then
  while IFS= read -r name; do
    case "$name" in
      ''|\#*) continue ;;
    esac
    while IFS= read -r -d '' match; do
      abs="$(cd "$match" && pwd)"
      exclude_names["$(mangle "$abs")"]=1
    done < <(find "$HOME/git" -maxdepth 4 -type d -name "$name" -print0 2>/dev/null)
  done < "$private_names_file"
else
  echo "normalize-excluding-private: no private-names file at $private_names_file -- proceeding with nothing excluded" >&2
fi

scratch_dir="$(mktemp -d "${TMPDIR:-/tmp}/normalize-sessions-filtered.XXXXXX")"
trap 'rm -rf "$scratch_dir"' EXIT

excluded_count=0
included_count=0
for entry in "$real_sessions_dir"/*/; do
  [ -d "$entry" ] || continue
  base="$(basename "$entry")"
  if [ -n "${exclude_names[$base]:-}" ]; then
    excluded_count=$((excluded_count + 1))
    continue
  fi
  ln -s "${entry%/}" "$scratch_dir/$base"
  included_count=$((included_count + 1))
done

echo "normalize-excluding-private: $included_count project dir(s) included, $excluded_count excluded (source: $private_names_file)" >&2

CLAUDE_SESSIONS_DIR="$scratch_dir" exec "$normalize_bin" "$@"
