# ADR-0001: Knowledge-Corpus Foundations

- Status: Accepted
- Date: 2026-05-29

This is a **composite foundational ADR**. The decisions below were taken together
during the design of the unified omnimedia knowledge corpus, and they are tightly
interlinked: the product framing motivates the cost constraint; the cost
constraint and the substrate choice together dissolve the "engine"; the substrate
choice is what makes the annotation layer and the projection layer drop in without
special-casing; org placement follows from what each artifact turns out to be.
Recording them as one ADR preserves that narrative. Future decisions get atomic
ADRs (see this directory's README). Each sub-record cites the settled plan
document where the full reasoning lives; those documents are the detailed
reference, this ADR is the durable summary.

Source documents:
`snuggly-squishing-blum.md` (master plan),
`format-spec.md` (format specification),
`annotation-topic-ontology-schema.md` (annotation layer),
`dusklight-binding-and-gaps.md` (projection layer),
`no-blessed-metadata-format-options.md` (the options analysis behind the format).

---

## 1. Product framing: omnimedia knowledge corpus, corpus-is-the-product

**Context.** The effort began as "a crash course for everything" and sharpened
into something larger. The market splits into two camps nobody bridges:
structured-knowledge players (Wikidata, Google Knowledge Graph, Wolfram) that are
not pedagogical, and pedagogical-content players (Khan Academy, Crash Course) that
are not structured or queryable.

**Decision.** Build a richly interlinked, richly annotated **structured knowledge
corpus** (Wikidata-style entities + typed relationships) where nodes carry
omnimedia pedagogical annotations (text, audio, video, presentations, interactive
demos — comprehensive medium coverage so any learner finds a form that fits). The
wedge is doing structure AND pedagogy AND omnimedia at once. **The corpus is the
product;** surfaces are projections of the data, not hand-built per-domain apps.
"Omnimedia" means comprehensive per-unit medium coverage for the learner's sake,
not medium chosen for the concept and not query-time synthesis.

**Alternatives rejected.**
- *Crash-course / learning-path-routing engine* — there is no minimal-prereq-path
  or routing machinery as the product; structure exists for data leverage, not as
  a prerequisite DAG.
- *Personalized-overlay-as-product* — a personal overlay (mark-read, preferences)
  is convenience UX, explicitly not the product.
- *Wikipedia / Khan / Wikidata individually* — each covers only one of the three
  axes; the value is the combination.

**Consequences.** Data leverage (querying, projection, recomposition) is
first-class. The reader is a convenience surface. Content is curated/extracted
from existing sources, domain by domain. See `snuggly-squishing-blum.md`
(Context, Core concept, "What this is NOT").

---

## 2. Hard cost constraint: no per-query LLM inference

**Context.** The target audience cannot bear per-query inference cost. This
constraint runs through every other decision.

**Decision.** **LLM is used only at construction time, amortized across all
learners.** Routing, query, and render logic are fully deterministic. Any LLM
judgment (e.g. claim verification) happens once at build time and is stamped into
the data.

**Alternatives rejected.**
- *LLM-on-demand / query-time synthesis* — unaffordable at the target price point,
  and non-deterministic.

**Consequences.** Selection of media, projection, and validation must all be
deterministic functions of the data plus persisted preferences. Verification
verdicts are precomputed and stored. This constraint is what makes the corpus
(not an inference service) the unit of value. See `snuggly-squishing-blum.md`
(Context, Confirmed parameters).

---

## 3. Domains-as-lenses (multi-register truth)

**Context.** The corpus must hold software, finance, law, medical, and other
domains, including factual, interpretive, and fictional framings, without
contaminating one with another.

**Decision.** **One corpus; domains are lenses** over a shared entity set. The
lens system already in software-taxonomy carries a *register* (factual /
interpretive / fictional) and prevents cross-contamination. A `finance` lens and a
`law` lens are first-class with zero schema changes. The recurring "factual core +
fanciful overlay" pattern (software→biology, software→mythology, medical→skill-tree)
is a fictional/interpretive-register lens overlaying flavorful framing onto a
factual entity set — promoted from a software-taxonomy quirk to a core, reusable
corpus feature.

**Alternatives rejected.**
- *Separate corpora / separate products per domain* — loses the shared entity set
  and the combinatorial data leverage that is the whole point.
- *A new schema per domain* — unnecessary; the lens mechanism already generalizes.

**Consequences.** A "skill tree for medical conditions" is a Dusklight tree-view
projecting dependency edges labeled via a worldbuilding lens — same corpus, same
mechanism, different view. The fictional/interpretive lens machinery is treated as
first-class. Open: whether some dependency edges are factual or game-design-
arbitrary (parked, medical domain). See `snuggly-squishing-blum.md` (Reuse
verdict, Domain candidates).

---

## 4. Annotation / topic-ontology layer

**Context.** The pedagogy layer needs three things on top of the factual corpus:
omnimedia explainers, claim-to-node citation with verification, and a cross-cutting
subject taxonomy. The original design overclaimed that much of this "fell out for
free" from existing validation rules.

**Decision.** Add three things as **ordinary entities and statements**, with
explicit new validation rules only where the existing rule set has a real gap:
- **Explainers are ordinary entities** (`@explainer:*`, `instance_of
  @meta:explainer`); pedagogy relations (`explains`, `medium`, `content`, `cites`,
  `verified`) are ordinary `@core` predicates.
- **A `@topic:*` axis** (`subtopic_of` / `about_topic`) **orthogonal to the class
  axis** (`subclass_of` / `instance_of`); topic closure reuses the existing
  transitive-closure engine. Decision procedure: topics are never instantiated;
  if X has instances it is a class, if X is a subject-area things are *about* it is
  a topic.
- **`@medium:*` as a controlled entity set** (not a string enum), so `rangeViolation`
  enforces the vocabulary and media can carry their own metadata.
- **Claim→node citation with construction-time verification.** Two composing
  mechanisms: existing per-statement `sources[].snippet` (external documents) and
  the new explainer-level `@core:cites` (internal entities). Verification supports
  **both** an in-explainer "derived" status (synthesis local to one explanation)
  **and** promotion-to-statement (when a derived claim is a reusable corpus fact).
- **Relaxed cardinalities** to `1..*` for `@core:medium` (genuinely multi-modal
  artifacts) and `@core:explains` (relational explainers teaching the link between
  concepts — build-time-fixed, not query-time synthesis).
- **New per-corpus validation rules** (genuinely new machinery, not reuse):
  `contentShapeMatchesMedium`, `explainerCitesNonempty`, `citedNodeSourced`,
  `verificationPresentWhenRequired`, `verificationStale`,
  `explainerStatementWhitelist`, `explainerOwnershipAligned`, `subtopicOfAcyclic`
  (+ recommended `subclassOfAcyclic`), `topicClassAlignment` (warning), plus a
  `sourceRequiredViolation` carve-out for explainer statements.

This layer was **adversarially pressure-tested against the actual validator source
and revised** (2026-05-29): the first draft was corrected on no `value_type`
validation existing, no statement-id reference kind existing, a sentinel-value
laundering hole, and no `subclass_of` acyclicity rule existing.

**Alternatives rejected.**
- *Statement-id-level citation in v0* — there is no statement-id reference kind;
  it would require a new index plus re-implementing every ref-integrity check for
  the `s:` kind. Deferred as a precision enhancement; v0 cites entities only.
- *Per-statement / new register value for pedagogy* — explainers inherit their
  domain lens's register; pedagogy is distinguished by entity type, not register.
- *Plain-string medium enum* — loses validation reuse and per-medium metadata.
- *"It falls out for free" claims* — rejected on contact with the validator
  source; genuine new rules are named as such.

**Consequences.** The validator gains a handful of pure `(ctx)=>Violation[]` rules;
construction-time QA reports (medium-coverage gaps, unverified/stale explainers,
untagged concepts) fall out of the closures + scans. The curation of the topic
taxonomy (human-curated upper tree, LLM-suggested + human-reviewed leaf tagging)
is the real intellectual work, not the mechanism. The interactive-component
embedding seam stays open. See `annotation-topic-ontology-schema.md`.

---

## 5. Substrate decision: document-native, no blessed metadata

**Context.** The central decision. Two questions had to be answered: do triples
earn their keep (no, see #6), and should the projection tool drive the substrate
shape (no, see #8)? With those settled, the question reduces to: how is knowledge
written down as documents, honoring "no blessed metadata" — no authoritative
"we shall have X, Y, Z metadata"?

**Decision.**
- **Model = RDF / RDF-star semantics as the conceptual contract.** Derived (not
  adopted) from three constraints — no blessed metadata, uniformity (metadata and
  data are the same kind of thing), statement-addressability. That derivation
  *is* RDF-star, so the model is RDF-equivalent by design and trivially
  exportable to RDF-star for interop.
- **Serialization = our own clean JSON, document-native, entity-per-file** (NOT
  Turtle, NOT JSON-LD). Entity document = `{ "id": "@ns:slug", "statements": [...] }`;
  the entity is the implicit subject. Statement = `{ "predicate", "value",
  ...open metadata keys..., "id"? }`.
- **`predicate` and `value` are structure; the optional statement `id` is
  addressability; `id`/`statements` are the entity container.** Everything in
  metadata position is **unblessed open-bag keys** sitting directly on the
  statement — `rank`, `lens`, `sources`, time-bounds, evidence-grade, roles — none
  named by the format, none required, none special-cased. No named metadata bag
  (`meta`/`about`) is blessed either.
- **Constructs:** multiplicity = repeated same-predicate statements; ordered list =
  a `value` that is a JSON array; n-ary = a `value` that is an inline anonymous
  node with role keys; reification/annotation = give the statement an `id` and
  reference it, OR nest (nesting carries the subject — no `subject` field is ever
  needed). `value` may be literal | `@ns:slug` reference | inline anonymous node |
  array. Inline vs referenced = anonymous vs named, chosen per assertion.
- **RDF-star export** is total and mechanical (entity→subject IRI, predicate→IRI,
  literal→typed literal, reference→IRI, inline node→blank node, array→rdf:List,
  statement id + metadata→RDF-star reified triple + annotation triples).

**Alternatives rejected.**
- *Blessed-metadata schema* — violates the principle; the format would declare
  privileged fields.
- *Pure triples / RDF adoption (Turtle, JSON-LD)* — re-imports RDF's framing,
  ceremony, blessing, and tooling weight; we keep RDF *semantics* and reject RDF
  *syntax*.
- *Property graph* — another substrate to adopt with its own blessing and weight.
- *Full reification, statements scattered across the file* (options analysis
  Option 1) — worst authoring ergonomics, scattered git diffs, re-introduces the
  EAV join in code.
- *Object grouped by predicate* — multiplicity becomes ambiguous; repetition +
  array-value keeps multiplicity vs ordered-list unambiguous.
- *Adopt RDF outright* — re-imports blessing/weight as above.
- *Invent with no standard alignment* — loses interop and re-solves problems RDF
  already solved; deriving to RDF-equivalence gets alignment for free.
- *Named metadata bag* (options analysis Option 3) — one more blessing than
  needed; keys live flat on the statement instead.

**Consequences.** The document IS the substrate: git-diffable, human- and
LLM-authorable. The format makes no projection commitments (that is Dusklight's
job, #8) and no validation commitments (per-corpus, #4/#7). The
software-taxonomy refactor implements this spec: demote `rank`/`lens`/`sources`/
`qualifiers` to open-bag keys, make statement `id` optional, demote entity-level
`labels`/`aliases`/`description`/`lens` to statements (or keep as a documented
convenience the format does not bless). Open sub-questions carried (not blocking):
identity scheme, literal datatype/unit handling, reference resolution,
`value`-vs-`object` naming, qualifier flatten-vs-nest. See `format-spec.md` and
`no-blessed-metadata-format-options.md`.

---

## 6. Triples don't earn their keep — no triple store

**Context.** software-taxonomy carried an EAV triple store (`@thi.ng/rstream-query`)
with transitive closure. The question: does that second representation earn its
keep?

**Decision.** **Code-verified: it does not.** The EAV index is ephemeral, rebuilt
in memory each run, never persisted; every nontrivial query already scans
documents and post-processes in TypeScript (closures are TS fixpoints). It adds no
capability. **Delete the triple STORE.** Keep the triple MODEL (RDF semantics) —
it is exactly the statements-list of #5. The key distinction: **model vs
serialization vs store** are three separate things; rejecting the store does not
reject the model.

**Alternatives rejected.**
- *Keep the EAV store* — incidental complexity, a second representation with no
  added capability; a triple-store grep across all of `~/git` found zero other
  users.

**Consequences.** `load.ts` simplifies drastically (read files → parse → return
documents + whatever per-corpus index a helper wants). The blessed-attribute
registry and sentinel coercion go away as format artifacts. The
`statement/subject` synthesized attribute is unneeded (subject = the document).
See `snuggly-squishing-blum.md` (Substrate decision, point 3) and `format-spec.md`
(§4.4).

---

## 7. The "engine" dissolves

**Context.** Earlier framing assumed a reusable "corpus-engine" would be extracted
and named (and placed in an org). With #5 and #6 settled, is there an engine left?

**Decision.** **No.** There is no novel engine to extract or name. It decomposes
into three things: **format** (open documents, #5) + **projection** (Dusklight,
#8) + **validation** (per-corpus tooling, #4). The former "extract corpus-engine"
task is reshaped into "refactor software-taxonomy to the document-native
no-blessed-metadata format." Engine naming is moot.

**Alternatives rejected.**
- *Extract and name a corpus-engine* — superseded; there is nothing engine-shaped
  once format, projection, and validation are separated.

**Consequences.** The corpus repo consumes no engine — it IS documents + per-corpus
helpers, projected via Dusklight. The generality-audit "gaps" (value-type/unit
validation, temporal querying, evidence grading) are reframed as per-corpus
validation concerns, not engine defects. If a shared FORMAT spec is ever named as
an artifact, it is a format/protocol (rhi-zone class), not an engine. See
`snuggly-squishing-blum.md` (Substrate decision, point 6; Engine section,
superseded).

---

## 8. Projection / query = Dusklight (universal, substrate-independent)

**Context.** Does the projection/view tool drive the substrate shape? And what is
the view layer?

**Decision.** **Dusklight is a universal data consumer/projector** (Source →
Parser → `value: unknown` → optics/Marinada). **Projection is NOT a substrate
concern;** it is a separate, pluggable, shape-agnostic layer, so it does not
constrain the format. A "domain reader" is a Dusklight **config** (source config +
selection query + layout tree + medium-scoring patterns + renderer references),
not a codebase. The corpus binds in as a Dusklight data source. This **requires
closing Dusklight's four config-driven gaps first**: (1) patterns-as-Marinada, (2)
a layout JSON loader, (3) `ForEach.optic` evaluation + Marinada optic ops, (4)
source-factory wiring (plus deterministic preference persistence). Closing these
gaps is dogfooding value in its own right, not a tax.

**Alternatives rejected.**
- *Let the projection tool drive the substrate shape* — Dusklight is
  shape-agnostic; the binding is a Source/Parser wiring concern, not a
  substrate-shape constraint.
- *Hand-built per-domain frontend apps* (e.g. annotated-law's Astro four-view
  frontend) — less general than Dusklight; the concept (multiple views over one
  corpus) survives as Dusklight configs.

**Consequences.** "How a medium is displayed" is code (a renderer plugin); "which
entities, which layout, which renderer for which medium-preference" is data. A law
reader vs a finance reader differ only in JSON. Build-time closure flattening on
each entity keeps reader queries to flat `filter`/`includes` with no query-time
graph walk. The corpus ships only data and renderer references, no Dusklight code.
Deterministic medium selection is a Marinada sort in the reader's `select` (full
tie-break in scope), with the pattern path as a secondary renderer-switch
convenience. See `dusklight-binding-and-gaps.md`.

---

## 9. Org-placement principle

**Context.** Where do the corpus, the (former) engine, and a possible new org
(`syne.land`) live? The prior heuristic ("exo-place = entity/world systems") did
not actually discriminate.

**Decision.** Both rhi-zone and exo-place hold **substrates**; the discriminator is
**whose purpose the substrate serves**: **rhi-zone = substrates for
technical/developer purposes** (compilers, IRs, runtimes, optics, codegen,
authoring infrastructure); **exo-place = substrates for end-user purposes** (things
end-users do or experience). The entity/world character of current exo-place
members is **incidental, not definitional**. **Neither org houses raw data** —
corpora live on the personal account `github:pterror` (precedent:
software-taxonomy).

**Alternatives rejected.**
- *"exo-place = entity/world systems"* — incidental trait, not the discriminator.
- *Put the corpus in an org* — it is raw data; no org houses raw data.
- *Place a corpus-engine in rhi-zone* — moot; the engine dissolved (#7).

**Consequences.** The unified corpus → `github:pterror` (`~/git/pterror/`); nothing
relocates (software-taxonomy and annotated-law already live there). Engine-org
question is moot. `syne.land` is **parked and unneeded** — promotable later if a
real cluster of org-worthy repos emerges; naming work is banked, not spent. See
`snuggly-squishing-blum.md` (Org / home).

---

## 10. Ecosystem relationships

**Context.** Several existing projects are adjacent. Each needed a verdict so they
are neither accidentally coupled nor redundantly rebuilt.

**Decision (cross-cutting findings).**
- **software-taxonomy** — the **schema ancestor AND the refactor target**:
  migrate it to the document-native no-blessed-metadata format (delete the triple
  layer, demote blessed fields). It is the foundation and is already general
  (the lens system makes new domains first-class).
- **noncanon** — **learn-from for the deferred federation story** (git-backed
  local-first canon; "canon = what you pulled in", "divergence = git diff").
  Lenses ≠ canons: different layers that compose (lenses are intra-store
  statement-level register-typed overlays; canons are cross-contributor
  object-level distribution). No code dependency today; design-alignment finding
  only.
- **aspect** — **same concept** (typed graph + swappable schema + pure validator)
  but **different substrate** (CRDT/Y.js, realtime, no reified/sourced
  statements). **Align vocabulary, do NOT couple code.**
- **defocus** — **irrelevant** (simulation runtime).
- **hologram** — **irrelevant** (free-text RAG facts; only the words coincide).
- *(rescribe, considered as a source-document layer, was rejected as too heavy —
  see #5/citation; ascent-interpreter noted as an adjacent possible query backend,
  not duplication.)*

**Alternatives rejected.**
- *Extract a shared engine across these* — the EAV/triple layer is unique to
  software-taxonomy and is being deleted; no dedup work warranted.
- *Couple to aspect's code* — different substrate; only vocabulary aligns.

**Consequences.** Federation is deferred until concrete; software-taxonomy runs
as-is and is the eventual (deferred) merge target. The open JSON document format
fits naturally inside a federated git object set, so distribution need not be
reinvented. See `snuggly-squishing-blum.md` (Reuse verdict, Overlap verdicts,
Federation finding).

---

## 11. v0 scope

**Context.** The corpus is large in ambition; v0 needs a bounded, demonstrable
slice.

**Decision.** **One domain end-to-end: personal finance fundamentals,
concept-level, jurisdiction-agnostic core** — "most generally useful first."
Universal money-management concepts (cash flow, compounding, opportunity cost,
debt mechanics, account types) before any jurisdictional tax procedure.

**Alternatives rejected.**
- *Multiple domains at once* — too much surface for a first proof.
- *A jurisdiction-specific finance slice first* — jurisdictional tax procedure is
  less generally useful and more brittle than the universal core.

**Consequences.** Provisional verification target: ~10 finance entities in the new
format under a `finance` lens, each with ≥2 media renderings and one
claim-with-citation, loaded as a Dusklight source, rendered as a minimal reader
config, plus one cross-lens leverage query. Finance source scouting (2–3 candidate
canonical sources) is needed to confirm extraction is feasible at acceptable
construction-time cost. See `snuggly-squishing-blum.md` (Confirmed parameters,
Critical next steps, Verification).

---

## Open questions (carried, not decided)

These are recorded as carried — they are not blockers for the decisions above, and
each will become its own atomic ADR (or a corpus-repo decision) when resolved.

- **Value-layer validation** (value-type / unit / quantity / date; temporal
  as-of querying; evidence grading) — per-corpus, post-v0.
- **Interactive-component embedding** — WASM / Web Component / sandboxed iframe;
  plugs in at an explainer's `content` value (`medium:interactive`), likely a
  future `@component:*` namespace. Verify against Dusklight's renderer/plugin
  model.
- **External query surface** — how external consumers build on the corpus
  (Marinada-based? exportable dump?); a deferred derived layer.
- **Corpus-construction process & LLM budgeting** — curation, QA loop,
  contribution shape, how construction-time LLM spend is bounded.
- **Content licensing** — practical/legal constraints for source-derived material.
- **Finance source scouting** — 2–3 candidate canonical sources for v0.
- **Entity-level fields purity vs convenience** — whether
  `labels`/`aliases`/`description` are statements or conventional top-level keys
  the format does not bless.
- **Identity scheme** — explicit `id` vs content-hash vs positional; interacts
  with diff-noise, dedup, and the RDF-star statement-IRI mapping.
- **Literal datatype / unit handling** — how typed literals and units are
  expressed as ordinary data.
- **Reference resolution** — whether `@ns:slug` → file-path mapping is blessed by
  the format or per-corpus convention.
