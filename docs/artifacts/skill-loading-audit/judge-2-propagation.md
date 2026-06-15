# Judge 2 — Propagation Correctness & Operations

Adversarial review. Attack lens: sync/manifest machinery and the day-to-day
operational loop. Ground truth: `mechanism.md`. Verdict digest at the end.

The brief's central operational question — restated so the attack is unambiguous:
**every candidate makes github-io both the canonical source AND a receiver that
commits its own `.claude/skills/`. Does that create one true source, or two
copies in one repo that can drift?** Answered definitively per candidate and in
aggregate below.

---

## THE SELF-SOURCE LOOP — definitive answer

Three of the four candidates (A, B, D) put **two physically distinct copies of
the same bytes inside github-io** and call one "canonical" and the other
"deployed/runtime." That is a textbook drift surface, and the audit already
*proves* it is not hypothetical: `mechanism.md` §2 documents
`think-with-the-engineering-taste.md` present in `tooling/claude-commands/` on
disk but **not committed** — i.e. the exact "two locations in one repo, one
drifted from the other" failure these designs re-create. They are reintroducing
the bug they were commissioned to remove.

- **Candidate A** is the *only* design that genuinely has ONE source of truth in
  github-io: it deletes `tooling/claude-commands/` and makes github-io's own
  committed `.claude/skills/` serve both roles — "one directory, two roles, zero
  duplication" (A line 49). There is no second copy *inside github-io* to drift.
  The drift surface that remains is across *receiver* repos (every design has
  that), not internal. A is correct on the loop.

- **Candidate B** explicitly keeps TWO dirs in github-io: `skills/` (warehouse)
  and `.claude/skills/` (github-io's deployed copy), and says "The sync tool is
  what keeps them consistent — github-io eats its own dog food by running the
  same push against itself" (B lines 48-50). This is a self-source loop: github-io
  is row `"rhizone/github-io"` in its own manifest (B line 96), so `sync-skills.sh`
  copies `skills/foo` → `github-io/.claude/skills/foo` and commits it. Two copies,
  kept in sync only by *running the tool*. Between an edit to `skills/` and the
  next sync run, github-io's own harness loads the STALE `.claude/skills/` copy.
  The warehouse is canonical for distribution but NOT for github-io's own loading.
  That is two sources of truth with a window of divergence. **Drift risk: real.**

- **Candidate C** dodges the loop the same way A does: "There is no separate
  `tooling/claude-commands/` canonical tree… that directory is *both* the
  canonical home and the load path" (C lines 11-13). github-io's
  `.claude/skills/` IS canonical; sync "only validates the manifest matches
  what's committed there" (C line 85). One copy in github-io. C is correct on the
  loop — and is explicit about *why* the two-copy design is wrong, citing the same
  `think-with-the-engineering-taste` evidence I cite above (C line 13).

- **Candidate D** keeps TWO copies in github-io by construction: canonical
  `tooling/rhi-plugin/` AND vendored `.claude/skills/rhi/` ("github-io is
  self-contained — it does not get to be the exception," D line 152). The
  propagator `rsync`s `tooling/rhi-plugin/` → `.claude/skills/rhi/`. Same window
  of divergence as B, and worse: D's propagator sketch (D lines 164-172) does
  **not** include github-io in the loop — it iterates `tooling/skill-repos.txt`
  and rsyncs `$SRC` → `$repo/.claude/skills/rhi/`. If github-io is one of those
  repos, it rsyncs github-io's own `tooling/rhi-plugin/` onto github-io's
  `.claude/skills/rhi/` — fine — but nothing shown re-runs after an edit to
  `tooling/rhi-plugin/`, so github-io's own loaded copy lags. **Drift risk: real,
  and the sketch doesn't even close it.**

**Definitive verdict on the self-source loop:** There is genuinely ONE true
source ONLY in A and C, because they collapse github-io's canonical and runtime
directory into the same committed `.claude/skills/`. B and D each maintain TWO
copies inside github-io (warehouse + deployed) reconciled only by running the
sync tool — a standing drift surface with a divergence window on every edit, and
it is the *same* class of bug the audit caught in the current state. A self-source
loop is not inherently a cycle (the copies are in different dirs, so `rsync`
terminates), but it IS a double source of truth whenever the two dirs are
distinct. Collapse them (A/C) and the problem vanishes; keep them split (B/D) and
you have shipped the original defect under a new name.

---

## Candidate A — Subtract

**Attacks that land:**

1. **Orphan/removal handling is absent from the core tool — the "retire" loop is
   broken.** A's `sync-skills.sh` (A lines 101-125) only iterates `wanted` skills
   and `cp -R` each one. If a skill is removed from a receiver's manifest, the
   loop **never touches** the now-orphaned `.claude/skills/<name>/` — it is not in
   `wanted`, so it is never `rm`'d, never staged, never committed. The skill stays
   live in the receiver forever. A even admits drift detection is "out of band"
   and pushes `--check` to a separate optional verb (A lines 201-207). So removal
   does not converge. **Severity: HIGH.** For a `*`-manifest repo this is less
   bad (set = `ls "$HUB"`, so deleting from the hub drops it from `wanted`) — but
   the orphan dir on disk is *still* never deleted because nothing diffs disk
   against `wanted`. Convergence on removal is simply not implemented.

2. **Self-source loop: A is clean (see above) — but only because it deletes
   `tooling/claude-commands/`. The migration step (f) that deletes it is
   load-bearing for the whole claim;** if an operator skips it, A degrades into B.
   Minor, but worth flagging: the property depends on a one-time migration
   actually completing.

3. **The push gate is subtly wrong and can push a dirty tree's unrelated work.**
   `git -C "$repo" diff --quiet && git -C "$repo" push || true` (A line 123). This
   checks the *unstaged* working tree AFTER committing the staged skill changes.
   If the receiver had unrelated uncommitted changes, `diff --quiet` is false →
   push is skipped — good. BUT the `commit` on line 122 already ran
   unconditionally (gated only by `diff --cached --quiet` on line 121). So a dirty
   receiver gets a **skill commit layered on top of its dirty tree**, then the push
   is skipped. Now the receiver has an unpushed skill commit AND uncommitted work
   tangled together — exactly the "dirty repos block commit/push" hazard the audit
   says today's script avoids by *skipping entirely*. A commits into dirty repos.
   **Severity: MEDIUM-HIGH** (operational mess, recoverable but violates the
   established dirty-repo convention).

4. **`normalize init` / `.normalize/` is dropped.** Today's script stages
   `.normalize/` (audit §1). A's loop stages only `.claude/skills/$name`. If
   `normalize init` is still required post-sync, A silently regresses it.
   **Severity: LOW-MEDIUM** (depends whether normalize is still in the loop;
   A doesn't say, which is itself the gap).

5. **`*`-manifest + `ls "$HUB"` is whitespace-fragile and unsorted**, but cosmetic.

**Operational cost:** edit one skill → 1 commit in github-io (the edit IS the
source) + N receiver commits + N pushes. Same N-commit fan-out as everyone. No
manifest parser, smallest tool. Cheapest steady state of the four.

**Survives?** **WOUNDED.** The single worst vulnerability: **removal/orphan
convergence is not implemented** — A is additive-only and explicitly defers drift
to an optional verb, so the "retire, don't deprecate" ecosystem principle cannot
be executed by the core tool. Combined with committing into dirty receivers, A
needs the orphan-prune and dirty-skip logic that C already has before it is
operationally sound.

---

## Candidate B — Registry + Manifest

**Attacks that land:**

1. **Self-source loop / double source of truth in github-io — the worst of the
   four on this axis.** Detailed above. `skills/` vs `.claude/skills/` are two
   committed copies in one repo, reconciled only by running the tool against
   github-io itself. The divergence window means github-io's OWN harness can load
   a stale skill it is simultaneously distributing fresh to everyone else. B
   markets this as a feature ("eats its own dog food") but it is the audit's
   original two-location bug. **Severity: HIGH.**

2. **Manifest TOML parser is an undeclared dependency with no fallback story.**
   B (d, "Costs") admits "a TOML parser dependency in the sync tool (or a
   constrained hand-parse)." On a NixOS per-project-flake system (global rules),
   there is no guaranteed system TOML parser. A hand-parse of nested inline tables
   `{ sets = [...], skills = [...] }` (B line 96) is genuinely fiddly bash and a
   bug farm. The current `find | cp` needs zero parsing. **Severity: MEDIUM.**

3. **Set-expansion makes "who has skill X" auditable only after computing a union
   per repo.** B claims "who has skill X is a grep of one file" (B line 183) — but
   that is FALSE for any skill delivered via a *set*. `polish` is in `baseline`;
   to answer "who has polish" you must expand every repo's `sets` and union. The
   audit-by-grep claim only holds for explicit `skills = [...]` entries.
   **Severity: LOW** (the data is there, the claim oversells ergonomics).

4. **Orphan handling is `--prune`, off by default (B step 4, line 124).** So the
   default run does NOT converge on removal — same class of defect as A, but B at
   least *detects and reports* the orphan by default and has the prune verb. Still:
   default-off prune means removing a skill from the manifest does nothing to
   receivers until someone remembers `--prune`. **Severity: MEDIUM.**

5. **Dirty-repo + partial-failure: B says push-if-clean, TODO-if-dirty (step 5),
   which matches today's convention** — better than A here. But `set -euo
   pipefail` is not shown; if it's set and one repo's commit fails mid-fan-out,
   the loop aborts leaving the ecosystem half-synced with no resume marker. No
   transactionality or resume story. **Severity: MEDIUM** (shared with A/C/D).

**Operational cost:** edit skill in `skills/` → must run sync even to update
github-io's OWN copy (extra step A/C don't have) → 1 github-io commit for the
edit + 1 more for github-io's deployed copy (or the same commit if batched) + N
receiver commits + N pushes. **Strictly more commits than A/C** because of the
self-source duplication.

**Survives?** **WOUNDED.** Worst vulnerability: **the warehouse/deployed split
inside github-io is a standing double-source-of-truth** — it re-creates the
audit's two-location drift bug and adds operational steps, for an abstraction
(sets, TOML) that the ecosystem's actual scale (8 repos) does not need. The
manifest idea is sound; binding it to a TOML warehouse separate from the load
path is the defect.

---

## Candidate C — Modern, Idempotent-Sync

**Attacks that land:**

1. **`*` and `rhizone/*` globs resolve against `docs/about.md` — a docs file, not
   a machine registry.** C (c) admits "Assumes the project list in `docs/about.md`
   is accurate and machine-parseable enough." This is the load-bearing input to
   *which repos get skills*, and it is parsed out of prose Markdown. If a project
   is added to the ecosystem but `docs/about.md`'s table format shifts, the glob
   silently resolves to the wrong set — and a *missing* repo means that repo
   silently gets no skills (find-by-presence's stranding bug, reborn through a
   parse miss). C hedges with "If it isn't, the manifest needs its own explicit
   repo list" — which is an admission the data source is wrong; it should just be
   the explicit list. **Severity: MEDIUM-HIGH.**

2. **"Manifest referencing a repo that doesn't exist locally" — unaddressed.**
   The glob resolves to org/repo paths under `~/git`. If `docs/about.md` lists a
   repo not cloned on this machine, C's loop has no stated guard — it would try to
   `git -C <missing>` and either error (if `set -e`) aborting the whole fan-out,
   or silently skip. C does not say which. The audit's `find ~/git` approach
   *structurally cannot* reference a non-cloned repo (it only finds what exists);
   C's declarative glob CAN. New failure mode introduced. **Severity: MEDIUM.**

3. **Drift detection claims — strongest of the four, and they mostly hold.** C's
   `--check` reports stale / missing / orphan distinctly (C lines 93-97) and
   catches manifest-references-nonexistent-skill (C line 98). This genuinely
   covers more drift classes than A (none in core) or B (orphan default-off).
   **But it does NOT catch format-mismatch** as a distinct class: if a receiver
   still has `.claude/commands/<name>.md` (legacy) AND `.claude/skills/<name>/`,
   the `--delete` rsync reconciles the skills dir but the orphan-removal step
   (step 4) only scans `.claude/skills/`, not `.claude/commands/`. A leftover
   legacy `commands/` file is invisible to `--check`. C's migration (f, step 3)
   removes legacy files once, but `--check` won't *catch* a regression that
   re-introduces one. So the "catches all drift" implication is overstated by one
   class. **Severity: LOW-MEDIUM.**

4. **`rsync --delete`-*equivalent* in bash is hand-waved.** C says
   "`rsync --delete`-equivalent" (C line 77) — if it literally uses `rsync`, that's
   another non-guaranteed tool on NixOS-per-flake; if it hand-rolls the
   delete-extraneous logic, that's the fiddly part and it isn't shown. The
   idempotency claim rests on code that isn't written. **Severity: LOW** (design
   doc, but the convergence guarantee is the headline and it's unspecified).

5. **github-io self-sync: C handles the loop correctly** (one dir, validate-only —
   see loop section). No internal drift surface. This is C's biggest advantage
   over B/D.

**Operational cost:** edit `.claude/skills/<name>/SKILL.md` in github-io (the edit
is immediately live, no extra step) → run sync → N receiver commits + N pushes.
Idempotent re-runs are no-ops. Same N-commit fan-out, but cleanest steady state
because github-io needs no self-sync step (A shares this; B/D don't).

**Survives?** **SURVIVES (with required fix).** Worst vulnerability: **the
`docs/about.md`-as-registry coupling** — deriving the distribution target set by
parsing a prose docs file is fragile and re-opens a silent-stranding path. Fix is
trivial and C names it: use an explicit repo list. With that swap, C is the most
operationally complete design: one source of truth in github-io, idempotent
convergent sync, real multi-class drift detection, correct dirty-repo skip.

---

## Candidate D — Vendored Plugin

**Attacks that land:**

1. **Self-source loop: TWO copies in github-io (`tooling/rhi-plugin/` +
   `.claude/skills/rhi/`), and the propagator sketch doesn't reconcile github-io
   to itself.** Detailed in the loop section. D's sketch (D lines 164-172)
   iterates `tooling/skill-repos.txt`; whether github-io is in that file and
   whether anything re-rsyncs after an edit is unspecified. Divergence window on
   every edit, same as B, with no shown closure. **Severity: HIGH.**

2. **Auto-update story when vendored per-repo: there is NONE — and D admits it.**
   The brief asks specifically about auto-update for the vendored plugin. D's own
   verdict (D lines 214-217): "We pay the plugin's costs (namespacing, manifest,
   no-walk-up) without getting its benefit (central install + auto-update)." The
   `version` field in `plugin.json` is "documentation" for pure vendoring (D line
   146). So bumping `version` does NOTHING — `/plugin update` is inert for an
   `@skills-dir` plugin; the only update path is re-running the propagator to
   `rsync` new bytes and committing N times. **Auto-update is a non-feature here.**
   This is decisive against the plugin noun for this use case. **Severity: HIGH
   (for the plugin framing specifically).**

3. **`rsync -a --delete` (D line 167) — best convergence semantics of the four**
   (it actually deletes orphaned files inside the plugin tree), BUT it's `rsync`
   on a NixOS-per-flake system again, and `--delete` scoped to
   `.claude/skills/rhi/` only converges *within the plugin dir* — a skill removed
   from the plugin manifest is removed, good; but if a repo also has loose
   pre-migration `.claude/commands/*.md` or a *different* skill dir, that's
   untouched. Same legacy-orphan blind spot as C, narrower. **Severity: LOW-MEDIUM.**

4. **Namespacing breaks every existing invocation irreversibly** (`/polish` →
   `/rhi:polish`, D lines 78-80, 209-211). Not strictly propagation, but it is a
   day-to-day operational tax on every skill call, forever, with no opt-out. D
   honestly flags this as the biggest reason to reject the noun. **Severity:
   MEDIUM** (ergonomic, permanent).

5. **No-walk-up footgun (D caveat 1):** project-scope `@skills-dir` only loads
   from the cwd's `.claude/skills/`, not the repo root. Launch Claude Code from a
   subdirectory → no skills, silently. Loose skills/commands walk up; the plugin
   doesn't. New operational failure mode. **Severity: MEDIUM.**

**Operational cost:** edit `tooling/rhi-plugin/` → re-run propagator → rsync +
commit + push across N repos + github-io's own vendored copy. Atomic *bundle*
update is the one genuine win (all 8 skills travel together). But every edit to
*one* skill re-commits the *whole plugin dir* in every repo — coarser commit
granularity than A/C (which commit per-skill). Noisier history.

**Survives?** **WOUNDED — and self-defeating by its own analysis.** Worst
vulnerability: **the plugin's entire reason for existing (central install +
auto-update) is incompatible with Requirement 1, so D vendors per-repo bytes
exactly like A/C/D-loose but pays namespacing + no-walk-up on top.** D's own
summary table says "plugin wrapper is overhead unless external distribution is a
goal." As a propagation mechanism it is strictly dominated by C (same vendoring,
no namespace tax, no walk-up footgun, real drift detection). It survives only as
"viable," not as "good."

---

## VERDICT DIGEST

| Candidate | Verdict | Single worst vulnerability |
|---|---|---|
| **A — Subtract** | **WOUNDED** | Removal/orphan convergence not implemented (additive-only; drift deferred to optional verb) + commits into dirty receivers |
| **B — Registry/TOML** | **WOUNDED** | Warehouse (`skills/`) vs deployed (`.claude/skills/`) split inside github-io = standing double source of truth, re-creating the audit's two-location drift bug |
| **C — Modern idempotent** | **SURVIVES (fix req'd)** | Distribution targets parsed from prose `docs/about.md` instead of an explicit registry — fragile, re-opens silent stranding |
| **D — Plugin** | **WOUNDED** | Plugin's only benefit (central install/auto-update) is incompatible with self-containment; vendoring + namespacing tax + no-walk-up = strictly dominated by C |

**Self-source-loop verdict (definitive):** ONE true source exists ONLY in **A and
C**, which collapse github-io's canonical and runtime skills into a single
committed `.claude/skills/` (no second copy to drift). **B and D each keep two
copies inside github-io** (warehouse/plugin-source + deployed) reconciled only by
running the sync tool — a genuine double source of truth with a divergence window
on every edit, and it is the *same* drift class the audit already caught in the
live state (`think-with-the-engineering-taste`: in `tooling/` on disk, not in
git). Not a cycle (copies sit in different dirs, so `rsync`/`cp` terminates), but
unambiguously a drift risk. **The loop is solved by collapsing the two dirs, not
by syncing them.**

**Operational standing (propagation lens only):** C ≳ A > B > D. C is the most
complete (idempotent, convergent, multi-class drift detection, correct dirty-repo
skip, single in-repo source) and needs only the registry-source swap. A is the
leanest but ships incomplete (no removal convergence, dirty-repo commits). B adds
real machinery (sets, TOML) the 8-repo scale doesn't justify and reintroduces the
two-location drift. D is dominated by C and self-defeats on auto-update.
