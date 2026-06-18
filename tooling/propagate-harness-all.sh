#!/usr/bin/env bash
# propagate-harness-all.sh — ecosystem rollout of the harness / CLAUDE.md region.
#
# Thin orchestrator over the single-target tooling/propagate-harness.sh: it
# discovers every recipient repo, applies the per-repo convergent propagation,
# and (for clean repos) commits + pushes. Mirrors sync-skills.sh discipline.
#
# Why a wrapper, not an --all flag inside propagate-harness.sh:
#   propagate-harness.sh is a linear POSIX-sh flow over a single $TARGET, with
#   the region/hook/settings logic inlined. Its single-target core is validated
#   and has its own --check. The ecosystem concern (discover, dirty-skip, commit,
#   push) is orthogonal, so it lives here — exactly as sync-skills.sh is a
#   separate orchestrator rather than logic folded into a per-file primitive.
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
# DISCIPLINE:
#   - CLEAN repos: full convergent region replace + hooks + settings, commit, PUSH.
#   - DIRTY repos: the harness install is ADDITIVE and safety-critical (the
#     orchestrator block hooks protect the main agent), so we do NOT blanket-skip.
#     We install the harness and make a HARNESS-ONLY local commit (no push),
#     under hard invariants:
#       1. Stage ONLY harness paths via explicit `git add <paths>` (never -A/.);
#          assert `git diff --cached` contains nothing else or abort that repo.
#       2. Never clobber an owner-edited harness file: any harness path already
#          in the owner's uncommitted changes is RESTORED + deferred (recorded),
#          never overwritten.
#       3. Never push a dirty repo (owner WIP / may be ahead / may be private).
#       4. If nothing can be safely installed (e.g. both CLAUDE.md and
#          settings.json are owner-dirty), fall back to skip + TODO line.
#   - Idempotent / convergent: a second run on a converged ecosystem (clean OR
#     dirty) writes nothing and creates no empty commit.
#   - --check is a dry-run drift report; exits non-zero if any repo would change
#     or is unreachable; mutates nothing (dirty repos report what WOULD install).
#
# Usage:
#   propagate-harness-all.sh [--check] [--no-push]
#     --check    Dry run. Report per-repo drift, write/commit/push nothing,
#                exit non-zero if any drift (or unreachable recipient).
#     --no-push  Commit changed clean repos but do not push. (Dirty repos are
#                never pushed regardless.)

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

TODO_LINE="- [ ] sync ecosystem harness/CLAUDE.md region: run github-io/tooling/propagate-harness-all.sh once clean"

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

for repo_path in "${REPOS[@]}"; do
  repo="${repo_path#"$GIT_ROOT"/}"
  echo
  echo "=== $repo ==="

  if [ ! -d "$repo_path/.git" ]; then
    echo "  MISSING: not a git repo at $repo_path — reported, skipped"
    drift_total=$((drift_total + 1))
    continue
  fi

  # Dirty check FIRST. A dirty tree is NOT blanket-skipped: the harness install
  # is additive + safety-critical, so we install it harness-only (no push),
  # deferring any harness file the owner is themselves editing (never clobber).
  if [ -n "$(git -C "$repo_path" status --porcelain)" ]; then
    dirty_repos=$((dirty_repos + 1))

    # Which harness-managed paths is the OWNER already editing? Those we must not
    # touch. Match CLAUDE.md, .claude/settings.json, and the claude-hooks tree.
    owner_dirty_harness="$(git -C "$repo_path" status --porcelain \
      | sed 's/^...//' \
      | grep -E '^(CLAUDE\.md|\.claude/settings\.json|tooling/claude-hooks/)' || true)"
    md_dirty=0; settings_dirty=0
    printf '%s\n' "$owner_dirty_harness" | grep -qx 'CLAUDE.md'            && md_dirty=1       || true
    printf '%s\n' "$owner_dirty_harness" | grep -qx '.claude/settings.json' && settings_dirty=1 || true

    # --check: report only, mutate nothing.
    if [ "$CHECK" -eq 1 ]; then
      if "$PROPAGATE" --check "$repo_path" >/dev/null 2>&1; then
        echo "  DIRTY but harness already current — no install needed"
      else
        echo "  DIRTY: WOULD install harness additively (harness-only commit, no push)"
        [ -n "$owner_dirty_harness" ] && echo "    would DEFER owner-edited harness file(s): $(printf '%s' "$owner_dirty_harness" | tr '\n' ' ')"
        drift_total=$((drift_total + 1))
      fi
      continue
    fi

    # Residual fallback: if BOTH core files are owner-dirty, nothing safe to
    # install — revert to skip + TODO line.
    if [ "$md_dirty" -eq 1 ] && [ "$settings_dirty" -eq 1 ]; then
      echo "  DIRTY: CLAUDE.md AND settings.json both owner-edited — cannot install safely; skip + TODO"
      drift_total=$((drift_total + 1))
      todo="$repo_path/TODO.md"
      if ! grep -qF -- "$TODO_LINE" "$todo" 2>/dev/null; then
        printf '%s\n' "$TODO_LINE" >> "$todo"
        echo "    TODO.md note left on disk (owner WIP present; not committed)"
      else
        echo "    TODO.md already carries the note"
      fi
      continue
    fi

    echo "  DIRTY: installing harness additively (harness-only commit, no push)"
    [ -n "$owner_dirty_harness" ] && echo "    DEFERRING owner-edited harness file(s): $(printf '%s' "$owner_dirty_harness" | tr '\n' ' ')"

    # Snapshot the owner's WORKING-TREE bytes of every owner-dirty harness file
    # BEFORE we let the propagator touch anything. We restore these exact bytes
    # afterward — NOT `git checkout` (which would revert to HEAD/index and so
    # destroy the owner's uncommitted edit). This is the never-clobber guarantee.
    snap_dir=""
    if [ -n "$owner_dirty_harness" ]; then
      snap_dir="$(mktemp -d)"
      printf '%s\n' "$owner_dirty_harness" | while IFS= read -r f; do
        [ -n "$f" ] || continue
        if [ -f "$repo_path/$f" ]; then
          mkdir -p "$snap_dir/$(dirname "$f")"
          cp -p "$repo_path/$f" "$snap_dir/$f"
        fi
      done
    fi

    # Run the convergent propagator (writes harness files).
    "$PROPAGATE" "$repo_path" >/dev/null

    # Restore owner working-tree bytes for every deferred harness file.
    if [ -n "$snap_dir" ]; then
      printf '%s\n' "$owner_dirty_harness" | while IFS= read -r f; do
        [ -n "$f" ] || continue
        if [ -e "$snap_dir/$f" ]; then
          cp -p "$snap_dir/$f" "$repo_path/$f"
        fi
      done
      rm -rf "$snap_dir"
    fi

    # Stage ONLY harness paths, explicitly — NEVER -A/. — and never the deferred ones.
    ( cd "$repo_path"
      for p in CLAUDE.md .claude/settings.json tooling/claude-hooks; do
        case "$p" in
          CLAUDE.md)              [ "$md_dirty" -eq 1 ] && continue ;;
          .claude/settings.json)  [ "$settings_dirty" -eq 1 ] && continue ;;
        esac
        git add -- "$p" >/dev/null 2>&1 || true
      done
      # Un-stage any deferred hooks-tree files the owner is editing.
      printf '%s\n' "$owner_dirty_harness" | while IFS= read -r f; do
        [ -n "$f" ] || continue
        git reset -q -- "$f" >/dev/null 2>&1 || true
      done

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
        exit 3   # signal: no commit made
      fi

      direnv exec . git commit -q -m "chore(harness): install orchestrator hooks + sync CLAUDE.md region" 2>/dev/null \
        || git commit -q -m "chore(harness): install orchestrator hooks + sync CLAUDE.md region"
      echo "    harness-only commit made (NOT pushed — dirty repo)"
    ) && changed_repos=$((changed_repos + 1)) || true
    continue
  fi

  # Clean repo: run the single-target propagator.
  if [ "$CHECK" -eq 1 ]; then
    if "$PROPAGATE" --check "$repo_path"; then
      echo "  already current"
    else
      echo "  WOULD UPDATE (drift above)"
      drift_total=$((drift_total + 1))
    fi
    continue
  fi

  # Apply, then commit/push only if it actually changed something.
  "$PROPAGATE" "$repo_path"
  if [ -z "$(git -C "$repo_path" status --porcelain)" ]; then
    echo "  already current — no changes"
    continue
  fi

  ( cd "$repo_path"
    direnv allow . >/dev/null 2>&1 || true
    [ -x "$NORMALIZE" ] && direnv exec . "$NORMALIZE" init >/dev/null 2>&1 || true
    git add CLAUDE.md tooling/claude-hooks .claude/settings.json .gitignore .normalize/ >/dev/null 2>&1 || true
    if git diff --cached --quiet; then
      echo "  nothing staged"
    else
      direnv exec . git commit -q -m "chore(harness): sync ecosystem CLAUDE.md region + hooks from github-io" \
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
  echo "drift items: $drift_total  (dirty receivers: $dirty_repos)"
  [ "$drift_total" -eq 0 ] && { echo "ecosystem converged."; exit 0; } || { echo "DRIFT DETECTED."; exit 1; }
else
  echo "repos changed: $changed_repos  (dirty receivers, harness installed locally/no-push where safe: $dirty_repos)"
fi
