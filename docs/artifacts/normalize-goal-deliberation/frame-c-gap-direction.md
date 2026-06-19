# Frame C — Gap / Direction Analysis: `normalize` vs. the Reconciler Goal

**Question:** Where is normalize's direction RIGHT, where WRONG, what's MISSING, relative to the
editor-as-reconciler goal (decision-as-unit-of-edit; five organs; non-LLM intelligence; name-independent
entity identity). Operate at direction/design, not implementation minutiae.

**Method note.** I took the "verified this session" reality as given but spot-checked the load-bearing
claims against the actual source, because the verdicts hinge on them. Two checks materially sharpened the
analysis and are flagged inline as *verified*:

- `normalize-refactor` is split Actions → Recipes → Executor; the edit data type it produces is
  `PlannedEdit { file, original, new_content, description }` (verified, `crates/normalize-refactor/src/lib.rs:23`).
- The structural index is a real SQLite store (facts index + `embeddings` table; `cfg_*` tables). The
  clone/skeleton hash (`compute_function_hash`, `normalize-code-similarity`) is computed only in the
  analyze pipeline (duplicates/fragments) and is **not** written to the index as an identity key — grep
  for any persisted structural-hash column returns nothing (verified).

These two facts are the spine of the whole analysis, so I state the conclusions with confidence; the
softer architectural judgments below are flagged where I'm inferring intent rather than reading code.

---

## 1. Aligned — assets that are the goal's organs *in embryo*

These are real, not aspirational. Each is a partial instance of a goal organ.

- **Structural-over-textual as the founding axiom (organ-1 Locate: mature).** Normalize's entire premise
  is "code at a structural level (AST, control flow, dependencies) rather than as text." Locate is the
  organ that already works at goal-grade: tree-sitter parse → facts index → symbol/call graph → CFG
  (`cfg_blocks/defs/uses/edges`). The reconciler's organ-1 is *here today*, across 98 languages. This is
  the single most valuable asset and it is irreplaceable — building it from scratch elsewhere would cost
  years.

- **The clone/skeleton hash as latent name-independent identity (organ toward identity).** `normalize-code-similarity`
  computes a normalized AST hash with identifier/literal elision (`compute_function_hash`,
  `serialize_structural_tokens`, skeleton-mode body replacement) plus MinHash-LSH. This is *exactly* the
  function the goal needs for name-independent identity — a content-addressed structural fingerprint.
  It exists and is computed correctly. (It is not yet *used* as identity — see §2/§3.)

- **`PlannedEdit`/`RefactoringPlan` + Actions/Recipes/Executor split (organ-2 Edit-as-decision: partial,
  *and the partiality is informative*).** The refactor crate already separates "query/mutation primitives"
  (Actions) from "compositions into plans" (Recipes) from "apply/dry-run/shadow" (Executor). The instinct
  to make the plan a *value* that is computed, inspected (dry-run), then applied is the right seam — it is
  the goal's plan/apply split. (The data on that seam is the *wrong* data — §2 — but the seam itself is in
  the right place.)

- **"No false positives" as a verification ethos (organ-5 verifier-gating in embryo).** The flagship bar —
  semantically-correct refactoring with no false positives, `confidence: "resolved" | "heuristic"` tags on
  every cross-file reference — is *precisely* organ-5's discipline: a transformation is only accepted when
  it can be exactly verified, and unverifiable cases are flagged rather than guessed. Normalize already
  refuses to let a heuristic masquerade as a fact. That ethos is the hard part of organ-5; it's cultural,
  and it's already the house style.

- **Library-first projection-from-one-definition (architecture aligned).** One typed core → CLI / JSON /
  MCP / HTTP / LSP projections. This is a direct match to the goal's "structure authoritative, text
  projected" *shape of thinking* — normalize already believes surfaces are projections of one definition.
  The goal asks it to apply that same belief one level deeper (text itself becomes a projection).

- **Shadow-git edit tracking (proto-provenance).** `.normalize/shadow/` records edit history structurally.
  This is a weak embryo of organ-3's "store the decision, not just the result" — it keeps *what changed*,
  not only the after-image. Weak because it tracks text edits, but the instinct to persist edit history as
  first-class data is aligned.

---

## 2. Divergent — each claim adjudicated (wrong-for-goal vs. defensible scoping)

| Tension | Verdict | Reasoning |
|---|---|---|
| **Text-canonical vs. structure-authoritative** | **Genuinely wrong-for-goal — but the cheapest divergence to flip, because it's a *polarity* not a *missing component*.** | The store exists (SQLite facts + CFG + embeddings); it is merely declared *derived*. The goal needs the same store declared *authoritative*, with text as the projection. This is the deepest philosophical fork (organ-3), but normalize has already built the artifact it would need to invert — it just points the arrow the other way. For its *stated* goal (be a tool over 98 arbitrary, externally-owned, dynamic languages where the user's editor and git own the text) text-canonical is *correct and necessary*. So: wrong for the reconciler, right for normalize's own mission. This is the cleanest case of "good tool, different goal." |
| **Refactors-as-code vs. transformation-as-data** | **Wrong-for-goal, and sharper than stated: the data that *does* exist is the wrong data.** | The seam is right (plan → apply) but `PlannedEdit = {file, original, new_content, description}` (verified) is a *resolved text-replacement diff* — the projected *output* of a decision, not the decision. The decision was "rename entity #E to N" or "extract lines L into a function"; what's serialized is the after-text. You cannot replay, re-target, or re-verify a `PlannedEdit` against a changed tree — it's already collapsed to text-vs-text. The recipes (rename/extract/inline/move) remain hardcoded Rust. So organ-2 is *more* divergent than "partial" suggests: it has a data type at the seam that actively encodes the wrong abstraction level. Not defensible scoping — it's a representation choice that fights the goal. |
| **Single-pass vs. fixpoint propagation** | **Wrong-for-goal; defensible only as far as the current operation set goes.** | Normalize propagates once (rename updates call sites; add-parameter updates call sites once). The goal's organ-4 requires iterating to a fixpoint because a determined edit *spawns* further determined shrapnel (a changed signature changes a caller, which changes *its* callers' inference, …). Single-pass is adequate for today's shallow refactors and *inadequate by construction* for decision-propagation. Defensible as scoping *only* while edits stay one-hop; the moment edits compose, it's wrong. |
| **Similarity-as-search vs. similarity-as-identity** | **Wrong-for-goal — and this is the highest-leverage divergence to flip (see §4).** | Verified: the structural hash is computed but never persisted as an index key; identity-for-lookup is name/path-based. The goal's name-independent, rename-surviving entity identity is *one persistence step* away from an asset that already exists. Treating the hash as a report metric instead of a primary key is the divergence. Not defensible — it's leaving the goal's hardest-to-build asset switched off. |
| **Breadth (98 langs) vs. depth** | **Not divergent — defensible, and the project already agrees.** | Stated direction is explicitly depth-over-breadth now ("languages saturated"). Breadth is a *sunk asset* that makes the reconciler more valuable (a cross-language reconciler beats a single-language one). No conflict. The only risk is if breadth maintenance starves depth investment — a resourcing question, not a direction error. |
| **Human/LSP refactoring vs. reconciler's decision-editing** | **Partly divergent — a framing ceiling, not a wrong turn.** | "JetBrains parity via LSP" anchors normalize to *replicating the existing IDE refactoring UX* — a fixed menu of human-named operations (rename/extract/inline/move) delivered to a human at a cursor. The goal's model is open-ended decision-editing where the *unit* is an arbitrary decision and the *operator* is search+verify, not a human picking from a menu. LSP-parity is a *subset* of the goal (every IDE refactor is a decision), so it's not opposed — but it's a ceiling: optimizing for parity means hardcoding the menu (→ refactors-as-code) and targeting a human-in-the-cursor loop rather than a reconciler engine. Defensible as a near-term revenue/credibility target; divergent if it becomes the terminal vision. |

**Net:** four genuine wrong-for-goal calls (text-canonical, edit-data-shape, single-pass, similarity-not-identity),
one non-issue (breadth), one framing-ceiling (LSP-parity). Crucially, *three of the four* are
polarity-flips or persistence-flips on assets that **already exist**, not missing components.

---

## 3. Missing — true gaps (nothing in-repo to flip)

- **Organ-3 authoritative store — MISSING as authority, PRESENT as artifact.** The store exists; the
  *authority relation* (structure is source, text is projection; edits land on structure, text regenerates)
  does not. The missing piece is a faithful **text projection / regeneration** path (structure → text that
  round-trips losslessly, preserving formatting/comments) — without it you cannot invert the polarity. This
  is the largest genuinely-new build, and it's hard precisely because of the 98-language breadth (lossless
  un-parse per grammar).

- **Organ-5 search+exact-verify — MISSING as a loop.** The *verifier ethos* exists (§1) and the *search*
  primitives exist (similarity, embeddings, facts queries). What's missing is the **closed loop**: spawn a
  decision → search candidate fillings (non-LLM: structural/embedding/constraint search) → verify each
  exactly → accept only verified, flag the rest. Today search and verification are separate user-invoked
  commands, not an automated propose→verify→accept engine. LLM-as-branching-proposer-only is entirely absent
  (and consistent with normalize's "LLM is an oracle at the leaves" house principle).

- **Persistent name-independent identity + entity lineage — MISSING as persistence (the hash exists).**
  No entity-id is assigned, persisted, or tracked across edits/renames/versions. The lineage graph
  (this entity in v2 *is* that entity in v1, despite a rename) does not exist. This is the goal's identity
  spine and it is the cheapest gap to start closing because the fingerprint is already computed (§4).

- **Fixpoint / incremental propagation engine — MISSING.** No worklist/fixpoint iterator that re-derives
  shrapnel until stable. (Incremental re-indexing exists for the *index*; decision-propagation-to-fixpoint
  does not.)

- **Spawned-decision enumeration — MISSING.** No notion that applying a determined edit *creates* new
  open decisions to be filled. This is the connective tissue between organs 2→4→5 and there is no embryo of
  it; it depends on the edit-as-decision representation (§2) existing first.

---

## 4. Cheapest high-leverage moves (2–4)

Ordered by leverage-per-cost. The first two are **promote/wire what exists**; the last two are **build**.

1. **Persist the structural hash as an identity key (WIRE, highest leverage / lowest cost).** Add a
   `structural_id` column to the symbol/facts index populated from `compute_function_hash`. Cost: one schema
   migration + one populate call (the hash function already exists and is correct). Payoff: turns
   similarity-as-search into similarity-as-identity, unlocks the *entire* identity spine (lineage, rename-
   survival, entity-tracking), and is the prerequisite for organ-2's "locate by identity not name." This is
   the single best move: it switches on an already-built asset that the goal cannot do without.

2. **Re-shape the edit data from `PlannedEdit` (text diff) to a decision value (WIRE/REFRACTOR).** Introduce
   a serializable `Decision`/`Transformation` type that records *intent + identity-targeted location +
   parameters* (e.g. `Rename{entity: structural_id, to}`, `Extract{range, …}`), with `PlannedEdit` demoted
   to its *projection*. The Actions/Recipes/Executor seam already wants this; you're changing what flows on
   it, not adding a seam. Payoff: organ-2 becomes real (transformation-as-data: cacheable, replayable,
   re-targetable, exactly-verifiable), and it's the precondition for spawned-decisions and fixpoint. Cost is
   moderate (recipes stay, but now *emit* Decisions); the existing recipes become the first library of
   decision-constructors.

3. **Close the search→verify loop for *one* decision type (BUILD, scoped).** Take rename (the maturest
   operation), and wire: spawn open "what is the new name's binding here?" decisions → search candidates via
   facts/similarity → verify exactly via the existing resolver (`confidence: resolved`) → accept only
   verified, flag heuristics. This proves organ-5 end-to-end on the safest case, reusing the existing
   verifier ethos and search primitives. Deliberately *not* general — a worked example that validates the
   loop shape before generalizing.

4. **Add a fixpoint worklist around propagation (BUILD, small).** Replace single-pass call-site update with
   a worklist that re-enqueues newly-affected entities until stable. Small once edits are Decisions (move 2)
   — it's a loop around an existing step. Lower priority than 1–3 because it only pays off once edits compose,
   but it's cheap and removes a by-construction wrong.

**Explicitly deferred (too expensive for the leverage *now*):** the lossless 98-language text-regeneration
path required to invert text↔structure polarity (organ-3 authority). Build it only after 1–3 prove the
decision model; until then, structure-derived-from-text + identity-persisted is enough to demonstrate the
whole reconciler *except* store-authority.

---

## 5. The honest verdict

**Good vehicle, partial-needing-redirection — NOT fundamentally mismatched.** Confidence: high on the
asset inventory (verified against source); medium on the redirection cost estimates (inferred from
architecture, not measured).

The case for "good vehicle": the two most expensive organs to build from scratch — **organ-1 Locate**
(98-language structural index + CFG) and the **organ-5 verifier ethos** ("no false positives," confidence-
tagged references) — already exist at goal grade. The name-independent **identity fingerprint** exists and
is correct; it is merely unpersisted. The **plan/apply seam** is in the right place. Three of the four
wrong-direction calls are *polarity/persistence flips on existing assets*, not missing machinery. A separate
substrate would have to rebuild the multi-language structural front-end — the single hardest, most-saturated
thing normalize has — to gain a cleaner store-authority story it can approximate without inverting anything
yet. That trade is bad.

The redirection that's actually required:
- **Flip similarity from metric to identity key** (move 1) — cheap, unlocks the identity spine.
- **Flip edit-data from text-diff to decision** (move 2) — moderate, unlocks organs 2/4/5.
- **Treat LSP/JetBrains-parity as a *surface*, not the *vision*.** The danger is not the LSP — it's letting
  "replicate the IDE refactoring menu" become the terminal goal, which rewards hardcoding the menu
  (refactors-as-code) and the human-at-cursor loop. Keep LSP as one projection of a reconciler engine.

**Where normalize stays legitimately divergent (and should):** text-canonical store-authority. For a tool
over 98 externally-owned, dynamic languages where the editor and git own the bytes, text-canonical is
*correct*. The reconciler's "structure authoritative" is the right end-state for a *greenfield, normalize-
owned* substrate, but forcing it onto normalize-the-multi-language-tool would break its actual mission. So
the honest sub-verdict: pursue organs 1/2/4/5 *inside* normalize (it's the right vehicle for them), and
treat organ-3 store-authority as the one organ that may eventually want a **distinct substrate with
normalize as a dependency** — a reconciler core that owns its own structure-authoritative store and calls
normalize for parsing/locating/fingerprinting across languages. That split lets the goal have its
structure-authoritative store without fighting normalize's text-canonical mission, while still reusing the
expensive front-end.

**One-line verdict:** normalize is the right vehicle for four of five organs and the identity spine — flip
the similarity-hash to a key and the edit-data to a decision first — but organ-3 (store authority) is the
seam where a normalize-dependent reconciler substrate is the honest home, not a polarity-flip inside
normalize itself.
