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
# DISCIPLINE (mirrors sync-skills.sh):
#   - Dirty-receiver skip FIRST: a dirty tree is never mutated/committed; it is
#     reported and a TODO.md line is suggested (and, when TODO.md itself is
#     clean, appended + committed — matching the ecosystem-refactor rule).
#   - Idempotent / convergent: a second run on a converged ecosystem writes nothing.
#   - --check is a dry-run drift report; exits non-zero if any repo would change
#     or is unreachable; mutates nothing.
#   - Default mirrors sync-skills.sh: commit AND push clean, changed repos.
#
# Usage:
#   propagate-harness-all.sh [--check] [--no-push]
#     --check    Dry run. Report per-repo drift, write/commit/push nothing,
#                exit non-zero if any drift (or dirty/unreachable recipient).
#     --no-push  Commit changed clean repos but do not push.

set -euo pipefail

HUB="$(cd "$(dirname "$0")/.." && pwd)"          # github-io repo root (canonical source)
GIT_ROOT="$(cd "$HUB/../.." && pwd)"             # ~/git
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

  # Dirty check FIRST — never mutate a dirty tree.
  if [ -n "$(git -C "$repo_path" status --porcelain)" ]; then
    echo "  DIRTY: skipping (no mutation). Suggested TODO.md line:"
    echo "    $TODO_LINE"
    dirty_repos=$((dirty_repos + 1))
    drift_total=$((drift_total + 1))
    if [ "$CHECK" -eq 0 ]; then
      # Append the TODO line only if TODO.md is itself clean (don't sweep WIP).
      todo="$repo_path/TODO.md"
      if ! grep -qF "$TODO_LINE" "$todo" 2>/dev/null; then
        printf '%s\n' "$TODO_LINE" >> "$todo"
        if [ -z "$(git -C "$repo_path" status --porcelain -- TODO.md | grep -v '^??')" ] \
           && git -C "$repo_path" ls-files --error-unmatch TODO.md >/dev/null 2>&1; then
          # TODO.md was tracked and (other than our line) clean — commit just it.
          if [ -z "$(git -C "$repo_path" status --porcelain | grep -v 'TODO.md$')" ]; then
            ( cd "$repo_path"
              git add TODO.md
              direnv exec . git commit -q -m "docs(todo): pending harness/CLAUDE.md region sync" 2>/dev/null \
                || git commit -q -m "docs(todo): pending harness/CLAUDE.md region sync"
            ) && echo "    TODO.md note committed"
          else
            echo "    TODO.md note left on disk (other WIP present; not committed)"
          fi
        else
          echo "    TODO.md note left on disk (untracked or WIP; not committed)"
        fi
      else
        echo "    TODO.md already carries the note"
      fi
    fi
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
  echo "drift items: $drift_total  (dirty/skipped: $dirty_repos)"
  [ "$drift_total" -eq 0 ] && { echo "ecosystem converged."; exit 0; } || { echo "DRIFT DETECTED."; exit 1; }
else
  echo "repos changed: $changed_repos  (dirty/skipped: $dirty_repos)"
fi
