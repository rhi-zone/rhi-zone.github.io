#!/usr/bin/env bash
# sync-skills.sh — distribute github-io's committed .claude/skills/ skills to
# the ecosystem recipient repos. Replaces propagate-skill.sh.
#
# Layout: directory-per-skill — every skill is .claude/skills/<name>/SKILL.md
# (+ optional sibling files under the same directory).
#
# CONTRACT (see docs/artifacts/skill-loading-audit/synthesis.md §Resolution 5):
#   - Source = github-io's committed .claude/skills/ (git-tracked files ONLY).
#     NEVER reads or writes ~/.claude. An untracked file in .claude/skills/ is
#     NOT distributed (closes the "on disk, not in git" drift class at the source).
#   - Recipients = explicit committed lists (tooling/skill-recipients.txt and, for
#     dev-tier skills, tooling/skill-recipients-rhizone.txt). No find-by-presence.
#   - Two-tier scoping = tooling/skill-tiers.txt maps each skill to tier all|dev.
#   - Idempotent / convergent: a second run on a converged ecosystem writes nothing.
#   - Dirty-receiver skip FIRST: a repo with a dirty tree is never mutated/committed;
#     it is reported and a TODO.md line is suggested. No rm on a dirty tree.
#   - Non-destructive default: orphan skills (present in receiver, absent from the
#     skill set for that receiver's tier) are REPORTED; removed only under --prune.
#   - Pure POSIX cp/diff. No rsync, no TOML parser. Portable across per-flake toolsets.
#
# Usage:
#   sync-skills.sh [--check] [--prune] [--no-push]
#     --check    Dry run. Report drift (stale / missing / orphan) per repo, write
#                nothing, and exit non-zero if any drift exists. CI/loop guard.
#     --prune    Also remove (git rm) orphan skills from receivers (clean repos only).
#     --no-push  Commit but do not push.

set -euo pipefail

HUB="$(cd "$(dirname "$0")/.." && pwd)"        # github-io repo root
SRC="$HUB/.claude/skills"                       # canonical source (committed)
GIT_ROOT="$(cd "$HUB/../.." && pwd)"            # ~/git  (recipient paths are relative to this; HUB is ~/git/rhizone/github-io)
RECIPIENTS_ALL="$HUB/tooling/skill-recipients.txt"
RECIPIENTS_DEV="$HUB/tooling/skill-recipients-rhizone.txt"
TIERS="$HUB/tooling/skill-tiers.txt"
NORMALIZE="$GIT_ROOT/rhizone/normalize/target/debug/normalize"

CHECK=0; PRUNE=0; PUSH=1
for arg in "$@"; do
  case "$arg" in
    --check)   CHECK=1 ;;
    --prune)   PRUNE=1 ;;
    --no-push) PUSH=0 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

for f in "$RECIPIENTS_ALL" "$RECIPIENTS_DEV" "$TIERS"; do
  [ -f "$f" ] || { echo "error: missing $f" >&2; exit 2; }
done
[ -d "$SRC" ] || { echo "error: source $SRC not found" >&2; exit 2; }

# read a recipient list, stripping comments/blanks
read_list() { grep -v '^[[:space:]]*#' "$1" | grep -v '^[[:space:]]*$'; }

# Is a skill name git-tracked in the canonical source?
#   dir:   .claude/skills/<name>/ (a directory with at least one tracked file,
#          conventionally <name>/SKILL.md plus optional siblings).
skill_is_tracked() {
  name="$1"
  [ -d "$SRC/$name" ] && [ -n "$(git -C "$HUB" ls-files ".claude/skills/$name")" ]
}

# List the relative paths (under .claude/skills/) a skill contributes.
skill_files() {
  name="$1"
  git -C "$HUB" ls-files ".claude/skills/$name"
}

# Recipient list path for a tier.
tier_list() {
  case "$1" in
    all) echo "$RECIPIENTS_ALL" ;;
    dev) echo "$RECIPIENTS_DEV" ;;
    *)   echo "" ;;
  esac
}

# Build: for each repo, the set of skill names it should carry.
# Emits lines "repo<TAB>skill" to a temp file.
PLAN="$(mktemp)"; trap 'rm -f "$PLAN"' EXIT
while read -r skill tier; do
  [ -z "${skill:-}" ] && continue
  case "$skill" in \#*) continue ;; esac
  if ! skill_is_tracked "$skill"; then
    echo "WARN: skill '$skill' in skill-tiers.txt is not git-tracked in $SRC — skipping" >&2
    continue
  fi
  list="$(tier_list "$tier")"
  [ -z "$list" ] && { echo "WARN: unknown tier '$tier' for skill '$skill' — skipping" >&2; continue; }
  read_list "$list" | while read -r repo; do
    printf '%s\t%s\n' "$repo" "$skill"
  done
done < <(grep -v '^[[:space:]]*#' "$TIERS" | grep -v '^[[:space:]]*$') >> "$PLAN"

REPOS="$(cut -f1 "$PLAN" | sort -u)"

drift_total=0
changed_repos=0

for repo in $REPOS; do
  repo_path="$GIT_ROOT/$repo"
  echo
  echo "=== $repo ==="

  if [ ! -d "$repo_path/.git" ]; then
    echo "  MISSING: not cloned at $repo_path — reported, skipped"
    drift_total=$((drift_total + 1))
    continue
  fi

  # Dirty check FIRST — never mutate a dirty tree.
  if [ -n "$(git -C "$repo_path" status --porcelain)" ]; then
    echo "  DIRTY: skipping (no mutation). Suggested TODO.md line:"
    echo "    - [ ] sync ecosystem skills: run github-io/tooling/sync-skills.sh once clean"
    drift_total=$((drift_total + 1))
    continue
  fi

  want_skills="$(awk -F'\t' -v r="$repo" '$1==r{print $2}' "$PLAN" | sort -u)"
  dest="$repo_path/.claude/skills"

  repo_changed=0

  # The full set of canonical relative paths this repo should carry.
  wanted_rel="$(for skill in $want_skills; do skill_files "$skill"; done | sort -u)"

  # Pass 1: stale / missing — detect drift, and (non-check) copy canonical files in.
  for rel in $wanted_rel; do
    src_file="$HUB/$rel"
    dst_file="$repo_path/$rel"
    if [ ! -f "$dst_file" ]; then
      echo "  MISSING: $rel"
      drift_total=$((drift_total + 1)); repo_changed=1
      [ "$CHECK" -eq 1 ] || { mkdir -p "$(dirname "$dst_file")"; cp "$src_file" "$dst_file"; }
    elif ! diff -q "$src_file" "$dst_file" >/dev/null 2>&1; then
      echo "  STALE:   $rel"
      drift_total=$((drift_total + 1)); repo_changed=1
      [ "$CHECK" -eq 1 ] || cp "$src_file" "$dst_file"
    fi
  done

  # Pass 2: orphans — receiver skills not wanted for this repo's tier.
  if [ -d "$dest" ]; then
    # Only consider git-tracked files in the receiver as orphan candidates
    # (untracked / repo-specific files are left alone).
    tracked="$(git -C "$repo_path" ls-files .claude/skills 2>/dev/null || true)"
    for rel in $tracked; do
      # repo-specific carve-outs: never treat these as orphans. Matched on the
      # FULL relative path (glob), not basename — under the directory-per-skill
      # layout every skill's main file is SKILL.md, so a basename rule would
      # degenerate and risk swallowing legitimate skill files.
      case "$rel" in
        */SUMMARY.md|*/character.md|*/build-stage.md|*/design-stage.md) continue ;;
      esac
      if ! printf '%s\n' "$wanted_rel" | grep -qxF "$rel"; then
        if [ "$PRUNE" -eq 1 ] && [ "$CHECK" -eq 0 ]; then
          echo "  PRUNE:   $rel"
          git -C "$repo_path" rm -q "$rel"; repo_changed=1
        else
          echo "  ORPHAN:  $rel (reported; use --prune to remove)"
          drift_total=$((drift_total + 1))
        fi
      fi
    done
  fi

  if [ "$CHECK" -eq 1 ]; then
    continue
  fi

  if [ "$repo_changed" -eq 0 ]; then
    echo "  converged — no changes"
    continue
  fi

  # Commit (clean repo guaranteed by the dirty check above).
  ( cd "$repo_path"
    direnv allow . >/dev/null 2>&1 || true
    [ -x "$NORMALIZE" ] && direnv exec . "$NORMALIZE" init >/dev/null 2>&1 || true
    git add .claude/skills .gitignore .normalize/ >/dev/null 2>&1 || true
    if git diff --cached --quiet; then
      echo "  nothing staged"
    else
      direnv exec . git commit -q -m "chore(claude-commands): sync ecosystem skills from github-io" \
        && echo "  committed"
      if [ "$PUSH" -eq 1 ] && [ -z "$(git status --porcelain)" ]; then
        git push 2>&1 | tail -1 | sed 's/^/    /'
      elif [ "$PUSH" -eq 1 ]; then
        echo "    not pushed: tree not clean after commit"
      fi
    fi
  )
  changed_repos=$((changed_repos + 1))
done

echo
if [ "$CHECK" -eq 1 ]; then
  echo "drift items: $drift_total"
  [ "$drift_total" -eq 0 ] && { echo "ecosystem converged."; exit 0; } || { echo "DRIFT DETECTED."; exit 1; }
else
  echo "repos changed: $changed_repos"
fi
