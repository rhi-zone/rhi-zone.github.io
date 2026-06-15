# Candidate B — Explicit Registry + Manifest (Invert the Dependency)

Design-it-twice candidate. Framing: **make ownership and distribution explicit.** One
repo holds the canonical, versioned skill set; a declarative manifest states which repos
subscribe to which skills; propagation is an explicit push driven by the manifest. The
hub repo is itself an ordinary receiver of its own skills — not special.

---

## (a) The Design

Three primitives replace today's implicit, machine-coupled mechanism:

1. **Canonical dir** — the single source of truth. Every skill lives, versioned, in
   exactly one place: `skills/` in github-io. This is *not* `~/.claude/commands/` and
   *not* a symlink target relied on at runtime. It is plain committed files. Nothing
   reads from `~/.claude` to find canonical bytes, ever.

2. **Manifest** — `skills/manifest.toml`, committed. A declarative table of
   `skill → subscribing repos`. This **replaces find-by-presence**. Distribution is
   stated, not discovered. A brand-new skill is propagated the instant it is named in the
   manifest; there is no chicken-and-egg seeding problem because subscription is an
   assertion, not an inferred fact about what files already exist.

3. **Sync tool** — `tooling/sync-skills.sh`. Reads the canonical dir + manifest, and for
   each `(skill, repo)` pair the manifest declares, copies the skill into that repo's
   committed `.claude/skills/<name>/SKILL.md`, commits, and pushes if clean. **It reads
   only from the canonical dir.** `~/.claude` is never an input.

The dependency is inverted relative to today. Today: the world (existing receiver files)
tells the propagator where to push (find-by-presence), and the propagator reads bytes
from a machine-local path. Candidate B: a versioned manifest declares the world, and the
propagator reads bytes from a versioned dir. Both axes (what-to-push, what-bytes) move
from machine-local/implicit to in-repo/explicit.

### github-io is a receiver of its own skills

This is the load-bearing move for self-containment. github-io appears in the manifest's
subscriber lists exactly like any other repo. The sync tool, when it processes a skill
subscribed by github-io, writes `github-io/.claude/skills/<name>/SKILL.md` and **commits
it**. So:

- Canonical bytes live in `skills/` (authoring/distribution source).
- github-io's *runtime* skills live in `.claude/skills/` — committed, loaded on fresh
  clone, identical mechanism to every receiver.

`skills/` and `.claude/skills/` are two different roles that happen to coexist in one
repo. `skills/` is the distribution warehouse; `.claude/skills/` is github-io's own
deployed copy. The sync tool is what keeps them consistent — github-io eats its own
dog food by running the same push against itself.

---

## (b) Concrete Realization

### Canonical dir layout

```
skills/
  manifest.toml
  design-it-twice/SKILL.md
  design-an-interface/SKILL.md
  domain-model/SKILL.md
  improve-codebase-architecture/
    SKILL.md
    DEEPENING.md
    INTERFACE-DESIGN.md
    LANGUAGE.md
  survey-open-threads/SKILL.md
  think-with-the-engineering-taste/SKILL.md
  polish/SKILL.md
  handoff/SKILL.md
```

Every skill is a **directory with a `SKILL.md`** (plus any auxiliary files), even ones
that are a single file today. This normalizes single-file (`polish.md`) and multi-file
(`improve-codebase-architecture/`) skills into one shape — the sync tool copies a
directory tree, never special-cases a bare `.md`. (`tooling/claude-commands/` is retired;
`skills/` supersedes it.)

### Manifest format — `skills/manifest.toml`

```toml
# Canonical skill registry + subscription manifest.
# Source of truth for WHICH repos get WHICH skills.
# The sync tool reads ONLY this file + the skills/ dir. Never ~/.claude.

# Named subscription sets, so common bundles aren't repeated per-repo.
[sets]
baseline = ["design-it-twice", "handoff", "polish"]
design   = ["design-it-twice", "design-an-interface", "domain-model",
            "improve-codebase-architecture", "think-with-the-engineering-taste"]

[repos]
# repo path is relative to ~/git ; "skills" is sets ∪ explicit skill names.
"rhizone/github-io"      = { sets = ["baseline", "design"], skills = ["survey-open-threads"] }
"rhizone/normalize"      = { sets = ["baseline", "design"] }
"rhizone/concord"        = { sets = ["baseline"] }
"rhizone/crescent"       = { sets = ["baseline"] }
"rhizone/moonlet"        = { sets = ["baseline"] }
"exoplace/aspect"        = { sets = ["baseline"] }
"exoplace/noncanon"      = { sets = ["baseline"] }
"paragarden/existence"   = { sets = ["baseline"] }
```

The effective skill set for a repo = union of its sets' members and its explicit `skills`.
Sets keep the manifest from degenerating into N×M repetition while leaving every
subscription auditable in one file. github-io is just another row — subscribing to
`baseline`, `design`, and `survey-open-threads`.

### What the sync tool does — `tooling/sync-skills.sh` contract

```
sync-skills.sh [--repo <path>] [--skill <name>] [--check] [--no-push]
```

1. Parse `skills/manifest.toml`. Validate: every referenced skill name has a directory
   under `skills/`; every set member exists; fail loudly on a dangling reference. (This
   is the guard that makes "name it in the manifest" safe.)
2. Compute the per-repo target set (sets ∪ explicit).
3. For each `(repo, skill)`: ensure `<repo>/.claude/skills/<skill>/` matches
   `skills/<skill>/` byte-for-byte; copy if absent or drifted. Bytes always come from the
   canonical dir.
4. Detect **orphans**: a `<repo>/.claude/skills/<name>/` with no manifest subscription →
   reported (and removed under `--prune`, off by default). This catches drift the
   find-by-presence rule could never see.
5. Stage `.claude/skills/`, run `normalize init` (parity with current flow), commit with a
   generated conventional message, push if the tree is clean; if dirty, print the TODO
   line for that repo and skip (matches the existing dirty-repo rule).
6. `--check` does steps 1–4 read-only and exits non-zero on any drift/orphan/dangling —
   suitable for CI in github-io.

Key contract guarantees:
- **Idempotent.** Re-running with no canonical changes is a no-op (no spurious commits).
- **Canonical-only input.** `~/.claude` is never read or written. The tool works on a
  fresh clone of github-io with zero user setup.
- **New skills are first-class.** Adding `skills/foo/SKILL.md` + a manifest line is the
  entire seeding procedure. No prior receiver file required.

### Fresh-clone load behavior

Per harness facts: a committed project-level `.claude/skills/<name>/SKILL.md` loads on
fresh clone with no user setup. So:

- **Any receiver repo** (incl. github-io): `git clone` → `.claude/skills/*/SKILL.md` are
  present and committed → skills load. Zero `~/.claude` dependency. github-io is now
  symmetric with receivers — the asymmetry the audit flagged is gone.
- The harness precedence (personal `~/.claude` OVER project `.claude/`) means a developer
  *may* still shadow a committed skill with a personal symlink for live authoring. That is
  an opt-in personal override, not a requirement — see (e).

---

## (c) What It Hides / Assumes

- **Assumes the manifest is maintained.** Explicitness has a cost: a new skill or new repo
  that isn't added to the manifest simply isn't distributed. This is strictly better than
  silent find-by-presence stranding (the failure is now a visible missing line, and
  `--check` in CI catches a skill dir with no subscribers), but it is still a human step.
- **Hides per-repo divergence behind sets.** If one repo needs a one-off skill, it goes in
  `skills = [...]`; the set abstraction is only a convenience and can be bypassed. The
  manifest stays the full truth either way.
- **Assumes byte-identical distribution is desired.** No per-repo skill customization; a
  skill is the same everywhere it's subscribed. If a repo ever needs a *variant*, that's a
  new skill name, not an in-place edit (which the tool would revert as drift). This is a
  deliberate constraint, not an oversight.
- **Assumes `~/git/<org>/<repo>` layout** for resolving manifest repo paths (already
  assumed by today's `find ~/git` rule, so no new assumption).

---

## (d) Honest Trade-offs

**Wins**
- Self-containment achieved uniformly, github-io included. No repo depends on `~/.claude`
  for skills to load.
- Single versioned source of truth (`skills/`), single versioned distribution policy
  (`manifest.toml`). Both diffable, reviewable, replayable.
- New-skill stranding is structurally impossible: subscription is declared, not inferred.
- Drift and orphan detection (`--check`) give CI-enforceable correctness — the current
  mechanism has no such notion.
- Distribution becomes auditable: "who has skill X?" is a grep of one file, not a
  filesystem crawl.

**Costs**
- More machinery than today: a TOML parser dependency in the sync tool (or a constrained
  hand-parse), set-expansion logic, drift comparison. Heavier than the ~20-line `find | cp`
  loop.
- The manifest is a second thing to keep in sync with reality (skills dir + repo set). The
  `--check` guard mitigates but doesn't eliminate the maintenance surface.
- Migration is a one-time non-trivial reshape (move to `skills/`, normalize to directory
  form, write the manifest, backfill committed copies everywhere). See (f).
- Two roles in one repo (`skills/` warehouse vs `.claude/skills/` deployed copy) is a
  subtlety a reader must internalize — though it's exactly what makes github-io non-special.

---

## (e) The Symlink Layer

The audit's core hazard: harness precedence is personal (`~/.claude`) **over** project
(`.claude/`), so a `~/.claude/commands/<x>` symlink *shadows* the committed project copy.
Today the symlinks are load-bearing — github-io's skills only load *because* of them.

Candidate B demotes the symlink layer to **optional authoring convenience**:

- Runtime correctness depends solely on committed `.claude/skills/`. Remove every
  `~/.claude` symlink and a fresh clone still loads all skills. The symlink is no longer
  load-bearing for *loading*.
- For an author iterating on a skill, a personal symlink
  `~/.claude/skills/<name> → ~/git/rhizone/github-io/skills/<name>` lets edits take effect
  live (shadowing the committed deployed copy via precedence) without a sync round-trip.
  This is explicitly a per-developer, machine-local affordance — documented as optional,
  never required, never the source the tool reads.
- An optional helper `tooling/link-skills.sh` can create these symlinks **into `skills/`**
  (the canonical dir) for whoever wants live authoring. It is a developer ergonomics tool,
  disjoint from the distribution path. The sync tool ignores `~/.claude` entirely.

So the precedence rule is turned from a hazard into an opt-in feature: shadowing is how an
author previews uncommitted canonical edits, and because the tool never reads `~/.claude`,
the shadow can never silently become the propagated truth.

---

## (f) Migration

**Stranded skills** (`survey-open-threads`, `think-with-the-engineering-taste`,
`design-an-interface`, `domain-model`, `improve-codebase-architecture` — never reached any
receiver):
- They already (mostly) live in `tooling/claude-commands/`. Move/normalize each into
  `skills/<name>/SKILL.md`, committing `think-with-the-engineering-taste` which was an
  untracked real file (audit §2) — fixing the "exists only on this machine" gap.
- Add them to manifest sets (`design` bundle above) / repo rows as policy dictates.
- Run `sync-skills.sh`. Because subscription is declared, they propagate immediately to
  every subscribing repo — no pre-existing receiver file needed. Stranding resolved by
  construction.

**Unversioned skills** (`handoff.md`, `polish.md` — real files in `~/.claude/commands/`,
not backed by the canonical dir per audit §3):
- Capture the current bytes from `~/.claude/commands/handoff.md` and `.../polish.md` into
  `skills/handoff/SKILL.md` and `skills/polish/SKILL.md`, and **commit them**. This is the
  one and only time `~/.claude` is read — a manual one-shot rescue during migration, not
  part of the tool's contract.
- They're already in receiver `.claude/commands/` widely (audit §4); add them to the
  `baseline` set so the manifest reflects reality, then sync (which will also migrate those
  receivers from legacy `.claude/commands/<name>.md` to modern `.claude/skills/<name>/`).

**github-io's own deployed copy:**
- Add github-io to the manifest, run sync, commit `github-io/.claude/skills/*`. This is the
  step that closes the audit's central asymmetry: github-io now loads from committed
  in-repo files like everyone else.

**Retire** `tooling/claude-commands/`, `propagate-skill.sh`, and the find-by-presence rule
once `skills/` + `sync-skills.sh` are in place — per the ecosystem "retire, don't
deprecate" principle. Update CLAUDE.md to point at `skills/manifest.toml` as canonical.

### `.claude/skills/` vs `.claude/commands/` — the call

Distribute as **`.claude/skills/<name>/SKILL.md`** (modern canonical), not
`.claude/commands/<name>.md` (legacy-supported). Justification: both load on fresh clone,
but skills is where commands were *merged into* — it's the forward-compatible target, it
uniformly handles single- and multi-file skills as directories (matching the canonical dir
shape), and it lets us retire the legacy form rather than carry it. Receivers currently on
`.claude/commands/*.md` get migrated to `.claude/skills/` by the sync tool and the old
files pruned. One shape, end to end: `skills/<name>/` (canonical) →
`.claude/skills/<name>/` (deployed) everywhere.
