# Skill Loading Audit — Synthesis (Recommended Design)

Synthesized 2026-06-16 from the four candidates (A subtract, B registry, C modern,
D plugin), the three adversarial judges (1 harness, 2 propagation, 3 migration), and
the ground-truth audit (`mechanism.md`). This is the single recommended mechanism.

---

## 0. What survived, and the base we build on

The candidates converged on a skeleton all three judges accept: **committed per-repo
skills (github-io included), kill find-by-presence, demote the symlink layer.** The
judges then sharpened it on three axes:

- **Judge 1 (harness):** the personal `~/.claude` symlink is *global by construction*
  and *personal-over-project* in precedence, so it shadows **every** repo's committed
  copy, not just github-io's. "Optional convenience" is incoherent. **Remove entirely.**
  A came closest (propagator never touches `~/.claude`, migration deletes the real
  files); B/C/D each ship a symlink-creating helper and were wounded for it.
- **Judge 2 (propagation):** only **A and C** have ONE true source inside github-io
  (collapse canonical and load path into one committed `.claude/` dir). **B and D**
  keep two copies inside github-io (warehouse + deployed) reconciled only by running
  the tool — the *same* two-location drift the audit already caught live
  (`think-with-the-engineering-taste` on disk, not in git). C is the most operationally
  complete (idempotent, convergent, multi-class drift detection, correct dirty-skip);
  its one required fix is to stop parsing `docs/about.md` for targets and use an
  explicit list.
- **Judge 3 (migration):** the `.commands → .skills/SKILL.md` **format migration is
  orthogonal to all four requirements** and every candidate welded it onto the
  critical-path fix, multiplying blast radius and courting the half-migration strand
  (the dirty-repo-skip rule guarantees a mixed ecosystem the moment any repo is dirty).
  R3 needs only an explicit newline-delimited repo list — TOML/sets (B) and
  glob-against-prose (C) are over-built; the minimal form is `tooling/skill-repos.txt`.

**The recommended design = A's/C's clean end-state architecture (one committed dir,
no symlink layer, no warehouse split) + Judge 3's minimal-blast-radius migration
sequencing (stay on `.claude/commands/`; fence the format migration) + C's idempotent
convergent sync contract with the safety rails Judge 2 demanded.** Judge 1's
remove-the-symlink-entirely verdict is adopted without compromise.

The disagreement between A/C and Judge 3 is purely about *sequencing and file format*,
not destination. We take Judge 3's substrate (`.claude/commands/`, flat `.md`) for the
correctness fix and record the `.skills/` directory migration as a separately-fenced
later step — getting the safe migration now and the clean end-state later without the
strand risk.

---

## 1. The recommended mechanism

### Layout — identical in every repo, github-io included

```
<repo>/
  .claude/
    settings.json            # committed, hooks only (unchanged)
    settings.local.json      # gitignored, permissions/secrets (unchanged)
    commands/
      design-it-twice.md     # committed real files — THE load path, every repo
      handoff.md
      polish.md
      ...                    # whichever skills this repo carries
```

In **github-io specifically**, `.claude/commands/` is *both* the canonical authoring
source for the ecosystem *and* github-io's own load path. There is no
`tooling/claude-commands/` warehouse and no `~/.claude` entry. One directory, two
roles, zero internal duplication (Judge 2's collapse; A's "one dir, two roles"). Editing
a file in github-io's committed `.claude/commands/` is immediately live for github-io at
project scope — that *is* the live-authoring loop, preserved without any symlink
(resolves Judge 3's worry; see §Resolution 1).

### Distribution registry — `tooling/skill-repos.txt`

A single committed, newline-delimited list of recipient repos (paths relative to
`~/git`), comments with `#`. Zero parser, zero dependency, pure POSIX `grep`. This is
the entire R3 fix: it replaces the find-by-presence discovery rule. See §Resolution 4
for the subsetting decision (a flat list suffices; no per-skill→repo mapping needed).

### Sync tool — `tooling/sync-skills.sh` (replaces `propagate-skill.sh`)

Reads bytes **only** from github-io's committed `.claude/commands/` and the explicit
repo list. Never reads or writes `~/.claude`. Idempotent and convergent with a
non-destructive default and a `--check` drift mode. Full contract in §Resolution 5.

### CLAUDE.md — corrected to match reality

Canonical = github-io's committed `.claude/commands/`. Registry =
`tooling/skill-repos.txt`. Propagation = `tooling/sync-skills.sh`. Every repo including
github-io carries committed `.claude/commands/*.md` loaded directly. `~/.claude/commands`
and `~/.claude/skills` entries for ecosystem skills are **forbidden** — they are global
and shadow every repo's committed copy (§Resolution 1). The false "canonical =
`tooling/claude-commands/`" and "updates `~/.claude` first" prose is removed.

### In six bullets

1. **One committed dir per repo, `.claude/commands/*.md`, github-io included** — the
   load path everywhere; github-io stops being special.
2. **github-io's committed `.claude/commands/` IS the canonical source** — no
   `tooling/claude-commands/` warehouse, no `~/.claude`, no second copy to drift.
3. **`~/.claude` skill entries removed entirely and forbidden** — global + personal
   precedence makes them shadow every repo; not an "optional convenience."
4. **`tooling/skill-repos.txt`** — flat explicit recipient list, replaces
   find-by-presence; zero dependency.
5. **`tooling/sync-skills.sh`** — idempotent, convergent, non-destructive default,
   skips dirty receivers safely, `--check` drift mode.
6. **Stay on `.claude/commands/` (flat `.md`) for the fix; fence the `.skills/SKILL.md`
   directory migration as a separate later step** — orthogonal to correctness, avoids
   the half-migration strand.

---

## 2. Resolved tensions

### Resolution 1 — Symlinks: REMOVE ENTIRELY (Judge 1 wins; Judge 3's worry dissolved)

**Decision: the propagator never creates a `~/.claude` skill entry; migration deletes
the existing `handoff`/`polish` real files and all six symlinks; CLAUDE.md forbids
recreating them.**

Judge 1 is decisive and correct: `~/.claude/commands/<name>` (and `~/.claude/skills/`)
is **global by construction** — it has no per-repo scope — and personal precedence beats
project precedence, so a single such entry shadows the committed copy of *every* repo the
operator ever opens, not just github-io's. The audit's original defect is exactly this:
a machine-local personal entry on the load path. "Optional convenience" reintroduces that
defect and projects it ecosystem-wide. There is no scoped form to keep.

Judge 3's worry — that killing the symlink layer loses the live-authoring loop — is
**resolved by the canonical-into-`.claude/` collapse, not by keeping a symlink.** The
symlink-into-`tooling/` topology was only the live-edit mechanism *because* github-io's
canonical files lived in `tooling/` (which the harness does not load) and the symlink
bridged them to a load path. Once github-io's canonical files live in github-io's own
committed `.claude/commands/`, the harness loads that directory directly at project scope:
**editing the committed file is immediately live for github-io with zero symlink.** The
live loop survives for the hub (the dominant author loop, as Judge 3 concedes). The
receiver-side iteration loss (edit-in-hub → sync → test-in-receiver) is real but minor and
intrinsic to self-containment — no symlink can fix it without re-creating the shadow.

CLAUDE.md states the rule explicitly: *creating a `~/.claude/commands` or
`~/.claude/skills` entry for an ecosystem skill shadows every repo's committed copy and is
forbidden.* No `link-skills.sh` helper is shipped (the trap B/C/D fell into).

### Resolution 2 — One canonical, not two (Judge 2 wins; collapse confirmed)

**Decision: github-io's committed `.claude/commands/` IS the canonical source. There is
no `tooling/claude-commands/` warehouse and no separate `.claude/` deployed copy. The
propagator reads from this one committed dir, never from `~/.claude` or a separate
warehouse.**

Judge 2 proved the two-copy designs (B's `skills/` warehouse + `.claude/skills/` deployed;
D's `tooling/rhi-plugin/` + vendored copy) re-create the audit's two-location drift bug
*inside one repo*, with a divergence window on every edit — github-io's harness can load
a stale copy of a skill it is simultaneously distributing fresh. A and C dodge this by
making the load path itself canonical. We adopt that collapse.

Note this *departs from Judge 3's minimal proposal*, which kept `tooling/claude-commands/`
as the authoring/superset source plus a committed `.claude/commands/` copy in github-io —
that is two copies in one repo, the exact drift surface Judge 2 condemns and the audit
caught live. We take Judge 3's *substrate and sequencing* (flat `.md`, no format
migration) but Judge 2's *single-source collapse*. Concretely: github-io's
`tooling/claude-commands/` is retired by `git mv`-ing its committed contents into
github-io's `.claude/commands/`, which then becomes the one canonical home.

### Resolution 3 — Format: stay on `.claude/commands/`; fence `.skills/` for later

**Decision: keep flat `.claude/commands/<name>.md` for this correctness fix. Record the
`.claude/commands/ → .claude/skills/<name>/SKILL.md` directory-format migration as a
SEPARATE, FENCED, optional later step.**

All three judges agree: `.claude/commands/` is legacy-but-fully-supported, loads on fresh
clone, and satisfies R1–R4 unchanged. The format migration is orthogonal — it requires a
per-skill content transformation (front-matter wrapper), per-skill load verification, and
legacy deletion across every repo, all at once. Under the ecosystem's own dirty-repo-skip
rule, a one-pass sweep *guarantees* a mixed `commands/`+`skills/` ecosystem the moment any
receiver is dirty, with the new tooling blind to the un-migrated repos — precisely the
"finish migrations before building on top / fence what you can't finish" failure.

**Fenced follow-up (recorded so it is not lost):** *After R1–R4 land and stabilize,
migrate `.claude/commands/<name>.md` → `.claude/skills/<name>/SKILL.md` (directory per
skill, uniform shape for single- and multi-file skills) as its own commit-per-repo
ecosystem refactor, load-testing each converted skill before deleting the legacy file,
deferring dirty repos to their TODO.md.* This is logged as an open follow-up in github-io's
TODO.md at the end of the migration. The end-state architecture to converge toward is A's
(one directory, no layers); this fix is fully forward-compatible with it.

### Resolution 4 — Manifest: flat repo list, NO per-skill subsetting (call made from evidence)

**Decision: a single flat `tooling/skill-repos.txt` (recipient repos) plus a single
common skill set. NO per-skill→repo mapping. Justified from the audit's per-repo table.**

The audit §4 table is the evidence. Every receiver today carries *exactly the same three
skills* — `design-it-twice`, `handoff`, `polish` — with zero variation across repos or
orgs. The five "stranded" skills reach *no* receiver at all. So the live state has **one
common set and zero subsetting**. The candidates that introduced subsetting (B's `sets`,
C's `rhizone/*` globs) were inventing an N×M distribution problem that does not exist at
the observed scale (8 repos, one uniform set) — exactly Judge 3's over-build finding.

There is one *forward* question the evidence raises: are the design/architecture skills
(`design-an-interface`, `domain-model`, `improve-codebase-architecture`,
`survey-open-threads`, `think-with-the-engineering-taste`) intended for *all* repos or only
developer-substrate (rhi-zone) repos? Candidates B and C *assumed* the latter
(`rhizone/*`). But that is an assumption, not observed policy — and even if true, it is a
**one-time seeding decision**, not a standing distribution requirement. Encoding it as a
per-skill mapping pays permanent complexity for a transient choice.

**Resolution: keep one flat recipient list + one common skill set. Express any seeding
subset as a one-time manual seed (§Resolution 6e), not as standing manifest structure.**
If genuine, durable per-repo divergence ever emerges, the minimal escalation is a flat
`tooling/skills.manifest` of `repo: skill skill skill` lines (still plain-text, zero-dep,
one grep) — but we do **not** add it now; YAGNI at N=8 with a uniform observed set. This is
the one place a defensible alternative exists; see §Open choice.

### Resolution 5 — Sync tool contract: convergent but safe (graft C, heed Judge 2/3)

**Decision: `tooling/sync-skills.sh` is idempotent and convergent with a non-destructive
default, a `--check` drift mode, and a hard dirty-receiver skip. NO `rsync --delete` as
default; NO `rm -rf` before the dirty check.**

Contract:

```
sync-skills.sh [--check] [--prune] [--no-push]
```

- **Source = github-io's committed `.claude/commands/`.** Never `~/.claude`, never a
  warehouse. The set of skills to distribute = the files committed there (git-tracked
  only; an untracked file in that dir is NOT distributed — closes the
  `think-with-the-engineering-taste` "on disk not in git" class at the source).
- **Targets = `tooling/skill-repos.txt`** (`grep -v '^[#[:space:]]*$'`). A listed repo
  not cloned on this machine is reported and skipped (no hard abort) — closes Judge 2's
  "manifest references non-existent repo" gap that the old `find` could not hit.
- **Convergence, safely (per repo):**
  1. **Dirty check FIRST.** `git -C "$repo" status --porcelain`; if non-empty, **skip the
     entire repo**, log it, and emit the TODO.md line for that repo. No filesystem
     mutation, no commit, no `rm` on a dirty tree. (Fixes Judge 2's "A commits on top of a
     dirty tree" and Judge 3's "`rm -rf` before the dirty guard" — the guard is the first
     thing that runs.)
  2. On a clean repo: copy each canonical skill file into `<repo>/.claude/commands/`
     (overwrite if drifted, create if missing). Additive + update.
  3. **Orphan handling is explicit and safe.** A skill present in the receiver's
     `.claude/commands/` but absent from the canonical set is **reported by default and
     removed only under `--prune`.** Default sync never deletes a committed file the
     operator didn't ask to remove (heeds Judge 2's "retire loop" need and Judge 3's
     destructive-default warning simultaneously: convergence on removal is *available and
     one flag away*, but not the silent default).
  4. If and only if the tree changed: `git add .claude/commands` (+ `.normalize/`,
     `.gitignore` for parity with today's script — retained, not dropped, closing Judge 2's
     `normalize init` regression), commit with a generated conventional message, run
     `normalize init` if still in the loop, push **only if the tree is otherwise clean**.
- **Idempotent:** a second run on a converged ecosystem detects no diff, writes nothing,
  commits nothing.
- **`--check`:** dry-run of the convergence computation, reports three drift classes
  distinctly — **stale** (receiver copy differs from canonical), **missing**
  (canonical skill absent in a receiver), **orphan** (receiver skill not in canonical) —
  and exits non-zero on any. Suitable for a CI/`/loop` guard in github-io. (C's
  taxonomy, adopted.)
- **Pure POSIX `cp`/`diff`, no `rsync`** (NixOS per-flake: `rsync` is not guaranteed;
  Judge 2/3 flagged it). The convergence is a per-file `diff`-then-`cp`; `--prune` is an
  explicit `git rm` of reported orphans.
- **No `~/.claude` read or write, ever.** Works on a fresh github-io clone with zero user
  setup.

### Resolution 6 — Migration sequence (ordered, completable in one pass)

All steps (a)–(d) and (f) happen **in github-io, which must be clean before starting**
(`git status` shows only the known untracked artifacts; commit or stash unrelated work
first). Step (e) touches receiver repos and respects the dirty-skip rule.

**(a) Version the unversioned skills into github-io's canonical `.claude/commands/`.**
   - `handoff.md`: real file in `~/.claude/commands/`, no versioned backing anywhere.
     Copy its current bytes to `github-io/.claude/commands/handoff.md`.
   - `polish.md`: committed in `tooling/claude-commands/polish.md` but the *loaded* copy
     is a real file in `~/.claude/commands/`. Use the `tooling/` committed bytes (verify
     they match the live file first; if they differ, the live file is the truth — capture
     it). Place at `github-io/.claude/commands/polish.md`.
   - `think-with-the-engineering-taste.md`: untracked real file in *both*
     `tooling/claude-commands/` and `.claude/commands/`. Capture the live bytes to
     `github-io/.claude/commands/think-with-the-engineering-taste.md`.

**(b) Collapse `tooling/claude-commands/` → github-io's `.claude/commands/` and commit.**
   `git mv` (or copy + remove) every committed file from `tooling/claude-commands/` into
   `github-io/.claude/commands/`:
   `design-it-twice.md`, `survey-open-threads.md`, and the directory-shaped
   `design-an-interface/`, `domain-model/`, `improve-codebase-architecture/` (these stay
   directories — `.claude/commands/` tolerates them; the flat-vs-dir mix is exactly what
   the *fenced* §Resolution 3 migration will later normalize, and is harmless now).
   `git add` the new `.claude/commands/` tree, remove the now-empty
   `tooling/claude-commands/`, commit. github-io's `.claude/commands/` is now the single
   committed canonical home, loaded by github-io's own harness — self-containment closed
   for the hub. *(`.gitignore` has no `.claude` entry per audit §6, so the dir tracks
   cleanly once added.)*

**(c) Remove all `~/.claude` skill entries.** Delete the two real files
   (`~/.claude/commands/handoff.md`, `~/.claude/commands/polish.md`) and all six symlinks
   (`design-an-interface`, `design-it-twice.md`, `domain-model`,
   `improve-codebase-architecture`, `survey-open-threads.md`,
   `think-with-the-engineering-taste.md`). After this, `~/.claude/commands/` for ecosystem
   skills is empty. github-io continues to load its skills from its own committed
   `.claude/commands/` at project scope — verify by launching from the github-io root and
   confirming the skills list (validate-against-reality; Judge 1's removal must be checked,
   not asserted).

**(d) Rewrite `propagate-skill.sh` → `tooling/sync-skills.sh`.** Per §Resolution 5: source
   = committed `.claude/commands/`, targets = `tooling/skill-repos.txt`, dirty-skip first,
   non-destructive default with `--prune`/`--check`, no `~/.claude`, no `rsync`. Create
   `tooling/skill-repos.txt` listing the receiver repos (the 7 in audit §4 plus any others
   the `find` rule currently reaches — enumerate them by a one-time `find ~/git -path
   "*/.claude/commands/*" -name design-it-twice.md` to seed the list completely, then it is
   static). Retire `propagate-skill.sh` (delete it — retire, don't deprecate). Commit.

**(e) Seed the 5 stranded skills to their target repos.** `survey-open-threads`,
   `think-with-the-engineering-taste`, `design-an-interface`, `domain-model`,
   `improve-codebase-architecture` now live committed in github-io's canonical dir.
   Decide their recipient scope (see §Open choice; recommended: developer-substrate
   rhi-zone repos for the design/architecture trio, all repos for the two cross-cutting
   ones — but this is a one-time seed, not standing structure). Run `sync-skills.sh`.
   - **Clean receivers** get the skills committed and pushed automatically.
   - **Dirty receivers are skipped** and an entry is added to *that repo's* TODO.md
     (per the ecosystem-refactor rule: clean repos changed directly, dirty repos deferred
     to their own TODO.md). This is where the migration is *not* one-pass for the whole
     ecosystem — and that is correct and safe: the github-io-side fix (a–d, f) IS one-pass
     and complete; receiver seeding is convergent and re-runnable, so deferred dirty repos
     simply get picked up on the next clean run. The fix never strands github-io itself.

**(f) Correct CLAUDE.md.** Replace the "Canonical skill location:
   `tooling/claude-commands/` … Symlink from `~/.claude/commands/`" block and the "Updates
   `~/.claude/commands/<skill-file>` first" line with the true mechanism: canonical =
   github-io's committed `.claude/commands/`; registry = `tooling/skill-repos.txt`;
   propagation = `tooling/sync-skills.sh` (idempotent, convergent, `--check`/`--prune`,
   dirty-skip); every repo including github-io loads from committed `.claude/commands/*.md`;
   **`~/.claude` skill entries are forbidden** (global, shadow every repo). Update the
   propagation command reference in the Responsibilities section. Add the fenced
   `.commands → .skills/SKILL.md` follow-up to github-io's TODO.md so §Resolution 3 is not
   lost. Commit.

**Clean vs dirty split, stated plainly:**
- **Must be done in github-io (clean):** (a), (b), (c), (d), (f) — all github-io-local,
  one pass, fully completable and reversible at each commit.
- **Receiver repos (may be dirty, deferred safely):** (e) only. Clean receivers are synced
  directly; dirty receivers get a TODO.md line and are picked up by the next convergent
  re-run. No receiver is left half-migrated, because the substrate (`.claude/commands/`,
  flat `.md`) is unchanged from what receivers already use — seeding only *adds* skill
  files, it does not transform existing ones.

---

## 3. The one open choice for the user

**Recipient scope of the 5 currently-stranded skills (a one-time seeding decision, §6e).**

The audit shows zero current subsetting (every receiver has the same baseline three), so
the *mechanism* needs no per-skill mapping — a flat repo list is correct (§Resolution 4).
But seeding the five stranded skills forces one policy call:

- **Option 1 (recommended): cross-cutting two → all repos; design/architecture three →
  rhi-zone (developer-substrate) repos only.** `handoff`/`polish`/`design-it-twice` are
  already everywhere; add `survey-open-threads` and `think-with-the-engineering-taste`
  everywhere (they are general ecosystem-hygiene skills); add `design-an-interface`,
  `domain-model`, `improve-codebase-architecture` to rhi-zone repos, matching B's/C's
  assumption that these are developer-substrate tooling. Rationale: aligns skill reach with
  the rhi-zone/exo-place purpose discriminator in CLAUDE.md.
- **Option 2: all five → all repos.** Simpler, maximal availability; costs nothing
  mechanically (flat list, common set). Defensible if you want every repo to have the full
  design toolkit.

**Recommendation: Option 1**, executed as a one-time seed (manually choose which repos
each skill goes to on the first `sync-skills.sh` run), with the standing mechanism staying
a flat common-set list. If durable per-repo divergence later proves real, escalate to the
minimal `tooling/skills.manifest` (`repo: skill...` lines, zero-dep) — but not now.

Everything else in this design is a settled call backed by the judges' findings.
