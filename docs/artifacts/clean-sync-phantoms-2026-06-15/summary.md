# Clean-sync of 7 phantom-dirty repos (2026-06-15)

Seven repos carried a stale CLAUDE.md ECOSYSTEM RULES region but no genuine
developer WIP — past propagation runs deferred them because the dirty-check
tripped on runtime artifacts (worktree submodules, brain/ session locks,
normalize caches) and self-inflicted propagator deferral notes in TODO.md.

Canonical source: `~/git/rhizone/github-io/CLAUDE.md` (post-commit e678388).
The synced region drops two harness-management bullets that no longer belong in
the propagated region:

- "No ecosystem changes without checking all affected repos."
- "Control surface stays self-contained and versioned."

Both are now confirmed absent from every committed `HEAD:CLAUDE.md` below, and
every synced region was byte-diffed equal to canonical before commit.

## Per-repo results

### 1. pterror/fuwafuwa — commit `02f84044` (pushed)
- Synced: ECOSYSTEM RULES region (3 ins / 5 del).
- Left untouched: `.claude/worktrees/agent-a9d9eb96f24f320d4` submodule (runtime, -dirty).
- Commit contents: CLAUDE.md only.

### 2. rhizone/defocus — commit `c825543` (pushed)
- Synced: region. (Audit said "already current / no CLAUDE.md change" — WRONG:
  both stale bullets were present despite a same-day commit, so the region did
  need syncing. Deviation in the safe direction; proceeded.)
- `normalize init`: no-op ("Already initialized").
- Left untouched (deliberately dirty): tracked volatile caches
  `.normalize/cache/summary-freshness.json`, `findings-cache.sqlite`,
  `index.sqlite` — regenerate on every run; not chased per instructions.
- Commit contents: CLAUDE.md only (2 del).

### 3. paragarden/postmortem — commit `43b7b5f` (pushed)
- Synced: region.
- Removed cruft: stripped all stacked propagator deferral blocks from TODO.md.
  Preserved the full genuine TODO (World infrastructure, First content,
  worldbuilding questions, writing principles, voice touchstones).
- `normalize init`: created `.normalize/config.toml` and the `.normalize/*`
  gitignore allow-list (repo previously had only stray April caches, no config).
- Commit contents: CLAUDE.md, TODO.md, .gitignore, .normalize/config.toml.
  Volatile sqlite/cache files correctly excluded by the new gitignore.
- Working tree fully clean after commit.

### 4. paragarden/solarium — commit `a74365d` (pushed)
- Synced: region.
- TODO.md: audit said "untracked, only propagator notes → delete it" — WRONG:
  it contained a genuine "Minecraft peaceful horror" design direction. Per the
  governing rule (preserve genuine content), did NOT delete — stripped only the
  boilerplate and left the file untracked, as it was.
- `normalize init`: "Already initialized"; config.toml existed but was untracked.
  Staged it (gitignore already committed).
- Left untouched: `maybe-rules.md` (old May-2 design notes, untracked).
- Commit contents: CLAUDE.md, .normalize/config.toml.

### 5. pterror/ashwren — commit `5cb99df` (pushed)
- Synced: region.
- TODO.md: the modification was only working-tree-appended boilerplate; the
  committed HEAD TODO was already clean. Truncating the boilerplate restored
  TODO to match HEAD exactly (no TODO change in the commit).
- Audit claimed `packages/core/.normalize/` untracked — WRONG: no `.normalize/`
  directory exists anywhere in the repo and there are no normalize gitignore
  entries. No normalize work to do.
- Left untouched (deliberately dirty): `brain/heartbeat-state.json`,
  `brain/session.lock` (runtime).
- Commit contents: CLAUDE.md only (3 ins / 5 del).

### 6. rhizone/rainbow — commit `a2890ec` (pushed)
- Synced: region.
- TODO.md: stripped only the appended propagator notes (working-tree-only); the
  rich committed TODO was already clean at HEAD and is preserved. Truncation
  restored TODO to match HEAD (no TODO change in the commit).
- `normalize init` in `packages/core`: created `packages/core/.gitignore`
  (normalize-only) and `packages/core/.normalize/config.toml`. Volatile
  sqlite/caches excluded.
- Commit contents: CLAUDE.md, packages/core/.gitignore,
  packages/core/.normalize/config.toml.
- Working tree fully clean after commit.

### 7. rhizone/scribble — commit `eb15bea` (pushed)
- Synced: region. (scribble had only the "No ecosystem changes" bullet pre-sync;
  both now absent.)
- TODO.md: untracked; preserved the genuine 2026-03-29 correction note
  (corrections-as-documentation-lag + context-poisoning handoff rule), stripped
  the propagator boilerplate, and left the file untracked as it was.
- normalize: config.toml already tracked; no normalize work.
- Commit contents: CLAUDE.md only (6 ins / 2 del).

## Verification

For every committed `HEAD:CLAUDE.md`:
- `grep -cF 'No ecosystem changes without checking all affected repos.'` -> 0
- `grep -cF 'Control surface stays self-contained and versioned.'` -> 0
- ECOSYSTEM RULES region byte-equal to canonical (`diff` clean) before commit.

No runtime artifact or developer WIP was swept into any commit:
- fuwafuwa worktree submodule, ashwren brain/ files, defocus volatile normalize
  caches: left deliberately dirty.
- solarium maybe-rules.md and TODO, scribble TODO: left untracked.
- All normalize commits contain only config.toml (+ gitignore where newly
  created); no sqlite/cache/diagnostics files staged.

## Audit corrections noted

- **defocus**: needed the region sync (audit said it didn't).
- **solarium**: TODO had genuine content (audit said delete-it); preserved.
- **ashwren**: no `packages/core/.normalize/` exists (audit said untracked); no
  normalize work performed.

None of these rose to "real WIP found -> stop"; all were resolved by the
governing rules.
