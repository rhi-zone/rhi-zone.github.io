# Design Exploration: Unified Omnimedia Knowledge Corpus

## Context
Began as an "insane idea": a crash course for everything. Through iteration it sharpened into something different and larger. The product is **richly interlinked, richly annotated structured knowledge** — and the explicit ambition is to be the best of its kind on the planet. Competitors span two camps that nobody bridges: structured-knowledge players (Wikidata, Google Knowledge Graph, Wolfram) that are not pedagogical, and pedagogical-content players (Khan Academy, Crash Course) that are not structured or queryable. The wedge is doing both at once.

Hard cost constraint throughout: per-query LLM inference is unaffordable for the target audience. Any LLM use is one-time, at corpus-construction time, amortized across all learners. Routing/query/render logic is deterministic.

## Core concept
A formally-structured (Wikidata-style entities + typed relationships) knowledge corpus where nodes carry omnimedia pedagogical annotations (text, audio, video, presentations, interactive demos — comprehensive medium coverage so any learner finds a form that fits them). The corpus is the product. The leverage goal is combinatorial: facts as composable building blocks; querying, projection, and recomposition as first-class. Surfaces are projections of the data, not hand-built per-domain apps — the UI itself is data-driven and configurable.

## What this is NOT (corrections banked during design)
- Not a learning-path-routing engine. There is no minimal-prereq-path or personalized-overlay machinery as the product. "There is no graph" in the routing sense — only as much graph as Wikipedia/Wikidata has. Structure is Wikidata-style typed relations for data leverage, not a prerequisite DAG.
- A personal overlay (mark-read, preferences) is convenience UX, explicitly not the product.
- Not LLM-on-demand (cost constraint above).
- Not Wikipedia (prose + prose-links), not Khan/Crash Course (pedagogy, no structure), not Wikidata/Wolfram (structure, no pedagogy). It is the combination.
- "Omnimedia" means comprehensive medium coverage per unit for the learner's sake (different people, different needs/preferred media) — not medium chosen for the concept's sake, and not query-time synthesis.

## This is mostly NOT greenfield — prior art map
An ecosystem mining pass (disk + Claude session transcripts) found that a working corpus prototype, a projection engine, and authoring tooling already exist. The unified corpus is largely an assembly + generalization, not a from-scratch build.

- **software-taxonomy** (`~/git/pterror/software-taxonomy/`, pushed to github:pterror) — a working Wikidata-style corpus. Statement-level model with per-statement verbatim source excerpts ("snippet" anti-confabulation primitive), entity-per-file JSON, namespaced IDs (`@software:`, `@org:`, `@person:`, `@license:`, `@format:`, `@protocol:`, `@specification:`), SHACL-lite predicate constraints (value_type/domain/range/cardinality), a `@class:technical-artifact` supertype introduced specifically so predicates generalize beyond software, an EAV triple-store (@thi.ng/rstream-query) with transitive closure (in-memory, rebuilt each run — ephemeral index), and a **multi-lens system designed to layer unrelated overlays over a shared entity set**. Mature (Phase 4.0 complete, ~45 entities, regression fixtures, pre-commit validation). Authoring format: open JSON documents, entity-per-file, git-diffable — this IS the substrate format going forward.
- **Dusklight** (`~/git/rhizone/dusklight/`) — a configurable "projectional viewer": UI defined entirely by data. Layout trees of primitives (HStack/VStack/ForEach/RendererLeaf) bound to data via composable optics, every layout property a **Marinada** expression (embedded query/expression language, reactive compilation). Renderer selection is itself a data pipeline (sources → parsers → confidence-scored pattern match → ranked renderer dispatch) with user-switchable renderers per item. Partially implemented, actively developed. This IS the configurable view engine; it already sits at the "composable primitives + expression language" tier, not mere declarative config.
- **annotated-law** (`~/git/pteraworld/` on disk — WRONG folder; pushed to github:pterror) — a stub (legislative-structure IR + topic ontology + Astro frontend, mostly empty). Its design thinking contributes ideas (below) but little reusable code.
- **rescribe** (`~/git/rhizone/rescribe/`) — lossless multi-format document IR. Considered as the source-document layer and REJECTED as too heavy (its value is cross-format round-tripping, which the corpus does not need).
- Supporting: **Rainbow** (`~/git/rhizone/rainbow/`) optics/reactivity substrate Dusklight builds on; **server-less** (`~/git/rhizone/server-less/`) projection-from-one-definition on the Rust protocol side.

## Reuse verdict (carry forward / new / supersede)
**Carry forward — it is the foundation and is already general.** software-taxonomy's schema is not software-specific in its bones: the `@class:technical-artifact` supertype, the agent/org/person/license namespaces, and above all the **lens system** mean a `law` lens and a `finance` lens are first-class with ZERO schema changes. "One unified corpus, multiple domains" is what lenses already do — the task is to lift the predicate vocabulary off the software domain and add domain lenses, NOT to design a new schema. Also carry: statement model, snippet primitive, **entity-per-file open JSON documents** (the substrate format), namespaced IDs, SHACL-lite constraints (as per-corpus validation, not engine), taxonomy-as-derived-view.

**NOT carried: the EAV triple-store layer.** software-taxonomy's @thi.ng/rstream-query EAV index is an ephemeral in-memory index rebuilt each run, never persisted. Every nontrivial query already scans documents and post-processes in TypeScript (closures are TS fixpoints). The triple decomposition is incidental complexity — a second representation that adds no capability given how it is actually queried. It will be deleted. (See "Substrate decision" section below.)

**Genuinely new (no prior art covers these).**
- Omnimedia content model: multiple media renderings attached per node. Neither project designed this.
- Claim→node citation with a construction-time verification pass — a generalization of the per-statement snippet to multi-source distilled explainers (claim cites N source nodes; a check confirms each supports it). The right annotation primitive for the pedagogy layer; domain-agnostic. (Idea originates in annotated-law's citation-rigor design.)
- Topic ontology — annotated-law flagged the cross-cutting tag taxonomy as "the actual intellectual product" and the hardest layer. This is the annotation-schema design question and the most blocking open one.

**Supersede — do not copy.**
- annotated-law's Astro + SolidJS four-view frontend (verdict/corpus/comparative/navigator). Less general than Dusklight. The *concept* (multiple views over one shared corpus) survives — as **Dusklight view configurations**, not hand-built pages. A "law reader" is a config (saved query + layout + annotation types + medium prefs), not a codebase.
- Prereq-routing / personalized-overlay machinery (demoted; not the product).

## Source documents & citation (decision)
Do not adopt rescribe; do not port annotated-law's legislative IR into the core. The corpus distills sources, it does not round-trip or reproduce them. **Citation is covered by the existing snippet / source-span primitive** (verbatim excerpt + source URL + revision + optional anchor) — no document-structure layer required. A full hierarchical document IR only earns its keep if a view renders a primary source itself (e.g. a law "corpus view" that browses raw statute section-by-section); treat that as a **deferred, domain-specific, lens-local view concern**, not a corpus-wide layer. Revisit only if multiple domains need it.

## Architecture (assembled shape)
- **Corpus** — one unified, multi-domain knowledge graph. software-taxonomy's schema lifted off the software domain; domains (software, law, finance, …) are lenses over a shared entity set. Lives in one repo. Format: open JSON documents, entity-per-file, source of truth, git-diffable.
- **Projection** — Dusklight (rhi-zone substrate). Configurable, data-driven views; Marinada as the query/expression layer. Universal consumer/projector, shape-agnostic. Consumed by the corpus; stays in rhi-zone. Projection is NOT a substrate concern — it is a separate, pluggable layer.
  - The corpus↔Dusklight binding (corpus-as-source, domain-reader-as-config) is designed in `dusklight-binding.md`. Chosen path: it requires CLOSING 4 Dusklight config-driven gaps first (patterns-as-Marinada, layout JSON loader, ForEach optic + Marinada optic ops, source-factory wiring; + preference persistence).
  - **Dogfooding and improving the broader ecosystem is a co-equal goal, not a tax.** Closing Dusklight's four config-driven gaps is valuable in its own right; the corpus acts as a forcing function that drives Dusklight (and software-taxonomy) to maturity. The gap-closure work is win-win, not merely a blocked-on prerequisite.
- **Surfaces** — Dusklight view configurations, not separate codebases. Per-domain "readers" are configs + theming.
- **Validation** — per-corpus tooling. Each corpus defines its own rules. Not a shared/blessed engine concern.
- **Annotation layer (new)** — omnimedia renderings per node + claim/citation-with-verification + topic ontology. Dedicated schema design: `annotation-schema.md` (pressure-tested and revised 2026-05-29: both-paths synthesis, relaxed `medium`/`explains` cardinalities to 1..*, +5 new validation rules).

## Substrate decision (settled): document-native, no blessed metadata

**Decided 2026-05-29** after investigating whether triples earn their keep (they don't) and whether Dusklight should drive the substrate shape (no — Dusklight is a universal consumer/projector, so it is shape-agnostic).

**Final format landed (2026-05-29).** The full, implementable specification is **`format-spec.md`** (supersedes the open fork in `format-options.md`). Landed shape:

- **Model = RDF / RDF-star semantics** as the conceptual contract (subject–predicate–object, reifiable/addressable statements, annotations on statements) — rederived from no-blessed-metadata + uniformity + statement-addressability, hence RDF-equivalent by design and trivially exportable to RDF-star.
- **Serialization = our own clean JSON, document-native, entity-per-file** (NOT Turtle, NOT JSON-LD). Entity doc = `{ "id": "@ns:slug", "statements": [...] }`; the entity is the implicit subject. Statement = `{ "predicate", "value", ...open metadata keys..., "id"? }`.
- **Blessed surface (irreducible minimum):** structurally only `predicate`+`value` (the assertion) and the OPTIONAL statement `id` (addressability), plus the entity container keys `id`/`statements`. **Nothing in metadata position is blessed** — and no named metadata bag (`meta`/`about`) either; metadata keys sit directly on the statement.
- **Constructs:** multiplicity = repeated same-predicate statements; ordered list = a `value` that is a JSON array; n-ary = a `value` that is an inline anonymous node with multiple role keys; reification/annotation = give the statement an `id` and reference it, OR nest (nesting carries the subject — no `subject` field ever needed). `value` may be literal | `@ns:slug` reference | inline anonymous node | array. Inline vs referenced node = anonymous vs named, chosen per assertion.
- **No triple store.** Projection/query is Dusklight's; validation is per-corpus tooling; the format is purely how knowledge is written down.

1. **No blessed/authoritative metadata.** The substrate does not declare required/official fields. Formerly-blessed fields (rank, lens/register, sources/provenance, qualifiers, evidence-grade) become ordinary open-bag keys on the statement (or nested data) under ordinary predicates — none named by the format. The ONLY unavoidable blessing is statement-addressability (a statement id) so you can say things about a statement.
2. **Format = open JSON documents, entity-per-file, source of truth, git-diffable.** This is already software-taxonomy's authoring format. The document IS the substrate. Precise shape and RDF-star export mapping: `format-spec.md`.
3. **Triples don't earn their keep (code-verified).** software-taxonomy's EAV/@thi.ng/rstream-query layer is an ephemeral in-memory index rebuilt each run, never persisted. Every nontrivial query already scans documents and post-processes in TypeScript (closures are TS fixpoints). The triple decomposition is incidental complexity — a second representation that adds no capability given how it is actually queried. It will be deleted.
4. **Projection/query = Dusklight, universal and substrate-independent.** Dusklight is a universal data consumer/projector (Source -> Parser -> value:unknown -> optics/Marinada). Projection is NOT a substrate concern; it is a separate, pluggable, shape-agnostic layer. Caveat: Dusklight's projection layer is partially unbuilt — the four gaps in task #13.
5. **Validation = per-corpus tooling.** Each corpus defines its own rules. Not a shared/blessed engine concern. (The generality-audit gaps listed in the superseded engine section below — value-type/unit validation, temporal querying, evidence grading — are now per-corpus validation concerns, not engine defects.)
6. **The "engine" dissolves** into: format (open documents) + projection (Dusklight) + validation (per-corpus). There is no novel engine to extract or name. Engine naming is moot. If a shared FORMAT spec later emerges as a named artifact, it would be a developer/technical substrate (rhi-zone) — but it is a format/protocol, not an engine.
7. **Task impact:** the former "extract corpus-engine" task is reshaped to "refactor software-taxonomy to the document-native no-blessed-metadata format (delete triple layer; demote blessed fields)," gated by a new task "design the no-blessed-metadata document format spec." The corpus repo consumes no engine — it IS documents + per-corpus helpers, projected via Dusklight.

## Org / home (decision)

### Governing principle (confirmed)

Both rhi-zone and exo-place hold **substrates**. The discriminator is **whose purpose the substrate serves**:

- **exo-place** = substrates for **end-user purposes** (things end-users do or experience). Current members: aspect, hologram, noncanon. That these are all entity/world systems is incidental — it is what currently exists there, not the defining trait. The defining trait is end-user purpose. noncanon (a library) lives in exo-place because it is a substrate for the end-user purpose of collaborative worldbuilding, not because it is or is not a library. exo-place members are also inherently dataless and structureless.
- **rhi-zone** = substrates for **technical / developer purposes** (compilers, IRs, runtimes, optics, codegen, generic engines, authoring infrastructure).
- Neither org houses raw **data**. Data corpora live on the personal account github:pterror (precedent: software-taxonomy).

### Settled placements

- ~~**corpus-engine** → **rhi-zone**~~ **SUPERSEDED.** The engine dissolves (see "Substrate decision" section). There is no corpus-engine to extract or place. What formerly would have been "engine" decomposes into: the document format (a format/protocol spec if ever named, rhi-zone class), Dusklight projection (already rhi-zone), and per-corpus validation helpers (github:pterror, co-located with data). [superseded 2026-05-29]
- **Unified corpus** (the actual knowledge data: finance/law/medical/software facts) → **github:pterror**, disk path `~/git/pterror/`. It is data/content; no org houses raw data (precedent: software-taxonomy lives on the personal account). software-taxonomy and annotated-law already live on github:pterror; nothing is relocated. [settled]
- **syne.land** — parked and unneeded: the corpus is personal-account data and projection is Dusklight in rhi-zone, so neither has a syne.land home. Can be promoted later if a real cluster of org-worthy repos emerges. Naming work is banked, not spent.

## Engine: generality + overlap verdicts (SUPERSEDED — engine dissolved 2026-05-29)

**This section records findings from when extraction of a "corpus-engine" was under consideration. Those findings remain factually accurate as observations about software-taxonomy, but the framing is superseded: there is no engine to extract. See "Substrate decision" above. Reframings are noted inline.**

**Generality — general-with-caveats; gaps are all in the value layer, not structure.**
The relational/factual core is genuinely domain-general: entities, typed relations, hierarchies, n-ary relations (via qualifiers), provenance, multi-register lenses, and fictional skill-tree lenses all model cleanly across finance/law/medical + the annotation layer. Gaps, ranked by bite:
1. **BIGGEST** — no value-type/unit/quantity/date validation; every value is an opaque unchecked string (`value_type` is loaded but checked by zero rules). **Reframed:** this is now a per-corpus validation concern, not an engine defect.
2. No temporal/as-of querying (time recordable via qualifiers but not orderable/queryable) — bites law versioning. **Reframed:** per-corpus query helper concern.
3. No computation (the Wolfram boundary) — correctly layered out to interactive explainers, not a substrate defect.
4. Mild: no first-class ordered collections; statement-level citation deferred; no per-citation evidence-grade slot. **Reframed:** evidence-grade is ordinary nested data under an ordinary predicate (no blessing required).

Verdict: acceptable for v0 (finance concepts + explainers; computation routed to demos, rigor to citations). Law versioning and medical evidence-grading will need per-corpus rule machinery later (tracked as a post-v0 task).

**Overlap — ~~the engine is unique~~ moot since there is no engine.**
A triple-store/EAV grep across all of `~/git` returned zero hits outside software-taxonomy. The EAV layer is being deleted, so uniqueness is no longer a placement consideration. The vocabulary-alignment findings remain valid:
- **aspect**: same CONCEPT (typed graph + swappable schema + pure validator; WorldPack kinds≈classes, edgeTypes≈predicates) but different SUBSTRATE (Y.js CRDT, realtime, no reified/sourced statements). Decision: align vocabulary, do NOT share code (unchanged).
- **hologram**: irrelevant (free-text RAG facts; only the words coincide).
- **ascent-interpreter**: adjacent (a Datalog engine, possible query backend), not duplication.

~~Decision: extract the engine CORPUS-ONLY scope; no dedup work needed.~~ **Superseded.** No engine extraction. Reformulated task: refactor software-taxonomy to document-native no-blessed-metadata format (delete triple layer; demote blessed fields), gated by format-spec design task.

## Confirmed parameters (quick reference)
- Corpus is the product; reader is a convenience surface.
- Structure is formal/Wikidata-style; goal is data leverage via projection and querying.
- Omnimedia = comprehensive per-unit medium coverage for the learner.
- Content extracted/curated from existing sources, domain-by-domain.
- No per-query LLM; construction-time LLM only, amortized.
- One unified corpus now; federation deferred until concrete. software-taxonomy left running as-is, treated as schema ancestor + eventual (deferred) merge target.
  - **Federation design finding (noncanon, 2026-05-29):** When federation becomes concrete, the model to follow is **noncanon** (`~/git/exoplace/noncanon/`, Rust, currently design-only/empty crate): git-backed local-first canon where "canon = what you pulled in" and "divergence = git diff between two canons." Canons and the corpus's **lenses** are at different layers and compose rather than duplicate: lenses are intra-store semantic overlays (statement-level, register-typed: factual/interpretive/fictional); canons are cross-contributor distribution/membership at the git-remote boundary (coarse, object-level). Neither subsumes the other. Implication for the document-native format: the open JSON document format naturally fits inside a federated git object set — no reinventing distribution. No code dependency today; this is a design-alignment finding only.
- v0 scope: one domain end-to-end.
- v0 domain: personal finance fundamentals, concept-level, jurisdiction-agnostic core ("most generally useful first" + budget realism).

## Domain candidates (parked)

### Medical conditions
Origin: a user idea — "skill trees for various medical conditions, fully cited, based in medical literature." This is another domain/lens in the unified corpus, not a separate product.

**Key framing (corrected):** "skill tree" means a LITERAL RPG/game-style skill tree — worldbuildy skill names, tiers, build flavor — NOT a clinical pathway or learning-progression abstraction. This is the same "factual core + fanciful overlay" mechanism already established by software-taxonomy's `biology` and `mythology-demo` lenses: a fictional/interpretive-register lens overlaying flavorful framing onto a factual entity set, with the lens register system preventing contamination.

Concretely, two lenses over one corpus:
- **Factual medical lens:** conditions / mechanisms / treatments / evidence; register factual, `source_required true`, fully cited.
- **Worldbuilding/skill-tree lens:** gamified skill names + flavor text; register fictional (or interpretive), `source_required false`; overlays the same factual entities, never mixes in.

The "skill tree" is a Dusklight tree-VIEW projecting dependency edges (likely existing `@core:depends_on`), labeled via the worldbuilding lens. This is a clean demonstration of the configurable-view thesis: same corpus, skill-tree view for medical, reader view for finance — and the fictional-lens machinery is all existing mechanism.

**Cross-cutting insight:** this is the THIRD instance of "factual core + fanciful overlay" (software→biology, software→mythology, medical→skill-tree). That promotes the fictional/interpretive lens from a software-taxonomy quirk to a core, reusable corpus feature worth treating as first-class.

**Why it matters as a test:** medical is the highest-stakes stress-test of the citation + verification + staleness machinery — cites, verification pass, and `verified_against`/`verificationStale` fields against literature churn.

**New requirements it surfaces** (that other domains only hint at):
- Evidence grading — medical literature uses GRADE / levels-of-evidence; the citation model may want an evidence-strength qualifier on cites or sources.
- Liability posture — information-not-advice, same as annotated-law.
- Audience differentiation — patient vs. clinician vs. student; likely different reader configs over one corpus.

**Residual open question:** are the progression/dependency edges themselves FACTUAL (you genuinely must understand X before Y, grounded in medical literature) or GAME-DESIGN-ARBITRARY (tree shape invented for engagement)? This determines whether the dependency edges live in the factual lens or the worldbuilding lens. **Parked, not designed.**

## Open questions (in rough priority)
- Topic-ontology / annotation schema — was the hardest and most blocking. Now has a dedicated design at `annotation-schema.md` (explainer entities, claim→node citation + construction-time verification, `@topic:*` ontology). Remaining work is curating the topic taxonomy and resolving the interactive-component seam, not the schema mechanism.
- Omnimedia content model — how multiple media renderings are represented, stored, and selected per node (selection must be deterministic, not synthesized).
- Interactive-component embedding — WASM / Web Components / sandboxed iframe-with-small-API. Affects format openness. (Note Dusklight's renderer/plugin model likely already informs this — verify against Dusklight before designing.)
- Generalizing software-taxonomy's predicate vocabulary off the software domain — concretely, which predicates are universal vs. lens-local.
- Query surface for external consumers (the data-as-infrastructure leverage) — Marinada-based? exportable dump? Decide who builds on the corpus and how.
- Corpus-construction process & LLM budgeting — who curates, QA loop, contribution shape, how construction-time LLM spend is bounded.
- License of extracted content — practical/legal constraints for source-derived material.
- v0 jurisdiction split — universal money-management concepts (cash flow, compounding, opportunity cost, debt mechanics, account types) before jurisdictional tax procedure.

## Critical next steps (not implementation steps)
- Confirm v0 domain framing (personal finance fundamentals, concept-level, jurisdiction-agnostic).
- Design the no-blessed-metadata document format spec (what a statement id looks like, how formerly-blessed fields are represented as ordinary nested data). Gates the software-taxonomy refactor.
- Refactor software-taxonomy to document-native no-blessed-metadata format: delete triple/EAV layer; demote blessed fields to ordinary nested data.
- Design session for the annotation/topic-ontology schema — the blocking layer — starting from software-taxonomy's existing predicate/lens model.
- A focused look at how the corpus binds into Dusklight (corpus as a Dusklight data source; a domain reader as a Dusklight config) before committing to the surface approach. (Dusklight is shape-agnostic; the binding is a Source/Parser wiring concern, not a substrate-shape constraint.)
- Decide the concrete predicate generalization: which of software-taxonomy's ~59 predicates are universal, which become lens-local.
- Identify 2–3 candidate canonical sources for the finance v0 to validate extraction is feasible at acceptable construction-time cost.

## Verification (placeholder)
Concept-stage; defer real verification until the v0 spec is concrete. Provisional check: take ~10 finance-domain entities in software-taxonomy's existing format under a new `finance` lens, attach at least two media renderings each plus one claim-with-citation, load them as a Dusklight data source, and render a minimal domain reader as a Dusklight config — plus one sample query demonstrating cross-lens leverage (e.g. list concepts depending on "compounding").
