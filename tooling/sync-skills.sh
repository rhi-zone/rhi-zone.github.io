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
#   - CONVERGE-ALWAYS, no skips: every recipient is processed every run, dirty
#     tree or not. Only .claude/skills (+ .gitignore/.normalize) is ever staged —
#     a dirty tree elsewhere is left untouched, never a reason to skip a repo.
#   - CONFLICT EDGE: if a tracked file this script is about to overwrite or
#     remove carries UNCOMMITTED owner edits, the owner's on-disk bytes are
#     preserved first as an untracked sibling `<file>.local-edit` (an existing
#     `.local-edit` is overwritten only if byte-different; otherwise left alone),
#     then canon is installed/removed and committed. Canon always wins in the
#     tree; owner bytes are never destroyed. Reported LOUDLY per occurrence.
#   - No TODO.md writes, anywhere, ever — all reporting is run-output only.
#   - PUSH SAFETY: before pushing a receiver, its unpushed commits (`@{u}..HEAD`)
#     must ALL match this script's own housekeeping commit-message pattern; if
#     any unpushed commit is unrelated owner work, the commit still lands but
#     the push is withheld and reported (a withheld push is not a skip — the
#     tree converged).
#   - Non-destructive default: orphan skills (present in receiver, absent from the
#     skill set for that receiver's tier) are REPORTED; removed only under --prune.
#   - Pure POSIX cp/diff. No rsync, no TOML parser. Portable across per-flake toolsets.
#
# Usage:
#   sync-skills.sh [--check] [--prune] [--no-push]
#     --check    Dry run. Report drift (stale / missing / orphan / conflict) per
#                repo, write nothing, and exit non-zero if any drift exists.
#     --prune    Also remove (git rm) orphan skills from receivers.
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

# CONFLICT EDGE: if $repo_path/$rel is tracked and carries uncommitted owner
# edits, snapshot its current on-disk bytes to "$rel.local-edit" (an existing
# snapshot is overwritten only if byte-different; else left alone) BEFORE
# canon overwrites or removes it. No-op if the file doesn't exist or isn't
# dirty. Always reports; only writes the snapshot in apply mode.
conflict_snapshot() {
  repo_path="$1" rel="$2"
  dst="$repo_path/$rel"
  [ -f "$dst" ] || return 0
  [ -n "$(git -C "$repo_path" status --porcelain -- "$rel" 2>/dev/null)" ] || return 0
  if [ "$CHECK" -eq 1 ]; then
    echo "  CONFLICT: $rel has uncommitted owner edits (would preserve as $rel.local-edit)"
    return 0
  fi
  edit="$dst.local-edit"
  if [ -f "$edit" ] && cmp -s "$dst" "$edit"; then
    : # identical snapshot already recorded
  else
    cp -p "$dst" "$edit"
  fi
  echo "  CONFLICT: $rel has uncommitted owner edits — preserved as $rel.local-edit (canon installed)"
}

# PUSH SAFETY: every unpushed commit ahead of the upstream must match this
# script's own housekeeping pattern, or the push is withheld (commit still
# stands — a withheld push is not a skip). No upstream at all (never-pushed
# branch) is not gated here — handled by the caller as a first push.
SYNC_COMMIT_RE='^chore\(skills\): sync ecosystem skills from github-io|^chore\(harness\): remove propagation skip-notices — mechanism retired'
push_is_safe() {
  repo_path="$1"
  git -C "$repo_path" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 || return 0
  bad="$(git -C "$repo_path" log --format=%s '@{u}..HEAD' 2>/dev/null | grep -Ev "$SYNC_COMMIT_RE" || true)"
  [ -z "$bad" ]
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

# Managed skill names = every git-tracked skill dir in the canonical source. The
# directory-per-skill migration replaces each receiver's OLD .claude/commands/<name>
# (file or dir) with .claude/skills/<name>/. Removal is keyed STRICTLY to these
# names so a receiver's own repo-local .claude/commands/<other> is never touched.
MANAGED_SKILLS=""
for d in "$SRC"/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  skill_is_tracked "$name" && MANAGED_SKILLS="$MANAGED_SKILLS $name"
done

drift_total=0
changed_repos=0

for repo in $REPOS; do
  if [ "${repo#/}" != "$repo" ]; then
    repo_path="$repo"
  else
    repo_path="$GIT_ROOT/$repo"
  fi
  echo
  echo "=== $repo ==="

  if [ ! -d "$repo_path/.git" ]; then
    echo "  MISSING: not cloned at $repo_path — reported, skipped"
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
      conflict_snapshot "$repo_path" "$rel"
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
          conflict_snapshot "$repo_path" "$rel"
          git -C "$repo_path" rm -q "$rel"; repo_changed=1
        else
          echo "  ORPHAN:  $rel (reported; use --prune to remove)"
          drift_total=$((drift_total + 1))
        fi
      fi
    done
  fi

  # Pass 3: directory-per-skill migration — remove this receiver's OLD ecosystem
  # command files (.claude/commands/<name>.md or .claude/commands/<name>/) for every
  # managed skill name, in the SAME commit that writes .claude/skills/<name>/. Keyed
  # strictly to MANAGED_SKILLS so repo-local commands are never removed. Convergent:
  # once gone, the git ls-files guard makes this a no-op (no extra commit).
  for name in $MANAGED_SKILLS; do
    for cand in ".claude/commands/$name.md" ".claude/commands/$name"; do
      [ -n "$(git -C "$repo_path" ls-files "$cand" 2>/dev/null)" ] || continue
      if [ "$CHECK" -eq 1 ]; then
        echo "  CMD-DEL: $cand (old command — to be removed)"
        drift_total=$((drift_total + 1)); repo_changed=1
      else
        echo "  CMD-DEL: $cand"
        conflict_snapshot "$repo_path" "$cand"
        git -C "$repo_path" rm -r -q --ignore-unmatch "$cand" >/dev/null 2>&1 || true
        repo_changed=1
      fi
    done
  done

  if [ "$CHECK" -eq 1 ]; then
    continue
  fi

  if [ "$repo_changed" -eq 0 ]; then
    echo "  converged — no changes"
    continue
  fi

  # Commit. Staged paths are ecosystem-only (.claude/skills, .gitignore,
  # .normalize) — a dirty tree elsewhere is left completely untouched, whether
  # or not this repo was clean going in (converge-always: no dirty-tree skip).
  ( cd "$repo_path"
    direnv allow . >/dev/null 2>&1 || true
    [ -x "$NORMALIZE" ] && direnv exec . "$NORMALIZE" init >/dev/null 2>&1 || true
    # Stage skills writes in the SAME commit as the Pass-3 command removals (atomic
    # migration). Stage each path independently and ONLY if it exists; never pass the
    # bare `.claude/commands` pathspec — the Pass-3 `git rm` already staged the command
    # removals, and once that dir is fully emptied the pathspec matches nothing, which
    # makes a combined `git add` abort atomically (exit 128) and drop the new skills/.
    for p in .claude/skills .gitignore .normalize; do
      [ -e "$p" ] && git add "$p" >/dev/null 2>&1 || true
    done
    if git diff --cached --quiet; then
      echo "  nothing staged"
    else
      direnv exec . git commit -q -m "chore(skills): sync ecosystem skills from github-io (directory-per-skill)" \
        && echo "  committed"
      if [ "$PUSH" -eq 1 ] && [ -z "$(git status --porcelain -- .claude/skills .gitignore .normalize)" ]; then
        # A remote-less recipient (e.g. a repo not yet published) is a legitimate
        # state: commit lands locally, there is nothing to push. Name it, and never
        # let a missing remote — or a rejected push — abort the ecosystem fan-out.
        if [ -z "$(git remote)" ]; then
          echo "    not pushed: no remote configured (committed locally)"
        elif ! push_is_safe "$repo_path"; then
          echo "    PUSH WITHHELD: unpushed commit(s) ahead of upstream aren't recognized housekeeping — commit landed, not pushed:"
          git log --format='      - %s' '@{u}..HEAD' 2>/dev/null
        else
          git push 2>&1 | tail -1 | sed 's/^/    /' || echo "    push failed (committed locally)"
        fi
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
