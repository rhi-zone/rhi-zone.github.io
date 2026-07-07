#!/usr/bin/env bash
# propagate-harness-all.sh — ecosystem rollout of the harness / CLAUDE.md region.
#
# Thin orchestrator over the single-target tooling/propagate-harness.sh: it
# discovers every recipient repo, applies the per-repo convergent propagation,
# and commits + pushes (subject to push-safety). Mirrors sync-skills.sh
# discipline.
#
# Why a wrapper, not an --all flag inside propagate-harness.sh:
#   propagate-harness.sh is a linear POSIX-sh flow over a single $TARGET, with
#   the region/hook/settings logic inlined. Its single-target core is validated
#   and has its own --check. The ecosystem concern (discover, converge-always,
#   conflict snapshotting, commit, push-safety) is orthogonal, so it lives here
#   — exactly as sync-skills.sh is a separate orchestrator rather than logic
#   folded into a per-file primitive.
#
# RECIPIENT SET — the harness/CLAUDE.md-region recipients are the repos that
#   CARRY the ecosystem-rules markers, discovered by grepping CLAUDE.md across
#   ~/git (excluding worktrees), NOT tooling/skill-recipients.txt. The skill
#   recipient list is a strict subset; using it would silently miss ~17 repos
#   that carry the region (e.g. ascent-interpreter, keybinds, ooxml, the org
#   github-io/profile clones, several pterror repos). See
#   docs/artifacts/propagate-data-over-code-2026-06-14/summary.md (54 recipients).
#   The canonical github-io is excluded (it is its own source of truth).
#
# DISCIPLINE — converge-always, no skips:
#   - Every recipient is processed every run, clean or dirty. Only harness paths
#     (CLAUDE.md, .claude/settings.json, tooling/claude-hooks/) are ever staged
#     via explicit `git add <paths>` (never -A/.); a dirty tree elsewhere is
#     left completely untouched and is never a reason to skip a repo.
#   - CONFLICT EDGE: if the owner has uncommitted edits to a harness path this
#     run is about to overwrite, that path's on-disk bytes are snapshotted to
#     an untracked `<path>.local-edit` FIRST (an existing snapshot is
#     overwritten only if byte-different; else left alone), then canon is
#     installed over it and committed. Canon always wins in the tree; owner
#     bytes are never destroyed. Reported LOUDLY per occurrence.
#   - No TODO.md writes, anywhere, ever — all reporting is run-output only.
#   - PUSH SAFETY: before pushing any receiver (clean-repo or harness-only
#     commit alike), its unpushed commits (`@{u}..HEAD`) must ALL match this
#     script's own housekeeping commit-message patterns; if any unpushed
#     commit is unrelated owner work, the commit still lands but the push is
#     withheld and reported (a withheld push is not a skip — the tree converged).
#   - Idempotent / convergent: a second run on a converged ecosystem writes
#     nothing and creates no empty commit.
#   - --check is a dry-run drift report; exits non-zero if any repo would change
#     or is unreachable; mutates nothing (dirty repos report what WOULD install,
#     including any CONFLICT that would be preserved as .local-edit).
#
# Usage:
#   propagate-harness-all.sh [--check] [--no-push]
#     --check    Dry run. Report per-repo drift, write/commit/push nothing,
#                exit non-zero if any drift (or unreachable recipient).
#     --no-push  Commit changed repos but do not push.

set -euo pipefail

HUB="$(cd "$(dirname "$0")/.." && pwd)"          # github-io repo root (canonical source)
# Scan root for recipient discovery. Defaults to ~/git; overridable via
# HARNESS_ALL_GIT_ROOT for testing against throwaway fixtures.
GIT_ROOT="$(cd "${HARNESS_ALL_GIT_ROOT:-$HUB/../..}" && pwd)"
PROPAGATE="$HUB/tooling/propagate-harness.sh"
NORMALIZE="$GIT_ROOT/rhizone/normalize/target/debug/normalize"
CANONICAL_CLAUDE_MD_REAL="$(realpath "$HUB/CLAUDE.md")"

[ -x "$PROPAGATE" ] || { echo "error: $PROPAGATE not found/executable" >&2; exit 2; }

CHECK=0; PUSH=1
for arg in "$@"; do
  case "$arg" in
    --check)   CHECK=1 ;;
    --no-push) PUSH=0 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

# PUSH SAFETY: every unpushed commit ahead of upstream must match one of this
# ecosystem's own housekeeping commit-message patterns (this script's two commit
# forms, the single-target propagator's dirty-additive form, and the receiver
# TODO-sweep commit), or the push is withheld — commit still lands, push doesn't.
# No upstream at all (never-pushed branch) is not gated here.
HARNESS_COMMIT_RE='^chore\(harness\): (install orchestrator hooks \+ sync CLAUDE\.md region|sync ecosystem CLAUDE\.md region \+ hooks from github-io|remove propagation skip-notices — mechanism retired)$'
push_is_safe() {
  local repo_path="$1" bad
  git -C "$repo_path" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 || return 0
  bad="$(git -C "$repo_path" log --format=%s '@{u}..HEAD' 2>/dev/null | grep -Ev "$HARNESS_COMMIT_RE" || true)"
  [ -z "$bad" ]
}

# CONFLICT EDGE: if $repo_path/$rel is tracked and carries uncommitted owner
# edits, snapshot its current bytes to "$rel.local-edit" (overwritten only if
# byte-different from an existing snapshot; else left alone) before canon
# overwrites it. Reports always; writes only in apply mode.
conflict_snapshot() {
  local repo_path="$1" rel="$2" dst edit
  dst="$repo_path/$rel"
  [ -f "$dst" ] || return 0
  [ -n "$(git -C "$repo_path" status --porcelain -- "$rel" 2>/dev/null)" ] || return 0
  if [ "$CHECK" -eq 1 ]; then
    echo "    CONFLICT: $rel has uncommitted owner edits (would preserve as $rel.local-edit)"
    return 0
  fi
  edit="$dst.local-edit"
  if [ -f "$edit" ] && cmp -s "$dst" "$edit"; then
    :
  else
    cp -p "$dst" "$edit"
  fi
  echo "    CONFLICT: $rel has uncommitted owner edits — preserved as $rel.local-edit (canon installed)"
}

# ── Discover recipients: every CLAUDE.md bearing the BEGIN marker under ~/git,
#    excluding worktrees and the canonical github-io itself. ──────────────────
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

drift_total=0
changed_repos=0
dirty_repos=0

# End-of-run classification (apply mode). One repo's failure must NEVER abort the
# batch: each repo is isolated, its outcome recorded here, and the run continues.
SUCCEEDED=()        # clean repo: committed (+pushed unless withheld/--no-push)
DIRTY_ADDITIVE=()   # dirty repo: harness-only commit installed (pushed if safe)
SKIPPED=()          # already-current, missing, nothing-staged
FAILED=()           # propagate error, push rejected/unreachable remote, commit error

# ── Per-repo processing, fully isolated. Returns 0 always (records its own
#    outcome); the known failure-prone calls (propagator, commit, push) are
#    explicitly guarded and turned into FAILED records with a reason, so an
#    unreachable remote (git push exit 128) or any per-repo error can no longer
#    propagate up and abort the batch. ─────────────────────────────────────────
process_one_repo() {
  local repo_path="$1"
  local repo="${repo_path#"$GIT_ROOT"/}"
  echo
  echo "=== $repo ==="

  if [ ! -d "$repo_path/.git" ]; then
    echo "  MISSING: not a git repo at $repo_path — reported, skipped"
    drift_total=$((drift_total + 1))
    SKIPPED+=("$repo: not a git repo")
    return 0
  fi

  # Dirty check FIRST — but NOT a skip gate. Converge-always: a dirty tree
  # (elsewhere) is never a reason to exempt a repo from the harness install.
  # Any harness path the owner has uncommitted edits to is preserved as
  # <path>.local-edit (conflict_snapshot) before canon overwrites it.
  if [ -n "$(git -C "$repo_path" status --porcelain)" ]; then
    dirty_repos=$((dirty_repos + 1))

    local owner_dirty_harness
    owner_dirty_harness="$(git -C "$repo_path" status --porcelain \
      | sed 's/^...//' \
      | grep -E '^(CLAUDE\.md|\.claude/settings\.json|tooling/claude-hooks/)' || true)"

    # --check: report only, mutate nothing.
    if [ "$CHECK" -eq 1 ]; then
      if "$PROPAGATE" --check "$repo_path" >/dev/null 2>&1; then
        echo "  DIRTY but harness already current — no install needed"
      else
        echo "  DIRTY: WOULD install harness (converge-always)"
        if [ -n "$owner_dirty_harness" ]; then
          printf '%s\n' "$owner_dirty_harness" | while IFS= read -r f; do
            [ -n "$f" ] || continue
            conflict_snapshot "$repo_path" "$f"
          done
        fi
        drift_total=$((drift_total + 1))
      fi
      return 0
    fi

    echo "  DIRTY: installing harness (converge-always; owner edits preserved as .local-edit if conflicting)"

    # CONFLICT EDGE: snapshot every owner-dirty harness path's on-disk bytes
    # BEFORE the propagator overwrites it. Canon always wins in the tree;
    # owner bytes are never destroyed — moved aside as <path>.local-edit.
    if [ -n "$owner_dirty_harness" ]; then
      printf '%s\n' "$owner_dirty_harness" | while IFS= read -r f; do
        [ -n "$f" ] || continue
        conflict_snapshot "$repo_path" "$f"
      done
    fi

    # Run the convergent propagator (writes harness files). Guarded: a propagator
    # failure records FAILED and bails this repo rather than aborting the batch.
    if ! "$PROPAGATE" "$repo_path" >/dev/null 2>&1; then
      echo "    FAILED: propagator errored on dirty repo — skipping (no commit)" >&2
      FAILED+=("$repo: propagator error (dirty install)")
      return 0
    fi

    # Stage ONLY harness paths, explicitly — NEVER -A/. — canon wins even over
    # the owner-dirty ones (their prior bytes already live in .local-edit).
    local rc=0
    ( cd "$repo_path"
      git add -- CLAUDE.md .claude/settings.json tooling/claude-hooks >/dev/null 2>&1 || true

      if git diff --cached --quiet; then
        echo "    nothing to install — already current (no commit)"
        exit 3   # signal: no commit made
      fi

      # INVARIANT GUARD: staged set must contain ONLY harness paths. If anything
      # else slipped in, abort this repo (do not commit owner WIP).
      stray="$(git diff --cached --name-only \
        | grep -Ev '^(CLAUDE\.md|\.claude/settings\.json|tooling/claude-hooks/)' || true)"
      if [ -n "$stray" ]; then
        echo "    ABORT: non-harness path staged ($(printf '%s' "$stray" | tr '\n' ' ')) — resetting, not committing" >&2
        git reset -q >/dev/null 2>&1 || true
        exit 4   # signal: aborted on stray (treat as failure)
      fi

      direnv exec . git commit -q -m "chore(harness): install orchestrator hooks + sync CLAUDE.md region" 2>/dev/null \
        || git commit -q -m "chore(harness): install orchestrator hooks + sync CLAUDE.md region" \
        || exit 5   # commit failed
      echo "    harness-only commit made"

      if [ "$PUSH" -eq 1 ]; then
        if [ -n "$(git status --porcelain -- CLAUDE.md .claude/settings.json tooling/claude-hooks)" ]; then
          echo "    not pushed: harness paths not clean after commit"
          exit 0
        elif [ -z "$(git remote)" ]; then
          echo "    not pushed: no remote configured (committed locally)"
        elif ! push_is_safe "$repo_path"; then
          echo "    PUSH WITHHELD: unpushed commit(s) ahead of upstream aren't recognized housekeeping — commit landed, not pushed:"
          git log --format='      - %s' '@{u}..HEAD' 2>/dev/null
        else
          local push_out push_rc=0
          push_out="$(git push 2>&1)" || push_rc=$?
          printf '%s\n' "$push_out" | tail -1 | sed 's/^/    /'
          [ "$push_rc" -eq 0 ] || exit 6
        fi
      fi
    ) || rc=$?

    case "$rc" in
      0) changed_repos=$((changed_repos + 1)); DIRTY_ADDITIVE+=("$repo: harness commit installed") ;;
      3) SKIPPED+=("$repo: dirty, already current (nothing to install)") ;;
      4) FAILED+=("$repo: non-harness path staged — aborted, not committed") ;;
      5) FAILED+=("$repo: harness-only commit failed") ;;
      6) FAILED+=("$repo: git push failed (unreachable/rejected remote)") ;;
      *) FAILED+=("$repo: dirty-tree install failed (exit $rc)") ;;
    esac
    return 0
  fi

  # Clean repo: run the single-target propagator.
  if [ "$CHECK" -eq 1 ]; then
    if "$PROPAGATE" --check "$repo_path"; then
      echo "  already current"
    else
      echo "  WOULD UPDATE (drift above)"
      drift_total=$((drift_total + 1))
    fi
    return 0
  fi

  # Apply, then commit/push only if it actually changed something. Guarded: a
  # propagator failure records FAILED and bails rather than aborting the batch.
  if ! "$PROPAGATE" "$repo_path"; then
    echo "  FAILED: propagator errored — skipping" >&2
    FAILED+=("$repo: propagator error")
    return 0
  fi
  if [ -z "$(git -C "$repo_path" status --porcelain)" ]; then
    echo "  already current — no changes"
    SKIPPED+=("$repo: already current")
    return 0
  fi

  local rc=0
  ( cd "$repo_path"
    direnv allow . >/dev/null 2>&1 || true
    [ -x "$NORMALIZE" ] && direnv exec . "$NORMALIZE" init >/dev/null 2>&1 || true
    git add CLAUDE.md tooling/claude-hooks .claude/settings.json .gitignore .normalize/ >/dev/null 2>&1 || true
    if git diff --cached --quiet; then
      echo "  nothing staged"
      exit 3   # signal: nothing to commit
    fi
    direnv exec . git commit -q -m "chore(harness): sync ecosystem CLAUDE.md region + hooks from github-io" \
      || exit 5   # commit failed
    echo "  committed"
    if [ "$PUSH" -eq 1 ]; then
      if [ -n "$(git status --porcelain -- CLAUDE.md tooling/claude-hooks .claude/settings.json .gitignore .normalize)" ]; then
        echo "    not pushed: harness paths not clean after commit"
        exit 0
      fi
      if [ -z "$(git remote)" ]; then
        echo "    not pushed: no remote configured (committed locally)"
        exit 0
      fi
      if ! push_is_safe "$repo_path"; then
        echo "    PUSH WITHHELD: unpushed commit(s) ahead of upstream aren't recognized housekeeping — commit landed, not pushed:"
        git log --format='      - %s' '@{u}..HEAD' 2>/dev/null
        exit 0
      fi
      # Capture push output so a failing remote (exit 128: unreachable/rejected)
      # is detected and reported WITHOUT a pipeline masking it or set -e aborting
      # the batch. The error is recorded by the caller via exit 6.
      local push_out push_rc=0
      push_out="$(git push 2>&1)" || push_rc=$?
      printf '%s\n' "$push_out" | tail -1 | sed 's/^/    /'
      [ "$push_rc" -eq 0 ] || exit 6   # push failed (unreachable/rejected remote)
    fi
  ) || rc=$?

  case "$rc" in
    0) changed_repos=$((changed_repos + 1))
       if [ "$PUSH" -eq 1 ]; then SUCCEEDED+=("$repo: committed + pushed"); else SUCCEEDED+=("$repo: committed (--no-push)"); fi ;;
    3) SKIPPED+=("$repo: nothing staged after propagate") ;;
    5) FAILED+=("$repo: commit failed") ;;
    6) FAILED+=("$repo: git push failed (unreachable/rejected remote)") ;;
    *) FAILED+=("$repo: clean-repo processing failed (exit $rc)") ;;
  esac
  return 0
}

for repo_path in "${REPOS[@]}"; do
  repo="${repo_path#"$GIT_ROOT"/}"
  # Belt-and-braces: even an unexpected non-zero from the function (set -e ERR)
  # must not abort the batch — record it and move on.
  process_one_repo "$repo_path" || FAILED+=("$repo: unexpected error (per-repo processing aborted)")
done

echo
if [ "$CHECK" -eq 1 ]; then
  echo "drift items: $drift_total  (dirty receivers: $dirty_repos)"
  [ "$drift_total" -eq 0 ] && { echo "ecosystem converged."; exit 0; } || { echo "DRIFT DETECTED."; exit 1; }
fi

# ── Apply-mode end-of-run summary: classified, with per-repo reasons. ──────────
print_group() {
  local title="$1"; shift
  [ "$#" -eq 0 ] && return 0
  echo "$title ($#):"
  local item
  for item in "$@"; do echo "  - $item"; done
}

echo "═══ rollout summary ═══"
print_group "SUCCEEDED (clean, committed/pushed)"        "${SUCCEEDED[@]}"
print_group "DIRTY-ADDITIVE (harness-only commit, no push)" "${DIRTY_ADDITIVE[@]}"
print_group "SKIPPED / DEFERRED"                          "${SKIPPED[@]}"
print_group "FAILED"                                      "${FAILED[@]}"
echo
echo "totals: succeeded=${#SUCCEEDED[@]}  dirty-additive=${#DIRTY_ADDITIVE[@]}  skipped=${#SKIPPED[@]}  failed=${#FAILED[@]}"

if [ "${#FAILED[@]}" -gt 0 ]; then
  echo "ROLLOUT INCOMPLETE: ${#FAILED[@]} repo(s) failed (see FAILED above)." >&2
  exit 1
fi
echo "rollout complete: no failures."
exit 0
