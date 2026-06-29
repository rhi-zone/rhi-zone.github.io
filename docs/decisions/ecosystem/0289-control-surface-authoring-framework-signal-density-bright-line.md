# ADR-0289: Control surface (CLAUDE.md) — authoring framework and main-session ingestion as a signal-density bright line

## Status
Accepted — rewrite implemented 2026-06-29; propagation executed 2026-06-29 (39 pushed / 9 dirty-additive / 3 skipped / 3 residual owner-action). C4 open.

## Resolution (2026-06-29)

The editorial rewrite is **DONE** this session — a faithful delete/compress/merge pass, not a redesign:

- The universal axioms were de-duplicated into an embodied `## Disposition` section (failure-mode names preserved: confabulation, option-dumping, false-independence, stale-context, backpedaling). The final axiom set is now **settled** — S1/S2/E1/E2/P1 re-derived under the universality+embodiment lens into `## Disposition`.
- Contradiction **C1** resolved by scoping: unsure-whether-a-decision-warrants-the-full-process → treat as if it clears the bar; unsure-about-a-fact/intent → ask/verify. **C2** resolved toward orchestrator mode (implementation happens in subagents, not the main session).
- The dangling `docs/decisions/throughlines.md` pointer **and** the eight use-case-taste "Ecosystem Design Principles" bullets were **removed from the propagated region** (the taste bullets were verified covered in throughlines.md before deletion).
- Management policy (sync-skills, doc-sync checklist, scaffolding, org table, crate naming, docs-site, activity logs) compressed into the github-io-local region. The C4 commands→skills fence compressed to a one-line deferred/held note.

**Both open forks resolved by the user — both toward PROPAGATED:**
- *Orchestrator stance* — the hard "main session is an orchestrator, never ingests raw foreign content, guessing is not an available move" disposition is **kept in the propagated region** (under `## Delegation & relay`).
- *Migration axiom* — "finish migrations before building on top; fence what you can't finish" is **kept in the propagated region** under `## Disposition` (a universal work-discipline axiom — unfinished migrations leave pre-migration code as active context-poisoning).

**Orchestrator-hook finding** (corrects the §2 / "Still open" promote premise): the orchestrator-only enforcement is **already** a committed `PreToolUse` hook (`tooling/claude-hooks/block-mainsession-exploration.sh`) wired through committed `.claude/settings.json` and already in the harness propagator's managed path set — so it **already propagates** to every marker-bearing receiver. Nothing to promote; the only residual is convergence verification (`tooling/propagate-harness-all.sh --check`) when propagation runs.

**Propagation — EXECUTED 2026-06-29 (no longer held).** The 54-repo harness propagation was run. Hub (github-io) pushed to origin/master: `2c90224` (CLAUDE.md rewrite) and `33c1620` (propagation-resilience fix — per-repo failure isolation + classified end-of-run summary, replacing the old whole-batch abort-on-first-push-failure). Rollout: 39 clean repos committed + pushed (the dangling `throughlines.md` reference / old propagated region is now replaced and live in the clean set); 9 dirty repos got harness-only additive commits (never pushed, per policy); 3 skipped/already-current (incl. one expected-skip recipient — converged to a no-op; its push fails by design under separate production credentials). 3 residual FAILURES, all owner-action and left safe: `rhizone/fractal` (no remote; committed local-only `6088283`), `rhizone/normalize` (`normalize rules run` errors `missing-summary` — `tooling/claude-hooks/` lacks a `SUMMARY.md`), `pterror/software-taxonomy` (0-byte/corrupt `flake.lock` blocks `nix develop` → bun validator). **Tooling follow-ups discovered (deferred):** commit receivers inside each receiver's own dev env (`direnv exec <receiver> ...`; note nested `direnv exec` swaps rather than stacks envs); ship a `SUMMARY.md` in the propagated `tooling/claude-hooks/` payload so doc-completeness rules don't block the harness commit.

**Still open:** C4 — the actual `.claude/commands/*.md` → `.claude/skills/<name>/SKILL.md` migration (only the fence *text* was compressed; the migration itself is deferred).

## Context

CLAUDE.md grew by ad-hoc accretion into a large, internally-contradictory, low-signal rule pile. Failure modes observed ecosystem-wide: baseless option-dumping and confident-wrong decisions; skills (esp. design-it-twice) triggering inconsistently because conditional rules fire unreliably; cross-artifact contradictions (CLAUDE.md vs injected hooks); and the document violating its own anti-accretion rule. Three adversarial audits this session located the concrete defects (see Evidence).

## Decision

### 1. Authoring framework — two axes

**Include test: universality.** Content earns a place in the always-on surface only if it applies across essentially all of the agent's work (universal behavioral or thought-/design-shaping axioms). Use-case-specific taste (e.g. "LLM as oracle at the leaves / determinism as invariant", "prefer data over code at a seam"), conventions, and reference material do NOT belong — they relocate to the relevant project/design docs (consulted when relevant) or to github-io's local management region. A conditional preference stated as an always-on rule gets pattern-matched into contexts where it doesn't apply and derails them.

**Form: embodiment, not guardrails.** Universal axioms are written as embodied disposition (what the agent *is* and how it thinks), not external rules to check against. A rule is a conditional gate: it fires unreliably and invites compliance-performance over thinking. An embodied principle shapes generation continuously — no trigger to miss. Caveats: (a) embodiment must cash out in concrete observable behavior ("value rigor" is fluff — name what the agent *does* differently); (b) genuine bright lines stay flatly non-negotiable; embodiment may carry the hardness but must not soften it into a vibe.

**Corollary — no ad-hoc rules.** When something breaks, repair or add a *principle*, never bolt on a patch. The file must be structurally incapable of growing into a rule-list. (Also recorded as the "Authoring the control surface" meta-note in CLAUDE.md, commit 0d9d2ba.)

### 2. Main-session-as-orchestrator (resolves "orchestrator-only vs loosen")

**Decision:** keep the hard block on the main session ingesting raw, autonomously tool-retrieved foreign content. The main session ingests only (a) the user's direct input and (b) attenuated digests from its own subagents — never raw file/command output.

**Primary justification — signal density.** The control loop's decision quality is a function of its context's signal-to-noise. Raw foreign material (pre-refactor code is *anti-signal* — it anchors the model to the state being left) plus verbose self-reasoning dilute and, via softmax normalization, actively *suppress* the user's direction (a small, positionally-buried fraction of tokens). Always-on degradation, not a tail risk; universal — passes the include-test with no dial.

**Secondary justification — trust/contamination.** Foreign content can carry injection or subtly shift priors/goals. Main-session contamination is uniquely bad: persistent, propagating (it poisons the briefs of every subagent subsequently spawned), silent, and irreversible — categorically worse than disposable, scoped subagent contamination. A tail-risk layer atop the S/N case.

**Confabulation cure (distinct from the block).** The block creates a cost gradient (verify = expensive spawn; guess = free), which tempts confabulation. The cure is NOT to loosen the block and allow direct reads — it is the embodied disposition: *the orchestrator does not answer world/codebase questions from its own priors; its only epistemic act is route -> reason over the returned, attenuated digest.* Guessing is removed as an available move. Relay/blackboard is the mechanism: the subagent writes raw evidence to a file the orchestrator never opens and returns a path + attenuated, provenance-marked digest.

**What was actually broken** (the restriction itself was right): its stated rationale (was "context-size"; is actually S/N + trust), the missing confabulation cure, and SendMessage being absent from the orchestrator allow-list (fixed, commit fb1f9c1).

### 3. Region rules for the rewrite

- Two regions. The **propagated region** (between the BEGIN/END ECOSYSTEM RULES markers, ships to ~54 repos) must be **self-sufficient and universal** — only compress-inline or delete; never a pointer to github-io-local docs. The **github-io-local** content (outside the markers) may be cut aggressively and may point to local docs.
- **Live defect to fix:** the propagated region currently references docs/decisions/throughlines.md, which exists only in github-io — a dangling reference already shipped to ~10 receivers. Remove it from the propagated region.

### 4. Shrink method

Editorial reduction, NOT design-it-twice (narrow design space — subtraction against known principles + verification, not open-ended design). Operations: **delete** (not load-bearing), **compress-inline** (load-bearing), **merge** (duplicates). Every retained line must earn its place by a concrete behavior it changes.

## Still open

- ~~Final axiom set~~ — **DONE (2026-06-29).** Settled: S1/S2/E1/E2/P1 re-derived under universality+embodiment into `## Disposition` (alongside the already-settled D1 dropped, P2 hardened to no-ad-hoc, and the frame).
- ~~The rewrite itself~~ — **DONE (2026-06-29).** Editorial delete/compress/merge pass complete; both forks resolved toward propagated (orchestrator stance kept; migration axiom kept — see Resolution above).
- ~~Orchestrator-hook promote~~ — **moot (2026-06-29).** The enforcement is already a committed, already-propagating `PreToolUse` hook; nothing to promote. Only residual: convergence verification when propagation runs.
- C4: finish the `.claude/commands/*.md` -> `.claude/skills/<name>/SKILL.md` migration, or drop the self-exempting fence (the repo is currently in the mixed state its own fence names as the failure mode). **Still open** — only the CLAUDE.md fence *text* was compressed this session; the migration itself was NOT done.
- ~~Propagation (54 repos) + github-io push~~ — **DONE 2026-06-29.** Executed: hub pushed (`2c90224`, `33c1620`); 39 clean pushed / 9 dirty-additive / 3 skipped / 3 residual owner-action (`fractal` no-remote, `normalize` missing-summary, `software-taxonomy` corrupt flake.lock). The previously-pending drift (SendMessage fix `fb1f9c1`, plan-mode stand-down `8d6b2d9`, orchestrator-rules stance rewrite `87cde38`) shipped with this propagation. See Resolution for the full outcome + tooling follow-ups.

## Evidence (this session's adversarial audits)

- **Contradictions:** C1 — "when unsure, treat as if it clears the bar" (twin-stated in CLAUDE.md Meta + design-it-twice section 1) vs "Unclear? Ask / verify" (hooks). C2 — "Clean repos: make the changes directly" vs "Implementation happens in subagents, not here". C4 — "Do not half-migrate" fence vs the repo's own tolerated mixed commands/+skills/ state.
- **Redundancy:** verify/evidence rule stated 3x; "re-read the source" 2x; design-it-twice discipline 3x (Meta prose + two skills).
- **Monkeypatches:** several single-incident rules; the file violates its own "rules added only on recurring failure" gate.
