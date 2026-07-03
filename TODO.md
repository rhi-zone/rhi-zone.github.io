# TODO

---

## Decided, pending scaffold

- **petgraph-native structural-mining library (2026-07-02).** Decided per `docs/decisions/ecosystem/0290-petgraph-native-structural-mining-library.md` (ADR-0290; evidence in `docs/artifacts/2026-07-02-motif-engine/`). Not yet scaffolded; org = rhi-zone. Open at scaffold: final crate name (verify crates.io availability; `petgraph-` is the plugin idiom, not a forbidden self-prefix). Live, unresolved: the `franken_networkx`-publishes-to-crates.io cohesion threat, and the open gates (per-node orbit attribution / GDV-GDD, scalable k=5, lazy-iterator lifetime, VF2 induced-filter, directed k≥4).

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
