# TODO

---

## Open threads: CLAUDE.md control-surface rewrite (updated 2026-06-29)

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*

- **CLAUDE.md control-surface rewrite — DONE (2026-06-29).** See `docs/decisions/ecosystem/0289-control-surface-authoring-framework-signal-density-bright-line.md` (ADR-0289 — the spec; read it first). The editorial delete/compress/merge pass is complete: the universal axioms were de-duplicated into an embodied `## Disposition` section (failure-mode names preserved: confabulation, option-dumping, false-independence, stale-context, backpedaling); C1 resolved by scoping (unsure-whether-it-warrants-the-process → treat as if it does; unsure-about-fact/intent → ask/verify) and C2 resolved toward orchestrator mode; the dangling `docs/decisions/throughlines.md` pointer **and** the eight use-case-taste "Ecosystem Design Principles" bullets were removed from the propagated region (taste bullets verified covered in throughlines.md first); management policy compressed into the github-io-local region. The final axiom set is now **settled** (S1/S2/E1/E2/P1 re-derived under universality+embodiment into `## Disposition`). **Both open forks resolved by the user, both toward PROPAGATED:** the hard main-session-orchestrator disposition is kept in the propagated region (under `## Delegation & relay`), and "finish migrations before building on top; fence what you can't finish" is kept in the propagated region under `## Disposition`.

- **Orchestrator-hook finding — nothing to promote (2026-06-29).** Earlier premise was that the orchestrator-only enforcement lived in the un-propagated `settings.local.json` and needed promoting. It does NOT: it is already a committed `PreToolUse` hook (`tooling/claude-hooks/block-mainsession-exploration.sh`) wired through committed `.claude/settings.json`, already in the harness propagator's managed path set — so it **already propagates** to every marker-bearing receiver. Only residual action: convergence verification (`tooling/propagate-harness-all.sh --check`) when propagation runs.

- **C4 — commands→skills migration — DONE (2026-06-29).** The directory-per-skill migration was executed and is largely complete. Hub: 8 canonical skills moved from flat `.claude/commands/<name>.md` to `.claude/skills/<name>/SKILL.md` (history-preserving renames; handoff/polish gained a `name` field, kept allowed-tools/argument-hint; the 3 already-directory skills moved wholesale, cross-links intact). `sync-skills.sh` rewritten to source `.claude/skills` (directory-only) and to converge receivers ATOMICALLY — each receiver's single commit writes the new `skills/` AND removes that repo's old ecosystem-skill files under `commands/` (keyed strictly to managed skill names; repo-local commands untouched). CLAUDE.md skill-propagation prose updated (canonical location is now `.claude/skills`; the deferred C4 fence REMOVED) and skill-tiers header updated. **Receiver rollout: 32 of 37 recipients on the skills/ layout** (27 migrated+pushed this session + 4 already-converged; a few are "mixed" only in retaining their own repo-LOCAL commands). **5 dirty recipients (aeriea, defocus, normalize, rainbow, solarium) dirty-skipped** — they stay on `commands/` until clean; a re-run of `sync-skills.sh` converges them (idempotent/atomic). One repo (rhizone/server-less) carries an earlier stray migration commit on an owner WIP feature branch (no upstream) — left for the owner; safe manual recovery is `git reset --hard HEAD~1 && git clean -fd .claude/skills` (the stray commit touches only `.claude/commands/` deletions). (See also the FENCED format-migration item under "skill-loading redesign follow-ups" below — now resolved by this work.)

- **Propagation + github-io push — EXECUTED 2026-06-29 (largely complete).** No longer held — the 54-repo harness propagation was run this session. Hub (github-io) is now pushed to origin/master: commits `2c90224` (CLAUDE.md control-surface rewrite) and `33c1620` (propagation-resilience fix). The previously-listed unpropagated drift shipped as part of this propagation: SendMessage fix (`fb1f9c1`), plan-mode stand-down (`8d6b2d9`), and the orchestrator-rules "command → stance" rewrite (`87cde38`).
  - **Resilience fix `33c1620`:** `tooling/propagate-harness-all.sh` previously aborted the whole 54-repo batch on a single receiver push failure (`set -euo pipefail` + unguarded push in a subshell). It now isolates per-repo failures (`process_one_repo ... || FAILED+=`), prints a classified end-of-run summary (SUCCEEDED / DIRTY-ADDITIVE / SKIPPED-DEFERRED / FAILED+reason), and exits non-zero iff any FAILED.
  - **Rollout result (54 marker-bearing repos):** 39 clean repos committed + pushed (this is where the dangling `throughlines.md` reference / old propagated region got replaced — the fix is now live in the clean set); 9 dirty repos got harness-only additive commits (never pushed, per policy); 3 skipped/already-current (incl. one expected-skip recipient that converged to a no-op; its push fails by design under separate production credentials, treated as fine).
  - **3 residual FAILURES — all owner-action, left in safe states (NOT forced):**
    - `rhizone/fractal`: no git remote configured; harness change committed locally (`6088283`), nothing to push to (likely intentional local-only).
    - `rhizone/normalize`: its own `normalize rules run` pre-commit rule errors `missing-summary` because the harness commit touches `tooling/claude-hooks/`, which has no `SUMMARY.md`. Needs `tooling/claude-hooks/SUMMARY.md` added in normalize, then re-run (harness-only, no push — it's dirty). Will recur on every propagation until that file exists.
    - `pterror/software-taxonomy`: committed `flake.lock` is empty/corrupt (0 bytes), so `nix develop` can't load bun for its pre-commit validator. Needs `nix flake update` + commit, then re-run (clean → commit + push).

- **Propagate-harness tooling follow-ups (discovered 2026-06-29 — not yet implemented).**
  - **Commit receivers inside each receiver's OWN dev env.** `propagate-harness` should commit each receiver via its own environment (e.g. `direnv exec <receiver> ...`), not the hub's env — otherwise receivers with tool-dependent pre-commit hooks (cargo/bun) fail spuriously. Gotcha for any fix: nested `direnv exec` SWAPS rather than stacks envs.
  - **Ship a `SUMMARY.md` inside the propagated `tooling/claude-hooks/` payload** so doc-completeness rules (like normalize's `missing-summary`) don't block the harness commit.
  - **Private-names guard had a commit-MESSAGE gap — closed for github-io (2026-06-29).** The `.githooks/pre-commit` private-names guard scans staged file CONTENT but not the commit MESSAGE, so a denylisted name leaked into a commit message in pushed public history this session. Remediated: rewrote the affected commit messages (non-interactive `git filter-branch --msg-filter`), force-pushed `master` with lease, and dropped the local backup ref so the old object is unreachable; added a new `.githooks/commit-msg` hook that scans the message against the same denylist. (Caveat for the record: a public force-push does not guarantee the old SHA is purged from upstream caches/forks.)
  - **Pre-commit re-stage bug — FIXED (2026-06-29), with an open ecosystem-wide sweep.** Latent bug (independent of C4, surfaced by it): scaffolded `.githooks/pre-commit` hooks re-staged after formatting via `git diff --cached --name-only | xargs git add`, which re-adds DELETED paths and fatally aborts ANY commit containing a deletion (this blocked the commands-removal commits). Fixed the scaffold TEMPLATE (`scaffolding/.githooks/pre-commit`, commit `cdc4500`) with `--diff-filter=ACMR`, and fixed the 11 live receiver hooks carrying it (concord, deskspace, gels, moonlet, motif, myenv, nanites, scribble, tiltshift, noncanon, annotated-law — each committed+pushed). **OPEN FOLLOW-UP:** the scan covered only the 37 skill-recipients; repos OUTSIDE that set may still carry the unguarded re-stage pattern — an ecosystem-wide sweep would catch them.
  - **OPEN — propagate the `.githooks/` private-names guards ecosystem-wide.** Both guards (`pre-commit` content-scan + new `commit-msg` message-scan) are github-io-LOCAL only — the harness propagator ships `tooling/claude-hooks/` (behavioral hooks), NOT `.githooks/`. Making the private-names guard ecosystem-wide is a separate propagation change: teach the propagator to ship `.githooks/` and run `git config core.hooksPath .githooks` in receivers, with each repo maintaining its own machine-local `.git/info/private-names` denylist.

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

- **Dirty repos (defocus, scribble, solarium) — no action needed now.** These were skipped by the sync-skills rollout; each has a TODO.md note. They will converge on the next clean `sync-skills.sh` run. Worth a look only if they stay dirty long-term.

- **✅ DONE (2026-06-29): `.claude/commands/<name>.md` → `.claude/skills/<name>/SKILL.md` format migration.** Executed this session — see the C4 item under "Open threads: CLAUDE.md control-surface rewrite" above for the full outcome (hub migrated, `sync-skills.sh` atomic-convergent, 32/37 receivers on the skills/ layout, 5 dirty deferred, the CLAUDE.md fence removed).
