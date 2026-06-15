# Judge 3 — Migration Cost, Blast Radius & Over-Engineering

Adversarial lens: *is this change worth it, and is it bigger than it needs to be?*
Attack vectors: (1) the `.commands → .skills` format migration as scope creep,
(2) manifest over-engineering, (3) collateral loss from killing
`tooling/claude-commands/`, (4) one-pass completability vs strand-the-ecosystem risk.

The four requirements, reconstructed from the brief and the candidates:

- **R1 — self-containment / fresh-clone load.** Every repo, github-io included,
  loads skills from committed in-repo files; a fresh clone works with zero
  `~/.claude` setup.
- **R2 — no unversioned skills.** `handoff` and `polish` (real files in
  `~/.claude/commands/`) and the untracked `think-with-the-engineering-taste`
  gain a versioned home.
- **R3 — new skills propagate.** Kill find-by-presence; the 5 stranded skills
  reach the repos they should.
- **R4 — docs match reality.** CLAUDE.md / the `tooling/claude-commands/`
  "canonical" prose / the script source-of-truth conflict get reconciled.

**The governing fact for this lens (mechanism.md):** `.claude/commands/<name>.md`
is *legacy-but-fully-supported*. The harness loads it on a fresh clone. Nothing
in R1–R4 requires abandoning it. R1 needs *committed in-repo files*; R2 needs a
*versioned home*; R3 needs *a push that isn't gated on prior presence*; R4 needs
*honest prose*. None of those four says "directory-per-skill" or "SKILL.md." That
is the crack every candidate widens into a full-format migration — and it is the
single biggest unforced blast-radius increase in the whole exercise.

---

## The shared scope-creep finding (applies to A, B, C, D)

All four candidates bundle the `.commands → .skills` format migration into the
fix. Three of them (A, B, C) also delete `tooling/claude-commands/`. Let me cost
it before judging individuals, because it is the same cost in each.

**Blast radius of the format migration:** every ecosystem repo (8+ confirmed in
mechanism §4: github-io, normalize, concord, crescent, moonlet, aspect, noncanon,
existence — and the find rule means there are likely more), every skill in each,
all at once. Each receiver today holds `design-it-twice.md`, `handoff.md`,
`polish.md` as committed `.claude/commands/*.md`. The migration `git mv`s each to
`.claude/skills/<name>/SKILL.md`, *and* requires a front-matter wrapper
conversion (C §c, D §f step 2 both admit "adding modern front-matter" — a
content transformation, not a rename), *and* requires load-verification per
skill (C §f step 4, C §d "verified by load-testing"), *and* deletes the legacy
files. That is N_repos × M_skills file moves + format conversions + per-skill
load tests, in one sweep, touching every repo's `.claude/` tree.

**Is it necessary for R1–R4?** No. A committed `.claude/commands/handoff.md` is
a committed in-repo file (R1 ✓), is versioned (R2 ✓), loads on fresh clone (R1 ✓,
per the legacy-supported fact). Find-by-presence (R3) is a property of the
*propagator's discovery rule*, totally independent of file format — you fix R3 by
changing how the script decides where to push, not by changing the file
extension. R4 is prose.

**So the entire format migration is orthogonal to all four requirements.** It is
a *separate, legitimate, lower-priority* improvement (forward-compat, uniform
directory shape) that every candidate has welded onto the critical-path fix. The
"retire-don't-deprecate" principle is invoked (C, B) to justify it — but that
principle says retire *when you remove the thing*, not *bundle an unrelated
retirement into an urgent correctness fix*. The competing principle —
**"finish migrations before building on top; fence what you can't finish"** —
cuts the other way and is the more relevant one here: a format migration that
strands halfway (some repos on `commands/`, some on `skills/`) is exactly the
"old patterns dominate by count, get read as canonical, copied forward" failure
that principle warns about.

**The partial-migration failure is concrete and severe.** If the one-pass sweep
fails partway — a dirty repo (mechanism's own dirty-repo rule means dirty repos
get *skipped* with a TODO, not migrated), a skill that doesn't load after
conversion, an interrupted run — the ecosystem is left with: some repos on
`.claude/skills/`, some on `.claude/commands/`, the propagator now keyed to one
form, and the other form silently not-updated. Every candidate's sync tool
operates on `.claude/skills/`; a skipped-dirty repo still on `.claude/commands/`
is now invisible to the new tool *and* abandoned by the old one. This is a strict
regression in blast-radius safety versus a fix that stays on `commands/`.

**Verdict on the format migration (answer (a) up front): NOT worth bundling.**
It is real scope creep relative to R1–R4. The honest sequencing is: fix R1–R4 on
the existing `.claude/commands/` substrate first (small, completable, reversible),
*then* run the format migration as its own fenced, separately-committable
ecosystem refactor if desired. None of the four candidates proposes that
sequencing; all four take the big-bang. That is the finding that wounds every
candidate.

---

## Candidate A — Subtract / Minimize Indirection

**Attacks that land:**

1. **Format migration is scope creep (HIGH).** A §f migrates every receiver from
   `.claude/commands/*.md` to `.claude/skills/<name>/SKILL.md` and deletes
   `tooling/claude-commands/`. As established above, none of R1–R4 needs this. A
   *claims* it's a subtraction ("subtract that future work now," §a) but it is
   the opposite: it adds a full-ecosystem format sweep to a fix that didn't
   require touching file formats at all. The "future second migration" it claims
   to avoid is hypothetical (legacy is *fully* supported, no deprecation date
   given); the migration it performs is real and now. Net add, not subtract.

2. **Kills `tooling/claude-commands/` and loses the live-authoring loop (MEDIUM).**
   A §e removes the symlink layer "entirely" and §f deletes `tooling/`. But the
   symlink-into-`tooling/` topology (mechanism §3: six of eight entries) is the
   mechanism by which **editing a skill in the versioned dir is immediately live
   in the running harness** — you edit one file, the symlink makes it live, no
   copy step. A's replacement: "edit the file in github-io's `.claude/skills/`
   directly; that edit is already the source" (§b). That *does* preserve live
   authoring **for github-io itself** (since github-io now loads its own
   `.claude/skills/`), so A actually keeps the live loop — credit where due. But
   it loses it for *receivers*: to iterate on a skill and test it in a receiver
   repo's context, you now edit-in-hub, run sync, commit in receiver. A admits
   this only obliquely. The loss is partial, not total. Severity MEDIUM because
   the dominant author-loop (in the hub) survives.

3. **The manifest is under-specified and A knows it (LOW-MEDIUM).** A introduces
   `.claude/skills.manifest` per receiver with `*`-means-all, then admits "the
   hub's superset status is convention, not enforced" and "drift detection is out
   of band." For the minimal lens this is fine — but A simultaneously *adds* a
   per-repo manifest file (new artifact, R3 fix) while *claiming* maximum
   subtraction. A cheaper R3 fix exists (below) that adds zero per-repo files.

4. **`rm -rf "$repo/.claude/skills/$name"` in the sync loop (MEDIUM, safety).**
   A §b's sync does `rm -rf` then `cp -R` per skill, unconditionally, before any
   dirty check. If the manifest or `$name` is malformed, this is a destructive
   operation across every repo. The dirty-repo guard runs *after* the filesystem
   mutation. Real foot-gun for a "minimal" design.

**Smallest honest blast radius?** A is *not* the smallest despite the framing,
because it still does the full format migration + deletes `tooling/`. Its
genuine subtraction (collapsing the canonical/symlink layers) is good and is the
right *end state*; but as a *migration* it is big-bang like the others.

**Survives?** **WOUNDED.** The end-state architecture is the cleanest of the
four and A's core insight (the layers are the disease) is correct. But it
conflates a clean end-state with a safe migration, bundles the format sweep it
didn't need, and has a destructive sync loop. Worst vulnerability: **the
unnecessary full-ecosystem format migration dressed as a subtraction.**

---

## Candidate B — Explicit Registry + Manifest (TOML)

**Attacks that land:**

1. **The TOML manifest is over-engineered for the problem (HIGH).** This is B's
   defining vulnerability and the answer to question (b). R3 — "new skills
   propagate" — is a defect in *one discovery rule* in *one script* on *one
   machine* (the operator's; mechanism §1: the propagator only ever runs from
   github-io on this machine). The find-by-presence bug is fixed by replacing
   `find ... -path "*/.claude/commands/*"` with *an explicit list of target
   repos*. That is a one-line change: `for repo in $(cat tooling/skill-repos.txt)`.
   B instead introduces: a TOML file, a TOML *parser dependency* in a bash script
   (B §d admits "a TOML parser dependency... or a constrained hand-parse"),
   named reusable subscription *sets* with set-union semantics, per-`(skill,repo)`
   subscription tuples, set-expansion logic, orphan detection, `--prune`,
   `--check` CI mode. B §d's own cost list is an indictment: "More machinery than
   today... Heavier than the ~20-line find|cp loop." For a single-operator,
   ~8-repo ecosystem where the operator *is* the one editing the manifest and
   *is* the one running the sync, the `sets` abstraction (designed to avoid
   "N×M repetition") is solving a scale problem that does not exist at N=8, M=8.

2. **TOML parser dependency in a NixOS bash-script context (MEDIUM).** Per the
   environment rules, tools are per-project via nix flakes; you cannot assume a
   TOML parser is present. B's sync now needs a flake dependency (a TOML CLI, or
   Python+tomllib, etc.) where today's mechanism is pure POSIX `find`/`awk`/`cp`.
   The "constrained hand-parse" fallback means hand-rolling a TOML subset parser
   in bash — more code than the thing it replaces. Either branch adds real
   surface for a problem an explicit newline-delimited repo list solves with
   `grep -v '^#'`.

3. **Format migration + `tooling/claude-commands/` deletion (HIGH).** Same as A —
   B §f retires `tooling/claude-commands/`, migrates every receiver
   `.claude/commands/*.md` → `.claude/skills/`, prunes legacy. Same scope creep,
   same partial-migration strand risk. B does *not* fence it; it's one big sync.

4. **Two roles in one repo is a documented subtlety, i.e. a comprehension tax
   (LOW).** B §a/§d: `skills/` (warehouse) vs `.claude/skills/` (github-io's
   deployed copy), kept consistent by github-io running sync *against itself*.
   This is cleverer than A's "one dir, two roles" and arguably more honest, but
   it means github-io carries the same bytes twice (warehouse + deployed) — a
   self-imposed intra-repo duplication that A avoids by making `.claude/skills/`
   serve both roles. B added a layer back that A removed.

**Survives?** **WOUNDED, closest to BROKEN on the over-engineering axis.** B is
the most thoroughly specified candidate and its `--check`/orphan/drift story is
genuinely the best correctness tooling of the four. But it is the clearest case
of building a declarative-manifest cathedral where an explicit repo-list shed
meets every requirement. Worst vulnerability: **the TOML manifest + sets + parser
dependency is disproportionate machinery for a one-line discovery-rule fix.**

---

## Candidate C — Modern-Format, Idempotent-Sync

**Attacks that land:**

1. **Manifest globs depend on parsing `docs/about.md` (HIGH, brittleness).** C's
   manifest uses `*` and `rhizone/*` globs "resolved against `docs/about.md`'s
   project list" (§b). This couples the propagator to the parseability of a
   human-authored Markdown prose/table file. C §c admits the assumption: "if it
   isn't [machine-parseable], the manifest needs its own explicit repo list." So
   the fallback for C's clever glob is... the explicit list that B and D use
   directly and that fixes R3 by itself. The glob adds a parse-`about.md`
   dependency to save typing 8 repo names. Net negative.

2. **`rsync --delete` semantics across every repo (MEDIUM-HIGH, blast radius).**
   C §b step 3 uses `rsync --delete`-equivalent into `<repo>/.claude/skills/<name>/`
   *and* step 4 *removes whole skill dirs not in the repo's target set*. This is
   the most aggressively convergent/destructive sync of the four. Combined with
   the big-bang format migration (step 1–3 of §f), a single wrong manifest line
   or a glob that mis-resolves against `about.md` deletes committed skill content
   across the ecosystem. C does have `--check` to dry-run, which mitigates — but
   the default path is full delete-convergence.

3. **Format migration with front-matter conversion + per-skill load-test
   (HIGH).** C is the most explicit about the *content transformation* cost:
   §c "a former `commands/<name>.md` body can be moved into `SKILL.md` with at
   most a front-matter wrapper," §f step 4 "verify each migrated skill loads from
   a fresh clone... before considering legacy removal final." This is honest, and
   it also proves the migration is bigger than a rename: it's a per-skill,
   per-repo content edit + load test + legacy delete. C accepts this as "the big
   one-time migration cost" (§d). The lens's objection stands: that cost buys
   nothing toward R1–R4 and risks the half-migrated state.

4. **Loses the live-authoring trick — and C says so (MEDIUM).** C §d explicitly:
   "Loses the 'edit the symlinked file and it's instantly live in tooling' trick
   for github-io's own dev loop." Like A, C recovers it for the hub (edit
   `.claude/skills/` directly), so the loss is again *receiver-side* iteration,
   not total. C is the only candidate to name the loss outright — credit.

**Survives?** **WOUNDED.** C's idempotent/convergent sync is the right *steady-
state* design and its drift-class taxonomy (stale/missing/orphan) is excellent.
But it stacks the three biggest blast-radius multipliers — full format migration,
`rsync --delete` convergence, and a glob coupled to `about.md` — on top of each
other, in one pass. Worst vulnerability: **destructive convergent sync driven by
a manifest whose targets are resolved by parsing a prose Markdown file.**

---

## Candidate D — Vendored / Referenced Plugin

**Attacks that land:**

1. **D talks itself out of its own noun (this is a feature for this lens, but
   it's still the worst over-engineering candidate on paper).** D §d is the most
   intellectually honest section in the entire set: "The plugin noun buys almost
   nothing here... we pay the plugin's costs (namespacing, manifest, no-walk-up)
   without getting its benefit." D's recommendation is *don't use the plugin
   unless external distribution is a goal* — which the requirements don't ask
   for. So D, read as a *proposal*, is the most over-engineered (a whole plugin
   manifest + `@skills-dir` mechanics + namespacing for zero requirement-driven
   benefit); read as an *investigation*, it correctly rules itself out. Severity
   depends on how you read it; as a candidate-to-adopt it's HIGH over-engineering.

2. **Forced `rhi:` namespacing is an irreversible ecosystem-wide rename (HIGH,
   migration cost + blast radius).** D §g caveat 2, §c, §d: every invocation
   becomes `/rhi:handoff`, `/rhi:polish`, etc., with no opt-out. This is a
   migration cost *none of the other candidates incur* — it breaks every existing
   muscle-memory invocation and any docs/log referencing bare skill names, across
   the whole ecosystem, permanently. Pure cost, zero requirement served.

3. **`no-walk-up` footgun is a new failure mode (MEDIUM).** D §g caveat 1: a
   subdirectory launch silently misses the plugin. Loose skills/commands walk up
   to repo root; the plugin doesn't. D introduces a *new* way for skills to
   silently not-load, which is the exact class of bug (silent non-loading) the
   audit exists to kill.

4. **Format migration + per-repo full-plugin vendoring (MEDIUM).** D still
   vendors the whole tree into every repo's `.claude/skills/rhi/` and still moves
   everything to `SKILL.md` form (§f). Same big-bang sweep, now wrapped in a
   plugin dir. D §d admits "duplication is unchanged" and the plugin "does not
   deduplicate."

**Survives?** **BROKEN as a proposal; SURVIVES as an analysis.** If treated as a
design to adopt, D is broken: it adds forced namespacing (irreversible rename,
the largest gratuitous migration cost of any candidate) and a new silent-non-load
footgun, for benefits the requirements never request — and D's own §d says so.
Its lasting value is the verified plugin-loader facts (marketplace/`--plugin-dir`
fail R1; only project-scope `@skills-dir` passes). Worst vulnerability: **forced
irreversible `rhi:` namespacing across the whole ecosystem for no
requirement-driven gain.**

---

## Cross-candidate migration-step count (answer to question 4)

Counting actual touch-points for a faithful one-pass execution:

| Candidate | New per-repo artifacts | Format sweep? | Destructive sync default | Irreversible rename | One-pass completable? |
|---|---|---|---|---|---|
| A | `skills.manifest` per repo | Yes (all repos) | `rm -rf` per skill | No | Risky — strands on dirty/skip |
| B | TOML manifest (central) + parser dep | Yes (all repos) | copy-if-drift (+`--prune` off) | No | Risky — most machinery to land at once |
| C | central manifest + about.md coupling | Yes (all repos) | `rsync --delete` + orphan-remove | No | Riskiest — destructive default |
| D | `.claude/skills/rhi/` plugin per repo | Yes (all repos) | `rsync -a --delete` | **Yes (`rhi:`)** | Risky + irreversible rename |

**Every candidate does the full-ecosystem format sweep in one pass**, so every
candidate carries the partial-migration strand risk. None fences it. None is
cleanly completable-in-one-pass under the ecosystem's own dirty-repo rule (dirty
repos get *skipped*, which by construction half-migrates the ecosystem the moment
any repo is dirty — and mechanism shows skills propagate to live working repos
that frequently *are* dirty).

---

## VERDICTS

### (a) Is the `.skills` migration worth it?

**No — not as part of this fix.** R1–R4 are fully satisfiable on the existing,
fully-supported `.claude/commands/` substrate. The format migration is an
orthogonal forward-compat improvement that every candidate welded onto the
critical-path correctness fix, multiplying the blast radius from "fix one script
+ version two files + reconcile prose" to "transform and load-test every skill in
every repo, delete the legacy form, all at once." It also directly courts the
"finish migrations before building on top" failure: the sweep strands the moment
any repo is dirty (the ecosystem's own rule skips dirty repos), leaving a mixed
`commands/`+`skills/` ecosystem with the new tooling blind to the un-migrated
repos. **If the format migration is wanted, sequence it as its own fenced
ecosystem refactor *after* R1–R4 land — do not bundle it.**

### (b) Is the manifest justified or over-built?

**Justified in principle, over-built in every candidate.** R3 needs exactly one
thing: *replace find-by-presence with an explicit list of target repos.* The
minimal form is a committed newline-delimited `tooling/skill-repos.txt`
(`grep -v '^#'`, pure POSIX, zero new dependencies) — which D actually sketches
(`cat tooling/skill-repos.txt`) and then buries under the plugin apparatus.
- B's **TOML + reusable sets + parser dependency** is the clearest over-build:
  set-union semantics solve an N×M repetition problem that doesn't bite at N≈8.
- C's **glob-resolved-against-`docs/about.md`** trades an explicit list for a
  prose-Markdown parsing dependency, and admits the fallback is... the explicit
  list.
- A's **per-repo `.claude/skills.manifest`** scatters the registry across repos
  when a single central list is simpler and more auditable.
The drift/orphan/`--check` tooling (B, C) is genuinely valuable but is a
*separate, optional* layer — add it after the core fix, not as a precondition.

### (c) The minimal design that still meets all four requirements

Stay on `.claude/commands/`. Touch only the script, two skill files, and prose:

1. **R2 (versioned home):** Commit the three orphans into the versioned canonical
   dir as-is, keeping the existing flat `.md` form:
   `tooling/claude-commands/handoff.md`, `.../polish.md` (capture current bytes
   from `~/.claude/commands/`), and commit the already-on-disk
   `think-with-the-engineering-taste.md`. Delete the unversioned real files in
   `~/.claude/commands/` and replace with symlinks into `tooling/claude-commands/`
   so the topology is uniform (this *preserves* the live-authoring loop rather
   than discarding it).
2. **R1 (github-io self-contained):** `git add` github-io's own
   `.claude/commands/<name>.md` as committed real files (copied from the canonical
   `tooling/claude-commands/`), so github-io loads from committed in-repo files on
   a fresh clone exactly like every receiver. (`tooling/claude-commands/` stays as
   the authoring/superset source + live-edit symlink target — *do not delete it*;
   it carries the dev-loop value A/C admit losing.)
3. **R3 (propagation):** Replace the `find ... -path "*/.claude/commands/*"`
   discovery rule in `propagate-skill.sh` with `for repo in $(grep -v '^[#[:space:]]*$'
   tooling/skill-repos.txt)`. Seed the 5 stranded skills by adding them to the
   relevant repos' first sync (now possible since inclusion no longer requires a
   pre-existing file). Make the source the canonical `tooling/claude-commands/`
   dir, not `~/.claude` (fixes the §5.1 source-of-truth conflict).
4. **R4 (docs):** Update CLAUDE.md to state: canonical = `tooling/claude-commands/`
   (now true and unconflicted, since the script reads it directly); registry =
   `tooling/skill-repos.txt`; every repo including github-io carries committed
   `.claude/commands/*.md`; `~/.claude/commands/` symlinks are optional live-author
   convenience, never load-bearing.

This meets R1–R4 with: 1 script edit, 1 new flat text file, 3 newly-committed
skill files, github-io's committed `.claude/commands/`, and prose — **no format
migration, no `tooling/` deletion, no TOML, no parser dependency, no plugin, no
namespacing, no destructive convergent sync, no half-migration strand risk, and
the live-authoring loop preserved.** Reversible at every step.

**Then, separately and optionally:** run the `commands → skills` directory-format
migration as its own fenced refactor, and add `--check` drift tooling, once the
correctness fix is in and stable. Best end-state architecture to converge toward
is A's (one directory, no layers); the disagreement with A is purely about
*migration sequencing and blast radius*, not the destination.

---

## One-line per-candidate

- **A — WOUNDED.** Best end-state, but bundles an unnecessary full-format
  migration sold as "subtraction" and ships a `rm -rf` sync.
- **B — WOUNDED (worst over-engineering).** TOML + reusable sets + parser
  dependency for a one-line discovery-rule fix.
- **C — WOUNDED.** Right steady-state sync, but stacks format migration +
  `rsync --delete` convergence + glob-parsing `about.md` in one destructive pass.
- **D — BROKEN as proposal / valuable as analysis.** Forced irreversible `rhi:`
  namespacing + no-walk-up footgun for zero requirement-driven benefit; its own
  §d agrees.
