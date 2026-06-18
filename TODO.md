# TODO

---

## Open threads: reasoning / representation

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*

### Thread — LLM reasoning / representation / intelligence ✓ RESOLVED 2026-06-18

A long Socratic exchange the user was steering toward an unstated destination. The assistant covered a lot of true terrain (LLMs imitate reasoning; von Neumann bottleneck; 20W brain; intelligence-as-efficiency; tokens overloading representation+compute+generation; flat compute over non-flat decision density; code as the redundant *projection* of abstractions that should be data).

**RESOLVED 2026-06-18.** Destination named by the user: **there is no objective representation** (the floor), whose lived consequence — "we are forced into a single fixed representation and pay the re-translation cost by hand" — on the *editing* axis becomes **the unit of editing should be the decision, not the line**. (User's actual interest: non-LLM intelligence / better representations generally; code was the worked example.) This was explored into a full map of the *space of single-decision behavior changes* — 18 decorrelated frames → `docs/artifacts/decision-editing-space/synthesis.md` — converging on the editor-as-reconciler with organ-5 (filling spawned decisions) staffed by search + verification — decided by an exact verifier at the leaf, with a learned proposer optional and non-load-bearing, escalating to a human where no verifier exists.

Full distillation: `docs/artifacts/handoff-reasoning-thread/handoff.md` (RESOLUTION section). The decision-editing map: `docs/artifacts/decision-editing-space/` (synthesis.md + frame-1..18).

### Live follow-on — decision-granular reconciler editor (design/build direction)

The constructive landing of the resolved thread, now a live workstream. Direction: **editor-as-reconciler** — you edit a decision/desired-state; a fixpoint engine derives the mechanical shrapnel, surfaces forced spawned decisions as a worklist, proposes discretionary ones, refuses to invent irreducible bits; derived artifacts are read-only. **Organ 5 = search + verification (non-LLM intelligence): candidates searched/synthesized, decided by a cheap-total verifier-at-leaf, bounded by compositionality; a learned proposer (an LLM, if any) is optional and non-load-bearing — a branching prior that narrows the search, never the decider; escalate to a human where no verifier exists** (the four other organs — locate / edit-as-decision / store-as-decision / propagate — already ship at scale per Frame 16). **Scope to the compositional / localizable / single-owner / decidable / reversible / acyclic core**; escalate to the human elsewhere (the honest boundary). Pointer: `docs/artifacts/decision-editing-space/synthesis.md` (§7 the vision, §8 the boundary, §9 the closed loop).

---

## Open threads: harness self-containment migration residuals (2026-06-17)

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*

Work from this session: unified harness propagator (`propagate-harness.sh`), orchestrator hooks wired into committed `settings.json`, hooks split into lean nudge + relay(CLAUDE.md) + workflows doc, handoff distillation artifact. The self-containment migration ran across the ecosystem; these are the still-open pieces:

- **Dirty-skip / unpushed / no-remote residuals — superseded by the 2026-06-18 relay-rule propagation section below.** The 7-repos-dirty list, normalize/aeriea unpushed, and fractal-no-remote items have been re-run and refreshed there; see that section for the current state.

- **Verify anomaly: `exoplace/github-io` and `paragarden/github-io`.** These were discovered as marker-carrying repos and synced during the migration. Confirm they're legitimate ecosystem repos that should have been touched — or flag if they shouldn't be in the harness propagation set.

- **Dead references in `~/.claude/hooks/` — optional cleanup.** `inject-orchestrator-rules.sh`, `block-*.sh`, `post-history.sh`, `lib/` are now unreferenced after going fully self-contained. Safe to delete; not yet done.

- **PreToolUse block hook — deny branch unexercised.** The committed hook was confirmed loaded on a fresh session (load test passed), but its deny branch was not triggered (model complied before reaching it). A probe forcing a raw Read would confirm denial actually fires.

---

## Harness / relay-rule propagation outcome (2026-06-18)

Relay-discipline rule scoped and propagated ecosystem-wide; supersedes the 2026-06-17 dirty-skip / unpushed / no-remote residuals above.

**Done:**

- **Relay-discipline rule scoped + propagated.** No file-per-subagent; the blackboard protocol applies only to large/poisoning payloads or critic-by-path. Hub (github-io `9f4ae0f`) pushed; 41 recipients region-updated + pushed. Full orchestrator harness installed on 5 formerly-hookless repos: ascent-interpreter, claude-code-hub, private-recipient-a, keybinds, ooxml.
- **New ecosystem-loop driver `tooling/propagate-harness-all.sh`.** Convergent replace-between-markers per repo, dirty-skip-first + TODO line, `--check` dry-run, `--no-push`. Fixed a stale doc pointer (`propagate-claude-md.sh` → `propagate-harness.sh`).

**Residuals / open (cross-repo — track here):**

- **`aeriea`, `normalize` — relay region committed locally, intentionally NOT pushed.** Owner reviews + pushes (standing rule). Not a github-io action. (Folds the prior 2026-06-17 normalize/aeriea note.)
- **`private-recipient-a` — harness committed locally; push FAILS.** Remote is `git@github.com:private-account/private-recipient-a.git` (third-party account, no push access). **OPEN DECISION:** keep it as a local-only recipient, or drop it from the harness recipient set. It carries the ECOSYSTEM RULES marker, which is why it was discovered.
- **`fractal` — no git remote configured.** Region committed local-only (pre-existing). Needs a remote before it can publish. (Folds the prior 2026-06-17 fractal note.)
- **`software-taxonomy` — committed + pushed after retry.** Its `flake.lock` is 0 bytes / corrupt (since 2026-05-23), which broke direnv → bun → pre-commit mid-run. Needs a separate flake.lock repair.
- **8 dirty repos skipped with an uncommitted TODO line.** solarium, pteraworld, ashwren, fuwafuwa, defocus, rainbow, server-less, private-recipient-b. Will converge on the next clean `propagate-harness-all.sh` run. (private-recipient-b's TODO.md now has a duplicate propagation line — dedupe later.)
- **Recipient-list divergence.** Harness propagation uses marker-grep discovery (~53 repos); `skill-recipients.txt` is 37 (a strict subset). Consider reconciling/documenting which list governs what.

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

- **Dirty repos (defocus, scribble, solarium) — no action needed now.** These were skipped by the sync-skills rollout; each has a TODO.md note. They will converge on the next clean `sync-skills.sh` run. Worth a look only if they stay dirty long-term.

- **FENCED: `.claude/commands/<name>.md` → `.claude/skills/<name>/SKILL.md` format migration.** Deliberately deferred — do not start until the current committed-file mechanism stabilizes. Already documented in CLAUDE.md. Listed here for visibility only; the fence exists to prevent a mixed-format ecosystem.
