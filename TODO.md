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
