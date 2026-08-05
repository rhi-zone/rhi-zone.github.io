# TODO

---

## Decided, pending scaffold

- **petgraph-native structural-mining library (2026-07-02).** Decided per `docs/decisions/ecosystem/0290-petgraph-native-structural-mining-library.md` (ADR-0290; evidence in `docs/artifacts/2026-07-02-motif-engine/`). Not yet scaffolded; org = rhi-zone. Open at scaffold: final crate name (verify crates.io availability; `petgraph-` is the plugin idiom, not a forbidden self-prefix). Live, unresolved: the `franken_networkx`-publishes-to-crates.io cohesion threat, and the open gates (per-node orbit attribution / GDV-GDD, scalable k=5, lazy-iterator lifetime, VF2 induced-filter, directed k≥4).

---

## Ecosystem-wide bug: cargo `config.local.toml` include never merges on stable — needs propagation (2026-08-05, updated 2026-08-05, worktree-policy conclusion finalized 2026-08-05)

**Not applicable to github-io itself** — verified: github-io has no `Cargo.toml` anywhere in
the repo root (`scaffolding/` has its own separate `flake.nix`), and `flake.nix` provisions
only `bun` + `jq`. It is a vitepress/bun docs site, not a cargo/Rust project, and has no
worktree/target-dir build-cache mechanism of any kind (`scripts/` contains only
`freshness.sh`; searched for `worktree`/`target/` mentions across `TODO.md`/`TODO.local.md`
— none). So this bug cannot recur here; noted per the ecosystem convention of tracking
cross-project issues in the affected repo's TODO.md, since github-io is the repo that
coordinates ecosystem-wide propagation.

**The bug (confirmed in rescribe, `~/git/rhizone/rescribe`):** the cross-git-worktree
shared `target/` build-cache mechanism relied on `.cargo/config.toml`'s
`include = ["config.local.toml"]` directive. That directive is gated behind the unstable
`-Z config-include` cargo flag and **silently never merges on stable cargo** — confirmed via
direct reproduction (CARGO_LOG tracing showed the included file never loads) plus an
isolated scratch-dir repro outside any repo. Consequence: every worktree built its own full
local `target/` instead of sharing one, and 11 concurrent agent worktrees filled a machine's
disk to ~100% (~137GB total duplicated).

**The fix (implemented and verified end-to-end in rescribe — reference implementation):**
replace the cargo-config-based sharing with filesystem-level symlinks/junctions. Each
worktree's `target/` becomes a symlink (unix/mac) or NTFS junction-with-symlink-fallback
(windows) pointing at the main checkout's `target/`, created automatically by a
`.githooks/post-checkout` hook (empirically confirmed `git worktree add` fires
`post-checkout`), so no manual per-worktree step is required. Windows specifics verified:
junctions (`mklink /J`) need no admin/Developer Mode for a regular user but only work within
one NTFS volume; true symlinks work cross-drive but need `SeCreateSymbolicLinkPrivilege`
(admin, or Developer Mode on Windows 10 1703+). Tries junction first, falls back to symlink,
hard-errors with a clear message if both fail — no silent failure path. rescribe commits:
`303bba6eca` (script rewrite), `b8d7e49236` (the `post-checkout` hook), `9a46158b03` (docs
correction — also removed stale claims that direnv/nix covered this automatically, false
once an earlier `CARGO_TARGET_DIR` shellHook was removed).

**Open action for a future session:** audit every cargo/Rust repo in the ecosystem for the
same `config.local.toml`-include pattern (or any other unstable-cargo-flag-dependent
sharing mechanism) and propagate the rescribe symlink/junction fix to each one found
broken the same way. Not yet done — no repos have been audited as part of this note; that
audit is the next step, not a claim that any specific repo besides rescribe is affected.

**UPDATE (2026-08-05, same day, same rescribe session): a second, distinct, still-UNFIXED
disk-bloat mechanism was found — do not read the symlink fix above as closing the
disk-bloat problem, it only closes one of two causes.**

Even after `target/` is correctly shared via symlink/junction across worktrees,
`target/debug/incremental/` specifically does **not** deduplicate across worktrees. Confirmed
via direct evidence in rescribe: ran `strings` on a cached `metadata.rmeta` inside the shared
`incremental/` directory and found literal absolute worktree-specific source paths baked into
it, e.g. `/home/.../worktrees/agent-XXXX/crates/rescribe-core/src/document.rs`. rustc's
incremental-compilation cache fingerprints embed the absolute source-file path, so identical
source code built from two different worktree checkout paths lands in entirely separate,
non-overlapping incremental cache directories — confirmed concretely: one crate had 8 distinct
top-level hash directories under `incremental/` across worktrees for what should be "the same"
build. Net effect: sharing `target/` via symlink stops *new redundant full builds*, but does
**not** stop `incremental/` itself from growing unboundedly as more worktrees get created and
torn down — each worktree's incremental contribution just piles up in the shared directory
forever, never reclaimed. This is a separate mechanism from the `config.local.toml` bug above
and is **not fixed** by the symlink/junction change.

**No standard fix exists — this was researched via web search, not assumed.**
`--remap-path-prefix` was tested as a candidate fix and *confirmed* to affect the actual
incremental fingerprint (not just cosmetic debug-info text — the SVH-derived hash component
matched across differently-pathed builds when both were remapped to the same canonical path).
However, a synthetic reproduction test could **not** cleanly reproduce the original real-worktree
symptom end-to-end, so this candidate fix is **not validated** and was **not implemented**.
Broader research found no accepted upstream solution:
- `sccache` does not solve this and actively conflicts with `CARGO_INCREMENTAL` (must be
  disabled to use sccache alongside it).
- No rust-lang RFC or accepted cargo issue addresses incremental-cache portability across
  worktrees/checkout paths. RFC 3127 / `-Z trim-paths` addresses paths baked into
  binaries/debuginfo for build reproducibility — a different problem, not incremental-cache
  portability.
- Every real-world workaround found treats rustc's incremental cache as fundamentally
  non-portable across absolute paths and works around it rather than fixing it: hardlinking
  only `deps/` + `.fingerprint/` between worktrees (explicitly *not* `incremental/`); full
  per-worktree isolation with no sharing at all (`cargo-worktree`); or replacing incremental
  compilation entirely with a custom content-addressed cache that excludes absolute paths from
  its cache key (`kache`).

**Open item for whoever picks this up:** either (a) implement the hardlink-only-`deps`-and-
`.fingerprint` pattern and leave `incremental/` unshared (it stays worktree-local and is
reclaimed automatically when the worktree is torn down), or (b) accept periodic
manual/scripted pruning of the shared `incremental/` directory as an ongoing operational cost.
**Neither has been implemented in rescribe yet** — this is open, not resolved.

**UPDATE (2026-08-05, same session): root-cause correction on what actually caused this
session's multi-agent collisions.** This reframes the read of the note above — the
`config.local.toml`/symlink fix addresses genuine disk-bloat mechanisms, but it was **not**
the primary cause of the multi-agent collisions observed during a large concurrent
crate-migration effort in rescribe (multiple agents, each migrating a different, independently
modular format crate to a shared new trait system). Format crates in rescribe are already
properly modular — separate directories, disjoint file sets — so concurrent edits to
*different* crates should never collide on the files themselves, and further investigation
found they didn't. The actual causes were:
- **`git stash` is a single shared stack across all worktrees of a repo, not per-worktree** —
  confirmed directly: multiple agents' `stash push`/`stash pop` operations collided with each
  other, each agent's stash sometimes popping another agent's changes.
- **A single shared cross-cutting test file**, `crates/rescribe-fixtures/tests/streaming_apis.rs`,
  that every crate-migration needed to add its own section to — combined with agents doing
  blind whole-file `git add` / `git commit` rather than scoping to their own diff hunks, which
  bundled unrelated crates' in-progress work into the wrong commits.

**SUPERSEDED lesson (do not use):** an earlier version of this note said worktree isolation
"should be reserved for work that genuinely needs it — shared/cross-cutting files, or
otherwise-overlapping file sets." Further discussion in the same rescribe session found this
framing incoherent and replaced it with the corrected conclusion below — kept here, struck,
only so the correction is traceable, not as guidance.

**UPDATE (2026-08-05, same rescribe session, final on this point): corrected conclusion on
worktree-usage policy.** The superseded framing above got the mechanism backwards. Worktree
isolation does **not** solve the shared-file collision problem at all — it only *relocates*
the collision from live-edit time to merge time: two isolated agents both editing the same
logical file on separate branches still have to reconcile it eventually, and that
reconciliation is exactly what produced the bundling/stash-contamination incidents recorded
above. What worktree isolation actually protects against is a different, narrower thing:
careless, non-file-scoped git operations (`git add -A`, whole-tree `git stash`) colliding
across concurrent agents even when the files they're each editing are genuinely disjoint —
a tooling-discipline problem, not a file-overlap problem.

The corrected rule, reached through discussion and checked against real alternatives:
- Multiple agents working in parallel against **one shared tree** (no `git worktree` at all)
  is fine, and actually preferable — zero extra build/disk cost, no
  `incremental/`-cache-duplication concern at all — **provided** three conditions hold:
  (1) disjoint files across agents (no two agents editing the same file); (2) disciplined git
  operations (never whole-tree `git add -A`, never repo-wide `git stash`, commits scoped to
  only the files/hunks each agent actually owns); (3) no shared cross-cutting file needing
  simultaneous edits from more than one agent — eliminate such files via refactor (e.g.
  rescribe's own fix: splitting the single shared `streaming_apis.rs` test file into one file
  per format) or serialize access to them, rather than reaching for isolation.
- The "need two different git states simultaneously" case, initially thought to be a genuine
  remaining justification for worktrees, was also examined and rejected as a common case:
  almost all such needs are actually "compare results across commits," which doesn't require
  true simultaneity — sequential checkout in **one** directory (build/test commit A, capture
  results, checkout commit B in the same path, build/test, compare) covers it with zero extra
  build cache. True simultaneity (rare) can often be covered by a throwaway
  `git archive <commit> | tar -x` snapshot to a scratch directory (a real buildable snapshot,
  no `.git` linkage, fully disposable) rather than a real `git worktree`, avoiding the
  incremental-cache-duplication cost entirely for that case too.
- **Conclusion:** given the confirmed, unavoidable per-worktree cost (`incremental/`
  cache duplication with no fix — see the mechanism table below) and that no remaining common
  use case actually requires a literal `git worktree`, worktree isolation should be treated as
  **rare and specifically justified**, not a default reached for whenever "multiple agents are
  running in parallel." This narrows the superseded framing above further, rather than
  restoring any part of it.

This conclusion is ecosystem-wide harness/agent-orchestration convention, not a rescribe-local
detail — it applies to any repo in the ecosystem that uses parallel/worktree-isolated agent
dispatch, which is why it's recorded here alongside the disk-mechanism findings rather than
only in rescribe.

rescribe is currently mid-fix on the concrete instance that motivated this: splitting
`streaming_apis.rs` into per-format files to eliminate the shared-touchpoint collision surface
that isolation would only have deferred to merge time — in progress as of this note (not
complete — check rescribe's own state before assuming this is done).

**Summary of state, so this isn't misread:**
| Mechanism | Status |
|---|---|
| `config.local.toml` include never merging (unstable flag) | **Fixed** — symlink/junction + `post-checkout` hook (rescribe `303bba6eca`/`b8d7e49236`/`9a46158b03`) |
| `target/debug/incremental/` not deduplicating across worktree paths | **Not fixed** — no validated solution; open item above |
| Multi-agent collisions this session | **Root cause was shared `git stash` + a shared cross-cutting test file with unscoped commits, not lack of file-level worktree isolation** — process/convention fix in progress in rescribe, not yet complete |
| Worktree-usage policy | **Corrected (final on this point):** shared-file collisions aren't solved by isolation, only deferred to merge time; isolation should be rare and specifically justified, not a default for parallel agent work — see corrected conclusion above |

---

## Ecosystem propagation residuals (2026-07-03)

- **Re-run `tooling/propagate-harness-all.sh` and `tooling/sync-skills.sh` once dirty receivers are clean.** Dirty at run time: exoplace/aeriea, exoplace/hologram, paragarden/solarium, pteraworld, pterror/ashwren, pterror/fuwafuwa, rhizone/defocus, rhizone/fractal, rhizone/rainbow, rhizone/server-less (harness landed there as unpushed harness-only commits; skills were skipped in aeriea, solarium, defocus, fractal, rainbow, server-less). One further dirty receiver is tracked in the machine-local TODO.local.md.
- **pterror/software-taxonomy — harness deferred.** Owner-edited CLAUDE.md + hook files; revisit once the owner edits settle.
- **pteraworld/annotated-law — not cloned locally, skills skipped.** Clone it or drop it from the recipient lists.
- One push-retry residual is tracked in the machine-local TODO.local.md (private repo name).

---

## Open threads: control-surface (updated 2026-07-02)

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*
>
> **Trust boundary:** this is a PUBLIC repo with a private-names pre-commit guard, a commit-msg guard, and a vitepress build. No private project names in committed content; no `--no-verify`; no `git add -A`; never stage the untracked `docs/artifacts/2026-06-23-agentic-analysis/`.

- **Control-surface decision-quality thread (2026-07-02) — LIVE, ordered.** A long design session reached two conclusions, both PENDING user certification (captured in `docs/artifacts/2026-06-30-overconfidence-control-surface/CONFIRMED-FACTS.md` §2026-07-02; detailed handoff in the sibling `HANDOFF.md`):
  - **(i)** design-it-twice is really a DISPOSITION — no approach is "the" way absent explicit unconditional user blessing — *not* a "spawn N candidates" procedure. The procedure-shape is what let it drift into forcing structure.
  - **(ii)** an uncovered OBLIGATION gap: acknowledging a defect and excusing it ("residuals, minor" / "bug but whatever") is a different axis from earned-standing and is ABSENT from the control surface.
  - **Open, in order:** (a) certify the pending §2026-07-02 section WITH the user before building on it — an uncertified item treated as fact poisons everything downstream. (b) Then, as attempts for the user's blessing, each DESIGNED IN A FRESH SUBAGENT CONTEXT (not reasoned out in the main session) with tradeoffs named: an OBLIGATION principle ("a correctly-identified defect is an open item to resolve or hand off, never excuse"); the design-it-twice-as-disposition reframe; and a directed propagated-section line stressing subagents are cheaper AND cleaner than inferring in the bloated main session.
  - **Forks / uncertainty:** the obligation principle might be a disposition line vs completing the subagent surfacing-injection ("a surfaced gap is unresolved, don't reassure past it") vs other — and it's unclear whether it belongs subagent-side or main-side; the design-it-twice reframe might need no new text if the earned-standing disposition already covers it.
  - **Honest constraints (from the certified record):** text may not bind these failures (mitigation, not fix); context is append-only (no selective eviction — the only lever is a full lossy reset); genuine independence needs a different prior (a different model family, or the user), so the independent adversary (refuter) is user-triggered.

- **Ecosystem propagation residuals (2026-07-02) — owner-action, real open items (not minor).** A few repos lag harness/skill propagation. Verify specifics against repo state before acting on any one:
  - Several dirty recipients carry local, unpushed scoped commits (harness and/or C4 skills) — owner to push alongside their WIP; github-io does not push them.
  - `rhizone/server-less` carries a stray migration commit on an owner WIP feature branch (no upstream) — left for the owner.
  - `rhizone/fractal` is committed locally with **no git remote** configured (verified) — needs a remote before anything can publish.
  - `pterror/software-taxonomy` has an empty/corrupt `flake.lock` (0 bytes, verified) that blocks its toolchain (`nix develop` → its pre-commit validator); its CLAUDE.md region was deferred as owner-dirty. Needs `flake.lock` repaired, then a clean re-run of propagation.

---

## Open threads: reasoning / representation

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*

### Thread — LLM reasoning / representation / intelligence ✓ RESOLVED 2026-06-18

A long Socratic exchange the user was steering toward an unstated destination. The assistant covered a lot of true terrain (LLMs imitate reasoning; von Neumann bottleneck; 20W brain; intelligence-as-efficiency; tokens overloading representation+compute+generation; flat compute over non-flat decision density; code as the redundant *projection* of abstractions that should be data).

**RESOLVED 2026-06-18.** Destination named by the user: **there is no objective representation** (the floor), whose lived consequence — "we are forced into a single fixed representation and pay the re-translation cost by hand" — on the *editing* axis becomes **the unit of editing should be the decision, not the line**. (User's actual interest: non-LLM intelligence / better representations generally; code was the worked example.) This was explored into a full map of the *space of single-decision behavior changes* — 18 decorrelated frames → `docs/artifacts/decision-editing-space/synthesis.md` — converging on the editor-as-reconciler with organ-5 (filling spawned decisions) staffed by search + verification — decided by an exact verifier at the leaf, with a learned proposer optional and non-load-bearing, escalating to a human where no verifier exists.

Full distillation: `docs/artifacts/handoff-reasoning-thread/handoff.md` (RESOLUTION section). The decision-editing map: `docs/artifacts/decision-editing-space/` (synthesis.md + frame-1..18).

### Live follow-on — decision-granular reconciler editor (design/build direction)

The constructive landing of the resolved thread, now a live workstream. Direction: **editor-as-reconciler** — you edit a decision/desired-state; a fixpoint engine derives the mechanical shrapnel, surfaces forced spawned decisions as a worklist, proposes discretionary ones, refuses to invent irreducible bits; derived artifacts are read-only. **Organ 5 = search + verification (non-LLM intelligence): candidates searched/synthesized, decided by a cheap-total verifier-at-leaf, bounded by compositionality; a learned proposer (an LLM, if any) is optional and non-load-bearing — a branching prior that narrows the search, never the decider; escalate to a human where no verifier exists** (the four other organs — locate / edit-as-decision / store-as-decision / propagate — already ship at scale per Frame 16). **Scope to the compositional / localizable / single-owner / decidable / reversible / acyclic core**; escalate to the human elsewhere (the honest boundary). Pointer: `docs/artifacts/decision-editing-space/synthesis.md` (§7 the vision, §8 the boundary, §9 the closed loop).

### LIVE — decision-reconstruction layer design (starting context, forks marked)

The current live thread: designing the decision-reconstruction layer, with normalize as the candidate vehicle. Starting context for the next session — verify before acting.

- **Design-stage Ubiquitous Language captured** at `docs/artifacts/normalize-goal-deliberation/CONTEXT.md` — 10 terms: Decision, Changeset, Edit, materialize, Diff, Projection, Identity, Evidence, Reconstruction, Oracle. The load-bearing discipline: every layer came out **PLURAL / no single canonical "the"** — no authoritative representation/store/architecture/identity/reconstruction/decider. This is DESIGN-STAGE; terms graduate into normalize's own CONTEXT.md only once validated.

- **DEFERRED design nodes (not yet modeled):**
  - **Verification** — the verifier-at-leaf. Also the make-or-break for the whole program.
  - **forward-vs-backward** — authoring a Decision vs recovering it: one process or two?
  - **Projection pluggability** — how projections + their transformation vocabularies get registered/extended.

- **The make-or-break (recurs across all deliberation):** whether decision classes have a **CHEAP EXACT VERIFIER** ("organ 5's middle cell") — this has been *asserted, never exhibited*. Previous session was leaning toward: the cheapest validation is a **NARROW organ-5 prototype** (e.g. reconstruct decisions from one repo's commit evidence → verifier-gated fill on one decision class), NOT more deliberation. **Open fork for next session: keep modeling (the Verification node) vs. build the prototype.**

- **normalize-fit notes (starting hypotheses — verify, don't take as settled):**
  - Good vehicle for locate / edit / propagate + its "no false positives / resolved-vs-heuristic" verifier-ethos.
  - The structure-authoritative store (organ 3) is *likely a SEPARATE bet* — don't force it into normalize's legitimately text-canonical, multi-language nature.
  - Cheapest candidate moves: persist the clone-detector's structural hash as an identity primitive (it's computed then discarded today); represent edits as transformation-as-data + materialize(original)→Diff (fixes the memory-insane whole-file PlannedEdit); move propagation toward fixpoint.
  - **Contradiction to resolve:** PlannedEdit's CONTEXT.md description ("location + replacement text") contradicts the code (whole-file original/new_content). normalize's owner decides which is authoritative.

- **Pointers (not directives):** `docs/artifacts/decision-editing-space/synthesis.md` (the 18-frame map); `docs/artifacts/normalize-goal-deliberation/` (goal-deliberation frames a–d + the glossary); `docs/artifacts/handoff-reasoning-thread/handoff.md` (the original thread + its RESOLUTION note).

---

## Open threads: harness self-containment migration residuals (2026-06-17)

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*

Still-open pieces from the self-containment migration (dirty-skip / unpushed / no-remote residuals are tracked in the 2026-06-18 section below):

- **Verify anomaly: `exoplace/github-io` and `paragarden/github-io`.** These were discovered as marker-carrying repos and synced during the migration. Confirm they're legitimate ecosystem repos that should have been touched — or flag if they shouldn't be in the harness propagation set.

- **Dead references in `~/.claude/hooks/` — optional cleanup.** `inject-orchestrator-rules.sh`, `block-*.sh`, `post-history.sh`, `lib/` are now unreferenced after going fully self-contained. Safe to delete; not yet done.

- **PreToolUse block hook — deny branch unexercised.** The committed hook was confirmed loaded on a fresh session (load test passed), but its deny branch was not triggered (model complied before reaching it). A probe forcing a raw Read would confirm denial actually fires.

---

## Harness / relay-rule propagation residuals (2026-06-18)

The relay-rule scoping, ecosystem harness propagation, the additive-install-on-dirty tooling fix, and the private-name pre-commit guard are all DONE and committed (see git: `ab33b9f`, `a46821e`, `19e65b0`, `d09d439`). The 8 exposed repos were fixed and the duplicate-TODO-line cause was fixed in the tooling. Only genuinely still-open residuals remain:

- **`aeriea`, `normalize`, `private-recipient-a` — relay region committed locally, intentionally NOT pushed.** Owners review + push (standing rule); not a github-io action. `private-recipient-a`'s remote pushes under a different GitHub account (`private-account`) whose SSH creds aren't this machine's default, so its owner pushes manually — NOT being dropped from the recipient set.
- **`fractal` — no git remote configured.** Region committed local-only. Needs a remote before it can publish.
- **`software-taxonomy` — `flake.lock` is 0 bytes / corrupt** (since 2026-05-23), which broke direnv → bun → pre-commit mid-run. Needs a separate flake.lock repair.
- **Recipient-list divergence.** Harness propagation uses marker-grep discovery (~53 repos); `skill-recipients.txt` is 37 (a strict subset). Might want reconciling/documenting which list governs what.

---

## Open threads: knowledge corpus + ADR program

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*

### Thread 1 — Knowledge corpus (concept/design stage)

A new project was sketched: an "omnimedia knowledge corpus" where the corpus is the product (document-native, open JSON documents, projected via Dusklight). Foundational decisions are recorded in `docs/decisions/0001-knowledge-corpus-foundations.md` (ADR-0001). Design docs live in `docs/projects/knowledge-corpus/` as an interim home — intended to relocate to a corpus repo on github:pterror once the project is named.

**Open / advisory (verify relevance before acting):**

- **Naming.** The project and repo are unnamed. Naming is the user's call — LLM name-suggestion is banned per CLAUDE.md; the role here is to refine the conceptual space only. Most downstream work waits on this.
- **Predicate vocabulary generalization.** software-taxonomy has a predicate vocab rooted in the software domain. Open question: which predicates are universal vs lens-local — this matters before other corpora are added.
- **Corpus repo creation.** Once named: create the repo (document-native; no engine to consume — open JSON documents + per-corpus helpers, projected via Dusklight).
- **software-taxonomy refactor.** Demote to the document-native, no-blessed-metadata format: delete the EAV/triple-store layer (verified unused index), demote blessed statement fields (rank/lens/sources/qualifiers) to ordinary open-bag keys. Surgery on a working corpus — verify carefully before touching.
- **Dusklight config-driven gaps (4).** Patterns-as-Marinada, layout JSON loader, ForEach.optic eval, source-factory wiring. Projection lives entirely in Dusklight; framed as co-equal ecosystem work, not a tax on corpus work.
- **v0 end-to-end prototype.** Personal-finance fundamentals, concept-level, jurisdiction-agnostic.
- **Carried open questions:** value-layer validation (post-v0); interactive-component embedding; external query surface (deferred derived layer); corpus-construction process + LLM budgeting; content licensing; finance source scouting; whether entity-level fields (labels/aliases/description) stay conventional keys or become statements (purity vs convenience); identity scheme; literal datatype/unit handling; reference resolution.
- **Housekeeping:** annotated-law is on disk under `~/git/pteraworld/` but pushed to github:pterror (wrong folder) — might need relocating when convenient.

### Thread 2 — ADR program ✓ RESOLVED 2026-05-29

A central ADR store was established at `docs/decisions/` (ADR-0001 + a convention README). All three sub-items completed: back-fill from ecosystem repos (284 atomic ADRs mined, ADR-0002–0285), back-fill from introspection logs (same pass), and principles synthesis (`docs/decisions/throughlines.md`: 15 throughlines, 6 tensions, 11 candidate principles). All pushed.

---

## Open items surfaced by ADR synthesis

> *Follow-ups from the ADR back-fill / throughlines work. Verify relevance before acting.*

- **Promote candidate ecosystem principles into CLAUDE.md — done (7 principles).** `throughlines.md` §3 proposed ~11 candidates; 7 are now encoded in CLAUDE.md's ecosystem-common region and propagating ecosystem-wide. Two items remain open:
  - **P11 (open-models vs typed-API) held.** Its physical-layer discriminator ("persistence/interchange open, execution typed") is falsified by ADR-0192 (normalize Reports: typed structs at the interchange seam). The candidate replacement variable is authorship/closedness (open where you must absorb foreign/unforeseen constructs you didn't author; typed where you own and close the set), but that is a proposed reconciliation, not observed consensus — needs validation before canonizing. See `docs/decisions/principles-cohesion.md`.
  - **X1 hand-roll-vs-defer discriminator unstated.** The operative rule is "defer by default; hand-roll only when a dependency would violate a substrate's load-time contract (air-gapped / runtime-loadable / no-build-step)"; worth stating explicitly somewhere canonical. See `docs/decisions/principles-cohesion.md` §1.
- **Watch tension X2 during the software-taxonomy refactor.** `throughlines.md` §2 flags that software-taxonomy re-adopts the EAV triple-store pattern (ADR-0252) that the corpus thesis decided to delete (ADR-0001 §6). Reconcilable (persisted store vs ephemeral index) but it's the exact spot where the corpus thesis meets reality — revisit when the refactor happens.

---

## Open threads: bug-finding-search design

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*

### Thread 3 — Logic-bug search design (exploratory, unvalidated)

The goal under exploration is more automated discovery of *logic* bugs (not just memory-safety) in critical existing software, with rsync as the concrete target. Two design essays exist in `docs/`:

- `docs/logic-bug-oracles.md` — the online-oracle half (how to detect a bug when the search finds one)
- `docs/biasing-the-search.md` — the search half (how to steer a fault-injection search toward interesting paths)

A proof-of-concept lives at `~/git/pterror/rsync-blind-fault-oracle-spike`.

**Update — the cheap two-phase resume experiment ran (recorded in `docs/biasing-the-search.md`, empirical-result section; PoC `resume.js` + control case D).** Hypothesis tested: the naive search found zero because it searched the wrong *region* (rsync's atomic temp-then-rename path), not because rsync is fault-clean. A two-phase harness (phase 1 interrupts mid-write with one fault; phase 2 clean same-flags resume; oracle conditions on phase-2 exit vs same-flags Dref) plus a class-level bias toward the non-atomic flags reached the resume/in-place/update paths **without any branch tracing**. A hand-staged control (D) confirms the oracle is not blind to resume-skip corruption. Result: 165 violations / 3000 trials (3 seeds, ~97% reproducible), all collapsing to a flag-set requiring `-u`/`--update`, vs zero from the single-fault search.

This **answers** the "is single-fault the wrong region / does it find anything" question: yes — a cheap class-level bias finds reproducible silent omission in the non-atomic region. BUT the discrepancies are the documented `--update` footgun (newer partial → `-u` correctly skips on resume, exits 0, leaves truncated file), NOT a hidden rsync logic defect. So the clean-run-reference oracle **conflates true defects with documented-semantics footguns**. **This is not a confirmed rsync bug.** The new top open question is the footgun-vs-defect oracle gate; branch tracing is further deprioritized (a cheap bias already reached the region path-novelty was meant to find).

**Open questions / forks (updated):**

- **NEW TOP PRIORITY — footgun-vs-defect oracle gate.** A second oracle gate that classifies `-u`/`--update`-driven resume skips as expected behavior, so a remaining violation can be reported as a candidate rsync defect. Cheap, and now the actual bottleneck — ahead of the path-tracing and explore/exploit work below.
- **Search-bias region/shape hypothesis is now partly validated.** The two-phase experiment shows the search *can* be steered (by a cheap class-level flag bias) into the region where silent-omission behavior lives — against zero for the naive single-fault search. The fuller explore/exploit structure (objective path-novelty base + bounded user-tunable value portfolio + never-zero rule) remains a design argument, unbuilt. What's settled by evidence: the region was a region miss, and it was reachable cheaply.
- **Branch-level tracing is now further deprioritized (evidence against, not just absent).** Path-novelty needs branch-level tracing (compile-time instrumentation or Intel PT), heavier than the LD_PRELOAD seam. The two-phase result is direct evidence against prioritizing it: a cheap class-level bias reached the non-atomic logic region with no path tracing at all. Unbuilt and unjustified by current evidence.
- **Loop-granularity knob is the one unresolved point in the redundancy measure.** How to count a path through a loop: collapsing back-edges is objective but blind to iteration-count bugs; keeping counts catches them but explodes the space. Unsettled.
- **A key (argued) conclusion worth not re-litigating from scratch:** there is no single *objective* measure of bug-value — value is irreducibly a choice, so it belongs in the user's hands as explicit tuning, not baked into the tool. The next session may disagree, but that was the landing point.
- **Possible repo anomaly.** At session end the git ahead-count and recent commit list shifted unexpectedly — commits touching hooks and a judgment lesson appeared that this design session did not author. Might be parallel edits/pushes; worth a glance at repo state before trusting history.

---

## Open threads: skill-loading redesign follow-ups

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*

- **✅ DONE — ADR-0014 superseded by ADR-0287.** New ecosystem ADR documents the committed-`.claude/commands/` + sync-skills.sh mechanism; ADR-0014 Status line annotated "Superseded by ADR-0287" (append-only convention, non-destructive forward pointer). ADR-0014 also marked repudiated (not merely superseded).

- **Stale historical references — low-priority judgment call.** `docs/open-threads/closed.md` and `docs/artifacts/seed-design-it-twice-2026-06-15/` may reference old `tooling/claude-commands` + symlink paths. The right action depends on the role of each file: historical record (leave it) vs live instruction (fix it). Check before touching; do not assume either way.

- **aeriea unpushed — user's call.** `~/git/exoplace/aeriea` has the skill-sync commit plus 4 pre-existing unpushed commits the user wanted to handle personally. Not a github-io action item; listed only so the next session doesn't re-investigate why aeriea is ahead.

- **Dirty repos (defocus, scribble, solarium) — C4 now applied (scoped, unpushed).** The 5 previously-dirty C4 recipients (aeriea, defocus, normalize, rainbow, solarium) now have the directory-per-skill migration as a scoped additive commit — owner WIP untouched, not pushed (owner to push alongside WIP). See the C4 item above. (scribble retains its own TODO.md note; worth a look only if it stays dirty long-term.)

- **✅ DONE (2026-06-29): `.claude/commands/<name>.md` → `.claude/skills/<name>/SKILL.md` format migration.** Executed this session — see the C4 item under "Open threads: CLAUDE.md control-surface rewrite" above for the full outcome (hub migrated, `sync-skills.sh` atomic-convergent, all 37 receivers on the skills/ layout — the 5 previously-dirty repos via a scoped unpushed commit, the CLAUDE.md fence removed).

---

## Open threads: 2026-07-03 session (design-failure corpus, crescent, reincarnate, cost regime)

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*

- **Design-failure corpus (`docs/artifacts/2026-07-03-design-failure-corpus/`).** Pilot complete and committed: ledger, locked hypothesis register, blind induced taxonomy, `arbitration-notes.md` with the instruction-provenance tagging rule. Open: ~169 marked docs remain unswept — owner rejected off-meter API billing (subsidized quota preferred); on-plan Haiku agent calls were estimated at ~1-2% of a session window, cost line to owner first per harness rules. Arbitration of remaining induced patterns is the owner's, at leisure. Verification kill-rate in the pilot was 1.2% (single-vote, low effort) — possibly under-rejecting; worth a stiffness check before the sweep's records are trusted. A theory amendment from late arbitration discussion is NOT yet recorded in `arbitration-notes.md` (owner hadn't approved the write): intent-framing was refuted for the indifference case; revised mechanisms discussed were artifact-consistency overdetermination, invariant density, absence of spontaneous oracle-building, absence of frontier-recognition, and a testable "tutorial-prior/toy-architecture" hypothesis for implementation-layer failures. Confirm with the owner before recording. Essay drafting can start from the existing 425-record ledger without the sweep; prose-register pointers are in the artifact README.

- **crescent typechecker — nine abandoned versions.** Owner's diagnosis: "too poorly thought out to scale reliably." A git-history postmortem of the nine was offered, with a hypothesis to test (toy/tutorial implementation signatures: naive substitution, no level-based generalization, no constraint-solver separation). Two exits were discussed but left undecided (owner's call): pin implementation architecture by citation to a production codebase, vs. hand-write the invariant-dense core and delegate the loosely-coupled shell. Project effectively parked meanwhile.

- **reincarnate — Unknown→Value kernel settled, rename authorized.** Per introspection record, remaining work discussed was transduction into enforcing media (rename, type-level enforcement in the Rust, counterexample tests, legacy-treatment sweep) — believed delegable end-to-end and would unblock scribble; also framed as the live test of the enforcement-media theory. Unstarted, unscheduled.

- **Cost regime (context, already enforced in hooks).** Workflow tool denied unconditionally by owner directive 2026-07-03; Agent calls require an explicit model tier; frontier tiers require user-approved cost plus a `[frontier-approved]` marker. ~73% of weekly quota was consumed as of 2026-07-03 evening — sessions should budget accordingly until reset. (Relates to the `propagate-harness-all` cost-tier delegation principle already landed in CLAUDE.md's ecosystem region, 2026-07-03.)
