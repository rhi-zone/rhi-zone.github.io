#!/usr/bin/env bash
# sync-agent-persona.sh — distribute github-io's committed agent persona
# (.claude/agents/peer.md + the top-level "agent" settings.json key) to every
# ecosystem recipient repo. Mirrors sync-skills.sh's discipline; see that file
# for the fuller rationale behind each rule reproduced below.
#
# CONTRACT:
#   - Source = github-io's committed .claude/agents/<name>.md (git-tracked
#     file ONLY). An untracked file in .claude/agents/ is NOT distributed.
#   - Recipients = discovered, NOT a committed list: every CLAUDE.md under
#     ~/git carrying the ecosystem BEGIN marker (same discovery mechanism as
#     propagate-harness-all.sh), excluding worktrees and the canonical
#     github-io itself.
#   - Idempotent / convergent: a second run on a converged ecosystem writes
#     nothing.
#   - CONVERGE-ALWAYS, no skips: every recipient is processed every run,
#     dirty tree or not. Only .claude/agents/<name>.md and .claude/settings.json
#     are ever staged (never -A) — a dirty tree elsewhere is left untouched,
#     never a reason to skip a repo.
#   - CONFLICT EDGE: if a tracked file this script is about to overwrite
#     carries UNCOMMITTED owner edits, the owner's on-disk bytes are preserved
#     first as an untracked sibling `<file>.local-edit` (an existing
#     `.local-edit` is overwritten only if byte-different; otherwise left
#     alone), then canon is installed and committed. Canon always wins in the
#     tree; owner bytes are never destroyed. Reported LOUDLY per occurrence.
#   - No TODO.md writes, anywhere, ever — all reporting is run-output only.
#   - PUSH SAFETY: before pushing a receiver, its unpushed commits
#     (`@{u}..HEAD`) must ALL match this script's own housekeeping commit
#     message pattern; if any unpushed commit is unrelated owner work, the
#     commit still lands but the push is withheld and reported (a withheld
#     push is not a skip — the tree converged).
#   - Pure POSIX cp/diff + jq for the settings.json mutation. No rsync.
#
# Usage:
#   sync-agent-persona.sh [--check] [--no-push]
#     --check    Dry run. Report drift (stale / missing / conflict) per repo,
#                write nothing, and exit non-zero if any drift exists.
#     --no-push  Commit but do not push.

set -euo pipefail

HUB="$(cd "$(dirname "$0")/.." && pwd)"           # github-io repo root (canonical source)
AGENT_NAME="peer"
SRC_FILE="$HUB/.claude/agents/$AGENT_NAME.md"
REL_AGENT="/.claude/agents/$AGENT_NAME.md"
REL_AGENT="${REL_AGENT#/}"                        # .claude/agents/peer.md
# Scan root for recipient discovery. Defaults to ~/git; overridable via
# AGENT_SYNC_GIT_ROOT for testing against throwaway fixtures.
GIT_ROOT="$(cd "${AGENT_SYNC_GIT_ROOT:-$HUB/../..}" && pwd)"
CANONICAL_CLAUDE_MD_REAL="$(realpath "$HUB/CLAUDE.md")"

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq is required (not on PATH)" >&2
  exit 2
fi

CHECK=0; PUSH=1
for arg in "$@"; do
  case "$arg" in
    --check)   CHECK=1 ;;
    --no-push) PUSH=0 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

[ -f "$SRC_FILE" ] || { echo "error: source $SRC_FILE not found" >&2; exit 2; }
git -C "$HUB" ls-files --error-unmatch "$REL_AGENT" >/dev/null 2>&1 \
  || { echo "error: $REL_AGENT is not git-tracked in $HUB — refusing to propagate an untracked persona" >&2; exit 2; }

# ── Discover recipients: every CLAUDE.md bearing the BEGIN marker under
#    ~/git, excluding worktrees and the canonical github-io itself. ──────────
discover() {
  find "$GIT_ROOT" -maxdepth 3 -name CLAUDE.md \
       -not -path '*/.claude/worktrees/*' -not -path '*/node_modules/*' 2>/dev/null \
    | while IFS= read -r f; do
        grep -qF '<!-- BEGIN ECOSYSTEM RULES -->' "$f" 2>/dev/null || continue
        [ "$(realpath "$f")" = "$CANONICAL_CLAUDE_MD_REAL" ] && continue
        dirname "$f"
      done | sort -u
}

mapfile -t REPOS < <(discover)

echo "recipient-list source: grep '<!-- BEGIN ECOSYSTEM RULES -->' over ~/git CLAUDE.md (excl. worktrees, canonical github-io)"
echo "recipients discovered: ${#REPOS[@]}"

# CONFLICT EDGE: if $repo_path/$rel is tracked and carries uncommitted owner
# edits, snapshot its current on-disk bytes to "$rel.local-edit" (an existing
# snapshot is overwritten only if byte-different; else left alone) BEFORE
# canon overwrites it. No-op if the file doesn't exist or isn't dirty. Always
# reports; only writes the snapshot in apply mode.
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
# branch) is not gated here.
SYNC_COMMIT_RE='^chore\(agent\): sync '"$AGENT_NAME"' persona from github-io$'
push_is_safe() {
  repo_path="$1"
  git -C "$repo_path" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 || return 0
  bad="$(git -C "$repo_path" log --format=%s '@{u}..HEAD' 2>/dev/null | grep -Ev "$SYNC_COMMIT_RE" || true)"
  [ -z "$bad" ]
}

# Desired settings.json content given the receiver's current content: sets
# the top-level "agent" scalar key to $AGENT_NAME, leaving everything else
# (hooks, etc.) untouched. Mirrors propagate-harness.sh's jq-mutation style
# (read current -> jq transform -> compare normalized -> write if different),
# but for a top-level scalar key rather than a hook array.
desired_settings() {
  current="$1"
  printf '%s' "$current" | jq --arg agent "$AGENT_NAME" '.agent = $agent'
}

drift_total=0
changed_repos=0
conflict_repos=()
withheld_repos=()
failed_repos=()
converged_repos=0

for repo_path in "${REPOS[@]}"; do
  repo="${repo_path#"$GIT_ROOT"/}"
  echo
  echo "=== $repo ==="

  if [ ! -d "$repo_path/.git" ]; then
    echo "  MISSING: not a git repo at $repo_path — reported, skipped"
    drift_total=$((drift_total + 1))
    failed_repos+=("$repo: not a git repo")
    continue
  fi

  repo_changed=0
  dst_agent="$repo_path/$REL_AGENT"
  dst_settings="$repo_path/.claude/settings.json"

  # ── agent persona file ──────────────────────────────────────────────────
  if [ ! -f "$dst_agent" ]; then
    echo "  MISSING: $REL_AGENT"
    drift_total=$((drift_total + 1)); repo_changed=1
    [ "$CHECK" -eq 1 ] || { mkdir -p "$(dirname "$dst_agent")"; cp "$SRC_FILE" "$dst_agent"; }
  elif ! diff -q "$SRC_FILE" "$dst_agent" >/dev/null 2>&1; then
    echo "  STALE:   $REL_AGENT"
    drift_total=$((drift_total + 1)); repo_changed=1
    conflict_snapshot "$repo_path" "$REL_AGENT"
    [ "$CHECK" -eq 1 ] || cp "$SRC_FILE" "$dst_agent"
  fi

  # ── settings.json "agent" key ────────────────────────────────────────────
  if [ -f "$dst_settings" ]; then
    current_settings="$(cat "$dst_settings")"
  else
    current_settings='{}'
  fi
  new_settings="$(desired_settings "$current_settings")"
  norm_current="$(printf '%s' "$current_settings" | jq -S .)"
  norm_new="$(printf '%s' "$new_settings" | jq -S .)"
  if [ "$norm_current" != "$norm_new" ]; then
    echo "  SETTINGS: .agent -> \"$AGENT_NAME\""
    drift_total=$((drift_total + 1)); repo_changed=1
    if [ "$CHECK" -eq 0 ]; then
      conflict_snapshot "$repo_path" ".claude/settings.json"
      if ! printf '%s' "$new_settings" | jq . >/dev/null 2>&1; then
        echo "  FAILED: resulting settings.json for $repo would be invalid JSON — skipping this repo's settings write" >&2
        failed_repos+=("$repo: settings.json jq mutation produced invalid JSON")
      else
        mkdir -p "$(dirname "$dst_settings")"
        printf '%s\n' "$new_settings" > "$dst_settings"
      fi
    fi
  fi

  if [ "$CHECK" -eq 1 ]; then
    if [ "$repo_changed" -eq 0 ]; then
      echo "  already current"
    fi
    continue
  fi

  if [ "$repo_changed" -eq 0 ]; then
    echo "  converged — no changes"
    converged_repos=$((converged_repos + 1))
    continue
  fi

  # Commit. Staged paths are agent-persona-only (.claude/agents/<name>.md,
  # .claude/settings.json) — a dirty tree elsewhere is left completely
  # untouched, whether or not this repo was clean going in (converge-always:
  # no dirty-tree skip).
  rc=0
  (
    cd "$repo_path"
    for p in "$REL_AGENT" .claude/settings.json; do
      [ -e "$p" ] && git add "$p" >/dev/null 2>&1 || true
    done
    if git diff --cached --quiet; then
      echo "  nothing staged"
    else
      if direnv exec . git commit -q -m "chore(agent): sync $AGENT_NAME persona from github-io" 2>/dev/null \
        || git commit -q -m "chore(agent): sync $AGENT_NAME persona from github-io"; then
        echo "  committed"
      else
        echo "  FAILED: commit errored" >&2
        exit 5
      fi
      if [ "$PUSH" -eq 1 ]; then
        if [ -n "$(git status --porcelain -- "$REL_AGENT" .claude/settings.json)" ]; then
          echo "    not pushed: agent-persona paths not clean after commit"
        elif [ -z "$(git remote)" ]; then
          echo "    not pushed: no remote configured (committed locally)"
        elif ! push_is_safe "$repo_path"; then
          echo "    PUSH WITHHELD: unpushed commit(s) ahead of upstream aren't recognized housekeeping — commit landed, not pushed:"
          git log --format='      - %s' '@{u}..HEAD' 2>/dev/null
          exit 7
        else
          git push 2>&1 | tail -1 | sed 's/^/    /' || { echo "    push failed (committed locally)"; exit 6; }
        fi
      fi
    fi
  ) || rc=$?
  case "$rc" in
    0) changed_repos=$((changed_repos + 1)) ;;
    7) changed_repos=$((changed_repos + 1)); withheld_repos+=("$repo") ;;
    5) failed_repos+=("$repo: commit failed") ;;
    6) failed_repos+=("$repo: push failed (unreachable/rejected remote)") ;;
    *) failed_repos+=("$repo: exit $rc") ;;
  esac

  # Note whether this repo hit a conflict snapshot (best-effort — grepped
  # from the .local-edit siblings this run may have just written).
  for rel in "$REL_AGENT" .claude/settings.json; do
    [ -f "$repo_path/$rel.local-edit" ] && conflict_repos+=("$repo: $rel")
  done
done

echo
if [ "$CHECK" -eq 1 ]; then
  echo "drift items: $drift_total"
  [ "$drift_total" -eq 0 ] && { echo "ecosystem converged."; exit 0; } || { echo "DRIFT DETECTED."; exit 1; }
else
  echo "repos changed: $changed_repos  converged (no-op): $converged_repos"
  [ "${#withheld_repos[@]}" -gt 0 ] && printf 'push withheld: %s\n' "${withheld_repos[*]}"
  [ "${#failed_repos[@]}" -gt 0 ] && printf 'FAILED: %s\n' "${failed_repos[*]}"
  [ "${#failed_repos[@]}" -eq 0 ] || exit 1
fi
