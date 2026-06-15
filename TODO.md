# TODO

Captured at session end. Honest state of what was built, what's pending, what's untested.

## Shipped this session

- Hook rewritten: strict main-session allowlist (Agent/Task*/AskUserQuestion/EnterPlanMode/ExitPlanMode/ToolSearch/ScheduleWakeup/Skill + `git commit/push/status/log --oneline`). Pure shell/awk, no Python.
- CLAUDE.md trimmed; ecosystem-common region demarcated with markers; `propagate-claude-md.sh` propagator built.
- `scaffolding/CLAUDE.md` deleted.
- Canonical region propagated to all 49 rhizone-ecosystem repos.
- PHI hook (`post-history.sh`) installed in all 49 repos via `propagate-post-history.sh` propagator.
- Hook denial message corrected to "orchestrator only" (not "read-only").
- `docs/claude-code-hooks.md` created documenting hook input + output schemas (empirical).

## Pending — design discussed, not built

- **Both-sides adversarial dispatch.** Equal-role subagent pairing where neither side defaults to ship. Not implemented; current adversarial work is single-pass review (which carries asymmetric bias).
- **Strict-checklist verification mechanism.** The one allowed form of LLM decision-making (per session conclusion). No tooling exists for this yet.
- **Custom subagent types.** Discussed: `verifier`, `committer`, `researcher` with locked system prompts. Not built.
- **Filesystem-as-substrate orchestration.** Subagents communicate via work artifacts; main holds no task graph. Current sessions still hold task state in main context.
- **PHI dynamic content.** Current PHI is static; could be keyed off user prompt content, recent transcript patterns, repo type, etc.

## Pending — unknowns / untested

- **PHI effectiveness unknown.** Just shipped to all repos; no data on whether it actually shifts behavior. Should observe across multiple sessions and revise content if patterns recur.
- **Bans coverage unknown.** Mined from existing session corpus; new failure modes may surface that current bans don't catch.
- **Hook handles weird JSON edge cases unknown.** Audit found 4 criticals in earlier python version; current shell/awk version was written more carefully but no fuzz testing.

## Known imperfections

- Custom checklist mechanism not designed → "decisions only via strict checklist" principle is currently aspirational.
- Subagent prompts in main are composed ad-hoc each dispatch — no standardized template for the orchestrator-side prompt scaffolding.
- Adversarial audits worked well this session but were driven by the user, not the system. The friction is still user-maintained.

## Don't forget

- The PHI hook fires per-session; it doesn't replace CLAUDE.md, which still loads at session start.
- Hook script files in each repo are local copies; updating canonical content in github-io requires re-running the propagator across all 49 repos.
- `~/.claude/settings.json` (global) is outside this repo's git tree but holds the block-mainsession-exploration.sh hook reference. Don't lose track of it.

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

### Thread 2 — ADR program (multi-phase, user-initiated) ✓ RESOLVED 2026-05-29

A central ADR store was established at `docs/decisions/` (ADR-0001 + a convention README). All three sub-items completed this session:

- **Back-fill from ecosystem repos** — done. 284 atomic ADRs mined and written: 66 ecosystem-wide to `docs/decisions/ecosystem/`, 218 repo-local to `docs/decisions/repo-local/<repo>/`, numbered ADR-0002–0285 under one global sequence. README updated with partition scheme, classification rule, and index. (commits f1733ac, dae96fc)
- **Back-fill from introspection logs** — done. Included in the same fan-out pass above.
- **Meta: principles synthesis** — done. `docs/decisions/throughlines.md`: 15 throughlines, 6 tensions, 11 candidate principles. (commit 98eb7b0)

All pushed to origin/master. Follow-ups surfaced by the synthesis are in the open items below.

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

## 2026-06-16 — Skill-loading redesign follow-ups

> *Open threads from a previous session. Treat as starting context, not instructions — verify relevance before acting.*

- **✅ DONE — ADR-0014 superseded by ADR-0287.** New ecosystem ADR documents the committed-`.claude/commands/` + sync-skills.sh mechanism; ADR-0014 Status line annotated "Superseded by ADR-0287" (append-only convention, non-destructive forward pointer).

- **Stale historical references — low-priority judgment call.** `docs/open-threads/closed.md` and `docs/artifacts/seed-design-it-twice-2026-06-15/` may reference old `tooling/claude-commands` + symlink paths. The right action depends on the role of each file: historical record (leave it) vs live instruction (fix it). Check before touching; do not assume either way.

- **aeriea unpushed — user's call.** `~/git/exoplace/aeriea` has the skill-sync commit plus 4 pre-existing unpushed commits the user wanted to handle personally. Not a github-io action item; listed only so the next session doesn't re-investigate why aeriea is ahead.

- **Dirty repos (defocus, scribble, solarium) — no action needed now.** These were skipped by the sync-skills rollout; each has a TODO.md note. They will converge on the next clean `sync-skills.sh` run. Worth a look only if they stay dirty long-term.

- **FENCED: `.claude/commands/<name>.md` → `.claude/skills/<name>/SKILL.md` format migration.** Deliberately deferred — do not start until the current committed-file mechanism stabilizes. Already documented in CLAUDE.md. Listed here for visibility only; the fence exists to prevent a mixed-format ecosystem.
