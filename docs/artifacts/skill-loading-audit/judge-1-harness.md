# Judge 1 — Harness Correctness & Self-Containment (Adversarial)

Lens: try to break each candidate's claim of self-contained, correct loading.
Ground truth: `mechanism.md`. The harness facts I hold the candidates to:

- **Precedence: personal `~/.claude` OVER project `.claude/`.** A personal entry
  shadows the project copy.
- **A personal `~/.claude/skills/<name>` (or `commands/<name>`) is GLOBAL.** It is
  not scoped to github-io. It fires in *every* directory you launch Claude from,
  including other repos' clones.
- **Fresh clone of a project-scope skill loads with zero `~/.claude` setup, gated
  only by the workspace-trust dialog** (same gate that already governs committed
  `.claude/settings.json` hooks).
- **`@skills-dir` project-scope plugins do NOT walk up to repo root** (candidate D
  only); plain skills/commands do.

---

## THE SHADOWING QUESTION — answered first, definitively

Three of four candidates (A, B, C) keep a personal `~/.claude` symlink as
"optional convenience," and D keeps one too. **The framing "optional convenience"
is incoherent with harness precedence. Here is why, concretely.**

A personal `~/.claude/skills/<name>` symlink is not scoped to the repo it points
into. It is a *global* personal-scope entry. Because personal precedence beats
project precedence, that one symlink shadows the committed `.claude/skills/<name>`
of **every repo you ever open** — not just github-io.

Walk the failure: the operator symlinks `~/.claude/skills/polish` →
`github-io/.claude/skills/polish` "for convenience." Later the ecosystem ships a
diverged or simply *newer* `polish` to `normalize` via sync, and `normalize` is
committed at version N+1. The operator `cd`s into `normalize` and runs Claude. The
harness resolves `polish` from `~/.claude/skills/polish` (personal, wins) — i.e.
**github-io's bytes at whatever the symlink currently points to**, silently
overriding `normalize`'s own committed N+1 copy. The receiver repo's
self-containment is now a lie: it ships a committed copy that never loads on the
author's machine.

This is **not a new bug. It is the exact bug the audit found, generalized.** Today
github-io's skills load only via `~/.claude/commands/` symlinks; the audit's core
defect is precisely that a machine-local personal entry is the load path. Every
"optional convenience" symlink reintroduces that defect — and worse, projects it
across the whole ecosystem, because the personal entry overrides *other repos'*
committed copies, not just github-io's. The duplicate-listing symptom (same skill
twice) is itself a precedence artifact: the harness sees the project copy AND the
personal copy and surfaces both.

There is a second, subtler trap the candidates that say "the symlink points at the
canonical files so it's always correct" all fall into: that is only true on the
*one machine where github-io happens to be cloned at the expected path*. The whole
point of self-containment is that correctness must not depend on that machine
state. "The symlink resolves to the right bytes" is the find-by-luck argument the
audit already demolished.

**VERDICT ON THE SYMLINK: REMOVE ENTIRELY. Not keep-scoped.** There is no scoped
form — `~/.claude/skills/` has no per-repo scoping; it is global by construction.
The only correct posture for any design claiming self-containment is: the
propagator never creates a `~/.claude` skill entry, the migration *deletes* the
existing `handoff`/`polish` real files and all symlinks, and CLAUDE.md forbids
recreating them. The "invoke skills outside any repo" use case (C's and D's stated
justification) is real but is a *personal* workflow want that must be paid for by
the operator's own eyes-open acceptance that they are shadowing every repo — it
must never be presented as compatible with self-containment, and it must never be
something the propagator or docs endorse as "optional convenience." A design is
only correct here if removing the symlink is the *default and documented* state.

Per-candidate grading below treats "keeps the symlink as optional convenience" as
a landed attack of HIGH severity unless the candidate also makes *removal the
default* and names the cross-repo shadowing explicitly.

---

## Candidate A — Subtract / Minimize Indirection

**Attacks that land:**

1. **Symlink: BEST of the four, but still soft. (Medium, survivable.)** A is the
   only candidate that does not propose a `link-skills.sh` helper and explicitly
   says "The propagator does not create, read, or depend on any `~/.claude`
   entry," and its migration (f) *deletes* the real `handoff`/`polish` files. That
   is the correct move. BUT it still calls personal `~/.claude/skills/` "permitted
   … a personal override" and frames the shadow as merely "out of scope," without
   naming that the override is *global across all repos*. It under-states the
   hazard: it treats the shadow as a github-io-local convenience the design simply
   doesn't depend on, when in fact a stale personal entry corrupts loading in every
   receiver. The attack lands as an under-documentation defect, not a load-path
   defect — A does not route any load through `~/.claude`.

2. **The hub "superset" is convention, not enforced. (Medium.)** A admits this. A
   receiver edited directly drifts and nothing fails loudly; A explicitly keeps
   `--check` out of core. For a *correctness* lens this is a real gap: drift means a
   receiver silently loads a stale committed copy. Survivable because the loaded
   copy is still committed and self-contained — it's a freshness bug, not a
   self-containment bug.

3. **Manifest-by-omission stranding. (Low.)** A repo that forgets to list a skill
   doesn't get it. A calls this intended opt-in. Fine — it is a visible missing
   line, not silent presence-gating. No worse than status quo, strictly better.

**Duplicate-listing cause eliminated?** YES. With no `~/.claude` load entry, the
harness sees exactly one copy (the project `.claude/skills/`). The double-listing
was a precedence artifact; removing the personal layer removes it at the cause.

**Fresh-clone reality:** A relies on harness fact "skills load from
`.claude/skills/<name>/SKILL.md` on fresh clone." Correct. A does not over-claim
"zero setup" beyond the trust dialog — though, like B and C, it does not explicitly
mention the trust-dialog gate. Minor over-claim of friction-free, not of
correctness.

**Survives? SURVIVES.** Worst vulnerability: the hub-superset / drift-detection
gap is left as convention, so a directly-edited receiver can silently load a stale
committed skill. Self-containment itself is sound and the symlink is correctly
non-load-bearing — A just describes the shadow hazard too gently.

---

## Candidate B — Explicit Registry + Manifest

**Attacks that land:**

1. **Symlink: WOUNDING. (High.)** B explicitly *demotes the symlink to "optional
   authoring convenience"* AND ships a helper `tooling/link-skills.sh` that
   *creates* `~/.claude/skills/<name> → github-io/skills/<name>` symlinks. This is
   the trap, endorsed and tooled. B's defense — "because the tool never reads
   `~/.claude`, the shadow can never silently become the propagated truth" —
   answers the wrong question. The propagation source being clean does not save
   *loading*. The created symlink is global; it shadows the committed
   `.claude/skills/` of github-io AND every receiver the operator opens. B even
   points the symlink at `skills/` (the warehouse), not at github-io's deployed
   `.claude/skills/` — so the author is live-previewing *uncommitted* warehouse
   edits that then shadow every receiver's committed copy. B has reintroduced the
   audit's exact defect and shipped a script to do it. This lands hard.

2. **Two roles in one repo (`skills/` warehouse vs `.claude/skills/` deployed) is a
   live drift surface. (Medium.)** B requires the sync tool to keep github-io's own
   `skills/` and `.claude/skills/` consistent by running the push *against itself*.
   If the operator edits `skills/` and forgets to self-sync, github-io's harness
   loads the stale `.claude/skills/` copy while the warehouse has moved on — the
   same canonical/deployed split the audit flagged, just relocated inside one repo.
   A and C kill this by making `.claude/skills/` itself canonical (one dir, one
   role). B re-introduces it. The `--check` mode mitigates *if run*.

3. **TOML parser dependency. (Low, correctness-adjacent.)** B needs a TOML parser
   or "constrained hand-parse" in the sync tool. A hand-parse of TOML tables with
   inline `{ sets = [...], skills = [...] }` is exactly the kind of fragile parsing
   that fails silently on an edge case and mis-targets propagation. Not a
   load-path defect but a propagation-correctness risk.

**Duplicate-listing cause eliminated?** Only if the operator never runs
`link-skills.sh`. As designed-and-tooled, B *enables* the duplicate by handing the
operator a script that creates the shadowing personal entry. The cause is not
eliminated — it is relocated into an opt-in tool and blessed as a feature.

**Fresh-clone reality:** committed `.claude/skills/` loads correctly; B is sound on
the pure fresh-clone path (no `~/.claude` needed). The defect is what the *author's*
machine does once `link-skills.sh` has run.

**Survives? WOUNDED.** Worst vulnerability: ships `link-skills.sh`, which creates a
global personal symlink that shadows every receiver's committed copy — the audit's
original bug, tooled and endorsed as "optional convenience." Plus the internal
`skills/` vs `.claude/skills/` drift surface. B is self-contained *on a clean
machine* but actively manufactures the non-self-contained state on the author's.

---

## Candidate C — Modern-Format, Idempotent-Sync

**Attacks that land:**

1. **Symlink: WOUNDING. (High.)** C is the most explicit of all about wanting the
   personal symlink ("let the operator invoke skills when working outside any
   repo") and ships `link-personal-skills.sh` to *recreate the whole symlink set*.
   C deserves partial credit: it is the only candidate that NAMES the precedence
   hazard sharply ("a *stale* symlink … could mask a repo's own committed copy")
   and adds `--check-personal` to warn on dangling/outside-tree symlinks. But it
   does not go far enough, and its mitigation has a hole: `--check-personal` only
   warns when the symlink is *dangling or points outside github-io's
   `.claude/skills/`*. A symlink that points *correctly* at github-io's current
   `polish` but shadows `normalize`'s diverged committed `polish` is **not
   dangling and not outside the tree** — so `--check-personal` passes it clean
   while it actively corrupts loading in normalize. C's own check cannot see the
   shadowing case it most needs to catch, because the check is scoped to github-io
   and the damage happens in other repos. The "invoke outside any repo" use case
   does not justify a global override of every repo's committed skills.

2. **Glob targets depend on `docs/about.md` being machine-parseable. (Medium.)** C
   resolves `*` and `rhizone/*` against the prose project list in `docs/about.md`.
   That file is human-authored markdown; parsing it to drive *which repos get which
   skills* is a propagation-correctness landmine. C flags it ("if it isn't, the
   manifest needs its own explicit repo list") but ships the glob-against-prose as
   the primary design. A wrong parse mis-targets or skips a repo silently. B's
   explicit `[repos]` table is strictly safer here.

3. **github-io self-sync is asserted trivial but rests on an implicit identity.**
   (Low.) C says github-io "self-syncs trivially" because its `.claude/skills/` *is*
   canonical — i.e. C correctly makes `.claude/skills/` the single role (better than
   B). The only residual is the manifest-vs-disk hard error, which C handles via
   `--check`. Fine.

**Duplicate-listing cause eliminated?** Same as B: only if the operator declines
the shipped symlink helper. C ships and documents `link-personal-skills.sh`, so the
duplicate-listing precedence artifact is reachable by design. Cause relocated, not
eliminated.

**Fresh-clone reality:** Strong. C correctly makes `.claude/skills/` both canonical
and load path (no internal warehouse/deployed split like B), so the pure
fresh-clone path is clean and github-io is genuinely symmetric with receivers. C
also correctly identifies the legacy `.claude/commands/` → `.claude/skills/`
migration and load-tests before deletion (validate-against-reality).

**Survives? WOUNDED.** Worst vulnerability: ships `link-personal-skills.sh` and its
own `--check-personal` is structurally blind to the cross-repo shadowing case
(checks only dangling/outside-tree, not "correctly-pointed-but-shadows-another-
repo's-diverged-copy"). The design is self-contained on a clean machine and is the
cleanest single-role layout, but it tools and under-guards the exact shadow the
audit was about.

---

## Candidate D — Vendored / Referenced Plugin

**Attacks that land:**

1. **Symlink: WOUNDING — and the worst-positioned of the four to keep one. (High.)**
   D keeps the personal-convenience symlink `~/.claude/skills/rhi →
   github-io/tooling/rhi-plugin`. D's own defense is self-defeating: "acceptable
   only because both resolve to the same versioned source *on the dev's machine*."
   That is precisely the find-by-luck, machine-state-dependent argument the audit
   killed. Worse, because D vendors *one bundled plugin* `rhi` containing all eight
   skills, the personal `~/.claude/skills/rhi` shadows the **entire** committed
   plugin in every receiver at once — an all-or-nothing override. If `normalize`
   ever carries a diverged `rhi` bundle, the personal symlink masks the whole thing.

2. **No-walk-up is a genuine new load-path defect. (High — unique to D.)** D itself
   surfaces the verbatim fact: project-scope `@skills-dir` plugins "do not walk up
   to the repository root." This is a real fresh-clone correctness regression that
   the loose-file candidates (A/B/C, which use plain skills that DO walk up) do not
   have. Launch Claude from any subdirectory of the repo — a perfectly normal thing
   — and the plugin silently does not load. "Documented constraint / launch from
   root" is a behavioral workaround, not a structural fix; the failure is silent
   (no error, just missing skills), which is the worst kind. This attack lands and
   is unique to D.

3. **Forced `rhi:` namespacing is irreversible and breaks every existing
   invocation. (Medium — ergonomic, not correctness, but D admits it dominates.)**
   `/polish` becomes `/rhi:polish` with no opt-out. D honestly concludes the plugin
   noun "buys almost nothing here" and is "strictly worse than loose vendored
   files." The candidate argues against itself, correctly.

4. **Trust-dialog / non-interactive contexts. (Low — shared, D names it.)** A CI or
   non-interactive run that can't answer the trust dialog gets no skills. D notes
   loose skills share this. True; not differentiating.

**Duplicate-listing cause eliminated?** On the clean path, yes (single committed
plugin, one load). But the kept personal symlink reintroduces the precedence
duplicate, and now at whole-bundle granularity.

**Fresh-clone reality:** D is the most rigorous candidate about *what actually loads
on a fresh clone* — its §(g) verdict correctly disqualifies marketplace install,
`--plugin-dir`, `--plugin-url`, and user-scope as all routing through
`~/.claude/plugins/cache` or per-session flags, and correctly identifies
project-scope `@skills-dir` as the one self-contained loader gated only by the
trust dialog. This is the strongest harness-facts analysis in the set. But the
mechanism it lands on carries the no-walk-up footgun that the simpler candidates
avoid entirely.

**Survives? WOUNDED (arguably self-broken).** Worst vulnerability: the no-walk-up
rule is a silent fresh-clone load failure on any non-root launch — a *new*
correctness defect that A/B/C do not have — and the bundled personal symlink
shadows the entire eight-skill set across all repos at once. D's own honest verdict
("plugin wrapper is overhead unless external distribution is a goal") is correct:
it pays plugin costs (namespacing, no-walk-up) for no self-containment benefit over
loose vendored files.

---

## Cross-candidate findings

- **Every candidate's pure fresh-clone path (committed `.claude/skills/`, no
  `~/.claude`) is correct.** The differentiator is entirely what each does with the
  personal symlink and where it puts the canonical bytes.
- **The single-role layout (A and C: `.claude/skills/` is *both* canonical and load
  path) is structurally superior** to B's warehouse/deployed split, which
  re-creates a canonical-vs-deployed drift surface *inside one repo* — the precise
  shape of the audit's original asymmetry.
- **No candidate makes symlink removal the unambiguous default.** A comes closest
  (propagator never touches `~/.claude`, migration deletes the real files) but still
  calls personal entries "permitted." B and C actively ship symlink-creation
  helpers. D keeps a bundle-wide symlink. The correct design ships *no*
  `link-skills.sh`, deletes the existing `handoff`/`polish` real files and all
  symlinks during migration, and documents in CLAUDE.md that creating a
  `~/.claude/skills` entry shadows every repo's committed copy and is forbidden for
  ecosystem skills.
- **Only C names the precedence hazard sharply, but its mitigation
  (`--check-personal`) is structurally blind to the cross-repo shadow case** because
  it checks only dangling/outside-tree, scoped to github-io — and the damage occurs
  in other repos with diverged copies, pointed-at-correctly.
