# Annotation / Topic-Ontology Layer — Schema Design

Design doc for the pedagogy/annotation layer of the unified omnimedia knowledge corpus. Extends the existing software-taxonomy schema (`~/git/pterror/software-taxonomy/`). Master plan: `design-overview.md`.

## 0. Revisions from pressure-test (2026-05-29)

This doc was adversarially pressure-tested against the actual validator source
(`~/git/pterror/software-taxonomy/tooling/src/lib/rules.ts`). The first draft
overclaimed that several mechanisms "fall out for free" from existing rules.
They do not. The ground truth (verified):

- **No `value_type` validation exists anywhere.** `value_type` is loaded into the
  predicate-def map and never compared against any statement value by any rule.
  Any type safety must be NEW, explicit machinery.
- **No statement-id reference kind exists.** Every ref-integrity rule
  (`danglingEntityRef`, `rangeViolation`, `crossLensFictional`, `qualifierDanglingRef`)
  gates on `value.startsWith("@")`. Statement-ids (`s:...`) are invisible to all of them.
- **Sentinel-valued statements** (`{unknown}`/`{novalue}` → `"__sentinel__"`) are
  **exempt** from `sourceRequiredViolation`. This is a laundering hole the draft missed.
- **No `subclass_of` acyclicity rule exists.** `aliasCycle` only covers `alias_of`.
  A `subtopic_of` acyclicity rule is genuinely NEW, not a parallel of existing machinery.
- **`qualifierUnknownPredicate` warns on any qualifier key not in predDefs.** Every
  qualifier predicate (verified_by, verification_status, verified_against) MUST ship as
  a real predicate-def file `<lens>__<local>.json`, or it warns on every use.
- **`crossLensFictional` guards entity REFERENCES, not prose.** It cannot police a
  `content` string.

### Design decisions taken

- **D1 — synthetic/derived claims: support BOTH paths.** A "why" is composed from
  premises and attested by no single node. Authors choose per claim between
  (a) in-explainer synthesis via a new `derived` verification status, and
  (b) promotion to a real factual statement. See §4.5.
- **D2 — relax both flagged 1..1 cardinalities.**
  - `@core:medium` → `1..*` (an explainer may be genuinely multi-modal). See §3 medium.
  - `@core:explains` → `1..*` (relational explainers teaching the link BETWEEN concepts
    are normal build-time-fixed artifacts, not query-time synthesis). See §3 explains.

### New validation rules added by this revision (full set in §7)

Carried from draft (still valid): `explainerCitesNonempty`, `danglingCitesRef`,
`verificationPresentWhenRequired`, `subtopicOfAcyclic`.
Added by pressure-test: `contentShapeMatchesMedium`, `citedNodeSourced`,
`explainerOwnershipAligned`, `verificationStale`, `explainerStatementWhitelist`,
`topicClassAlignment` (warning), and a recommended symmetric `subclassOfAcyclic`.

## 1. Overview

This layer adds three things to the corpus: (a) **omnimedia explainers** — per-medium pedagogical content units attached to concepts; (b) **claim/citation-with-verification** — explainers cite the internal source *nodes* they distill, stamped by a construction-time verification pass; (c) a **topic ontology** — a cross-cutting subject taxonomy orthogonal to the class hierarchy. The governing principle: **reuse the existing entity/statement/lens/closure machinery where it genuinely applies, and add explicit new rules only where the existing rule set has a real gap.** Explainers and topics are ordinary entities with `instance_of` metaclass typing; new relations are ordinary predicates; topic closure reuses the transitive-closure engine that already powers `subclass_of`; verification metadata rides on statements/qualifiers. The validator gains a handful of new pure `(ctx)=>Violation[]` rules — and several of these are genuinely new machinery, NOT reuse, because the existing rules do not validate value types, do not see statement-id refs, and do not police prose. No new file formats, no new ID scheme, no new store.

## 2. New namespaces & metaclasses

Two new namespaces (implicit from `data/entities/<ns>/` dir names, same as all existing namespaces):

- **`@explainer:*`** — explainer/content-unit entities. Slug convention: `<concept-slug>-<medium>-<NN>` (e.g. `@explainer:compound-interest-text-01`). `<NN>` is a 2-digit ordinal disambiguating multiple explainers of the same concept+medium (e.g. a beginner vs. advanced text explainer). Name chosen over alternatives (`@content:`, `@lesson:`) because "explainer" is exactly the unit Decision 1 names and avoids implying course/sequence structure (the plan explicitly rejects learning-path routing).
- **`@topic:*`** — topic entities. Slug = kebab subject name (e.g. `@topic:personal-finance`).

New metaclass:
- **`@meta:topic`** — `data/entities/meta/topic.json`, self-instancing and parallel in every respect to `@meta:class`:
  ```json
  { "id": "@meta:topic", "labels": { "en": "Topic" },
    "description": "The meta-class of all topics. Every subject-tag entity is instance_of @meta:topic.",
    "statements": [ { "id": "s:<...>", "predicate": "@core:instance_of", "value": "@meta:topic", "lens": "core" } ] }
  ```

**Inherited conventions (both namespaces):** entity-per-file JSON at `data/entities/<ns>/<slug>.json`; ID format `@<ns>:<slug>` (with `@` stored); `id`/`labels`/`aliases`/`description`/`statements` entity shape; `instance_of` metaclass typing; statement model (`s:<7char base36>` ids, rank, qualifiers, lens, sources); predicate-def and closure machinery. Explainer entities additionally carry a domain `lens` (see §6); topic entities are structural and live in `core` like classes do.

## 3. Explainer entity design

### Shape (worked example — finance concept `@finance:compound-interest`)

```json
{
  "id": "@explainer:compound-interest-text-01",
  "labels": { "en": "Compound interest — plain-text explainer" },
  "description": "Beginner text explainer for compound interest.",
  "statements": [
    { "id": "s:ex1note", "predicate": "@core:instance_of", "value": "@meta:explainer", "lens": "core" },
    { "id": "s:ex2plns", "predicate": "@core:explains", "value": "@finance:compound-interest", "lens": "finance" },
    { "id": "s:ex3medi", "predicate": "@core:medium", "value": "@medium:text", "lens": "finance" },
    { "id": "s:ex4cont", "predicate": "@core:content",
      "value": "Compound interest is interest earned on both your principal *and* on previously earned interest. ...",
      "lens": "finance" },
    { "id": "s:ex6cite", "predicate": "@core:cites", "value": "@finance:compound-interest", "lens": "finance" },
    { "id": "s:ex7cite", "predicate": "@core:cites", "value": "@finance:principal", "lens": "finance" },
    { "id": "s:ex8veri", "predicate": "@core:verified", "value": "2026-05-29",
      "lens": "finance",
      "qualifiers": {
        "@core:verified_by": "claude-opus-4-8",
        "@core:verification_status": "supported",
        "@core:verified_against": "@finance:compound-interest#r3,@finance:principal#r1" } }
  ]
}
```

Note an `@meta:explainer` metaclass entity (in `data/entities/meta/explainer.json`, self-typing pattern like `@meta:class`) so explainers are first-class typed and domain/range checks can target them.

**`cites` is ENTITY-level for v0** (`@ns:slug` only). The draft's example cited a statement-id (`s:<stmt-id>`); that has been removed — see §4.3 for why and the deferred precision enhancement.

### Predicate home: `@core`

All structural, cross-domain pedagogy predicates live in **`@core`**, alongside `instance_of`/`subclass_of`. Justification: they are domain-agnostic plumbing — `explains`/`medium`/`content`/`cites`/`verified`/`about_topic`/`subtopic_of` mean the same thing in finance, law, and software. Putting them in `core` (which every domain `depends_on`) means each domain lens gets them with zero per-lens duplication, exactly as `instance_of` is shared today. The *statements* using them still carry the domain `lens` tag (`finance`), so ownership/`crossLensFictional`/`source_required` resolve to the domain — see §6. (This mirrors the existing fact that `@core:instance_of` is a core predicate used in `lens:"core"` statements; here the same core predicate is used in `lens:"finance"` statements, which is already legal — predicate lens and statement lens are independent fields.)

### Predicate definitions (verbatim)

```json
{ "id": "@core:explains", "label": "explains", "lens": "core",
  "description": "Links an explainer entity to a concept entity it teaches. Multi-valued for relational explainers that teach the link between concepts.",
  "value_type": "entity", "domain": ["@meta:explainer"], "range": null,
  "cardinality": "1..*", "inverse": "@core:explained_by" }
```
```json
{ "id": "@core:explained_by", "label": "explained by", "lens": "core",
  "description": "Inverse of explains: the explainer entities that teach this concept.",
  "value_type": "entity", "domain": null, "range": ["@meta:explainer"],
  "cardinality": "0..*", "inverse": "@core:explains" }
```
```json
{ "id": "@core:medium", "label": "medium", "lens": "core",
  "description": "The presentation medium/media of an explainer (text, audio, video, ...). Multi-valued: one artifact may be genuinely multi-modal (e.g. video with interactive transcript).",
  "value_type": "entity", "domain": ["@meta:explainer"], "range": ["@meta:medium"],
  "cardinality": "1..*" }
```
```json
{ "id": "@core:content", "label": "content", "lens": "core",
  "description": "The explainer payload. Interpretation depends on medium: inline markdown for text, a media URL/path for audio/video/diagram, a component-manifest reference for interactive. Shape per medium is enforced by contentShapeMatchesMedium (no value_type validation exists).",
  "value_type": "markdown", "domain": ["@meta:explainer"], "range": null,
  "cardinality": "1..*" }
```
```json
{ "id": "@core:cites", "label": "cites", "lens": "core",
  "description": "Links an explainer to an internal source ENTITY (@ns:slug) it is distilled from. v0: entity refs only, covered by danglingEntityRef/rangeViolation. Distinct from statement-level sources[].snippet, which cites external documents.",
  "value_type": "entity", "domain": ["@meta:explainer"], "range": null,
  "cardinality": "0..*" }
```
```json
{ "id": "@core:verified", "label": "verified", "lens": "core",
  "description": "Construction-time verification stamp: date the explainer's claims were confirmed against its cited nodes. Qualifiers carry verifier identity, verdict, and the cited-node anchor.",
  "value_type": "date", "domain": ["@meta:explainer"], "range": null,
  "cardinality": "0..1" }
```

Qualifier predicates — **these MUST be real predicate-def files**, or `qualifierUnknownPredicate` warns on every use. Naming convention `<lens>__<local>.json`, so:

- `core__verified_by.json` → `@core:verified_by` (value_type `string`; verifier identity, e.g. a model id).
- `core__verification_status.json` → `@core:verification_status` (value_type `string`; controlled vocabulary `"supported" | "partial" | "unsupported" | "derived"` — the `derived` value is new, see §4.5).
- `core__verified_against.json` → `@core:verified_against` (value_type `string`; a comma-joined list of `@ns:slug#<rev-anchor>` pairs capturing the revision/hash anchor of each cited node's relevant statements at verification time; consumed by `verificationStale`). Precedent: external sources already carry `revid`.

Note: `value_type` on these files is documentation/intent only — no rule reads it. The controlled vocabulary of `verification_status` is enforced by `verificationPresentWhenRequired`, not by value_type.

### `medium` vocabulary — controlled entity set `@medium:*`

**Recommendation: a controlled `@medium:*` entity set, not a plain string enum.** Entities `@medium:text`, `@medium:audio`, `@medium:video`, `@medium:presentation`, `@medium:interactive`, `@medium:diagram`, each `instance_of @meta:medium`. Justification: (1) media get their own labels/descriptions and can carry their own statements later (e.g. a `default_renderer` hint Dusklight reads) — a bare string cannot; (2) `range:["@meta:medium"]` lets the existing `rangeViolation` rule enforce the vocabulary — this IS genuine reuse, because `rangeViolation` gates on `@`-prefixed values and `@medium:*` values qualify; (3) adding a medium is just adding an entity file, no code change. Trade-off accepted: slightly more verbose than a string, but consistent with how the corpus already models controlled vocabularies as entities (licenses, languages).

### `content` storage per medium

`@core:content` is `value_type:"markdown"` (an open value_type string — but recall NO rule validates value_type, so this is documentation only). Per-medium interpretation, **enforced by the new `contentShapeMatchesMedium` rule** (§7), which is the ONLY defense against content/medium type confusion since no value_type validation exists:
- **text** → inline markdown string (the literal lesson body).
- **audio / video / diagram** → a URL or repo-relative path string (the rendered/recorded asset). The rule checks the content matches a URL/path shape.
- **interactive** → a `@component:*` entity ref or a repo-relative path to a component manifest. **Open seam** (§9): the manifest format and embedding mechanism (WASM / Web Component / sandboxed iframe) is the still-open interactive-component-embedding question. The schema seam: `content` holds a manifest reference (a path or a `@component:*` entity ref once that namespace exists); nothing else in this layer needs to change when it is resolved.

### `explains` cardinality: 1..* (relaxed — D2)

An explainer **explains one OR MORE concepts**. The draft fixed this at `1..1` and defended it by claiming a multi-concept explainer "would reintroduce synthesis/composition the plan rejects." That defense conflated two different things:

- **Query-time synthesis** (rejected by the plan): composing an answer about multiple concepts on demand, at serve time, with no authored artifact. This remains rejected.
- **Relational explainers** (normal, allowed): an authored artifact that teaches the *relationship between* two or more concepts (e.g. "how compound interest interacts with inflation"). It is fixed at build time, verified once, and deterministic to serve. This is exactly the kind of pedagogical unit the corpus needs and is NOT query-time synthesis.

A relational explainer surfaces under **every** concept it `explains` (via `explained_by`). Medium-coverage and Dusklight selection (§3 medium, §8) treat it as an explainer for each of its concepts. Single-concept explainers remain the common case; the cardinality simply stops forbidding the relational case.

### `medium` cardinality: 1..* (relaxed — D2)

An explainer may be genuinely multi-modal — e.g. a video that ships WITH an interactive transcript, both being THE artifact, not two separate explainers. Setting `medium` to `1..*` lets one entity declare all media it satisfies. Consequence for `content`: `content` is also `1..*`, and `contentShapeMatchesMedium` validates each `content` value against the medium it is paired with (pairing convention: equal `rank` ties a content value to a medium value; if a single content serves all media, it must satisfy every declared medium's shape — see §7).

**Dusklight selection under multi-medium (deterministic).** Selection by learner medium preference must be deterministic: an explainer **matches** a preference if **ANY** of its `medium` values match. When multiple explainers match a (concept, preferred-medium), the tie-break is deterministic and fixed: (1) prefer an explainer whose medium set is the *smallest superset* containing the preferred medium (most specifically targeted); (2) then lowest `<NN>` ordinal in the slug; (3) then lexicographic entity id. No randomness, no LLM. This replaces the draft's note, which assumed exactly one medium per explainer.

## 4. Citation + verification model

### 4.1 Two distinct, composing citation mechanisms

| Mechanism | Lives on | Points at | Cites what | Enforced by |
|---|---|---|---|---|
| `sources[].snippet` (existing) | each factual **statement** | **external** document (`source.id` + verbatim snippet) | the document a *fact* came from | `danglingSourceRef`, `sourceRequiredViolation` |
| `@core:cites` (new) | **explainer** entity | **internal** ENTITY (`@ns:slug`) | the corpus *nodes* a *claim* distills | `danglingEntityRef` (reused) + `rangeViolation` + new `citedNodeSourced` |

They **compose**: an explainer's `cites` points at internal entities; those entities' statements in turn carry `sources[].snippet` pointing at external documents. So an explainer claim is traceable two hops — claim → internal entity → external source snippet — without the explainer duplicating external citations. Verification operates on the first hop; the snippet primitive already secures the second.

### 4.2 Verification: construction-time process vs. deterministic validator

**Construction-time process (LLM allowed, never query-time):** for each explainer, confirm that the union of its cited nodes actually supports the explainer's content. On success, stamp `@core:verified` (date) with qualifiers `verified_by`, `verification_status`, and `verified_against` (the cited-node revision anchors). This is judgment work; the LLM does it once at build time, amortized.

**Deterministic validator (query-time-safe, structural only):** the validator NEVER judges semantic support. It checks only structural integrity (full list §7): cited entities resolve; verification stamp present and well-formed where required; cited nodes themselves satisfy their source obligation; the recorded anchor still matches current state; the explainer carries only pedagogy predicates.

**Crisp boundary:** the LLM decides *whether claims are supported* (semantic, build-time, writes the stamp). The validator decides *whether the stamp and citations are structurally well-formed and current* (mechanical, any-time, reads the stamp). The validator never re-derives the verdict.

### 4.3 Statement-id citation: dropped for v0, deferred as precision enhancement

The draft allowed `@core:cites` to target a statement-id (`s:<stmt-id>`) and proposed a `danglingCitesRef` rule covering both entity and statement-id targets. **This is dropped for v0.** Reason: there is NO statement-id reference kind in the system. Every ref-integrity rule gates on `value.startsWith("@")`, so a statement-id citation would be a parallel ref subsystem invisible to `danglingEntityRef`, `rangeViolation`, `crossLensFictional`, and `qualifierDanglingRef` — it would need an entirely new statement-id index plus a re-implementation of every ref-integrity check for the `s:` kind. That is real new machinery the draft hid behind "for free."

**v0: `@core:cites` resolves ENTITY refs only** (`@ns:slug`). This is covered by the existing `danglingEntityRef` (genuine reuse) plus the new `citedNodeSourced` rule. Synthesis-as-statement (§4.5b) therefore cites the concept ENTITY that bears the promoted statement.

**Precision limitation (stated honestly):** citing an entity does not pin *which* statement on that entity the explainer relied on. An explainer citing `@finance:compound-interest` is asserting "distilled from facts on this concept," not "distilled from statement s:abc1234 specifically." For v0 this coarser granularity is acceptable.

**Deferred precision enhancement:** statement-id-level citation. Cost, recorded so it is not re-hidden: a new statement-id index in `ValidateContext`, plus re-implementing every ref-integrity check (`danglingCitesRef` for `s:`, range/fictional/qualifier-dangling analogues) for the statement-id kind. Not v0 work.

### 4.4 Verification staleness

Trust in an explainer's stamp assumes the cited nodes have not drifted since verification. The `verified_against` qualifier records a revision/hash anchor per cited node at stamp time (`@ns:slug#<rev-anchor>`, comma-joined). The new deterministic rule **`verificationStale`** (§7) fires when the current state of a cited node's relevant statements no longer matches the recorded anchor. **Detection needs no LLM** (it is a hash/revision comparison); only *re-verification* (re-running the build-time judgment) needs the LLM. This protects the trust premise without per-query cost.

### 4.5 Synthetic / derived claims — BOTH paths (D1)

The corpus's core value is explaining *why*. A "why" is composed from premises and attested by no single node. Two representations are supported; the author chooses per claim.

**(a) In-explainer synthesis via `verification_status: "derived"`.** The composed claim lives only in the explainer's `content`. The explainer cites its premise nodes (`@core:cites`). The build-time verifier confirms (i) each premise is cited, (ii) each premise is individually `supported`, and (iii) the composed inference is valid — then stamps `verification_status: "derived"` (distinct from `supported`/`partial`/`unsupported`). At query time the stamp is precomputed, so serving is deterministic. The claim is citable (its premises are) and verifiable (premises supported + inference sound), without ever becoming a factual graph node.

*Worked example (a).* An explainer teaches "why you should start saving early": it cites `@finance:compound-interest` and `@finance:time-value-of-money`, asserts in prose the synthesized conclusion, and is stamped `verification_status: "derived"`, `verified_against` anchoring both premises. The conclusion is nowhere in the factual graph — it is a local pedagogical synthesis owned by this one explainer.

**(b) Synthesis-as-statement (promotion).** When a derived claim is reusable enough to belong in the factual graph, promote it to a real factual statement on the relevant concept node, sourced via `sources[].snippet` from a pedagogy/reference source; the explainer then `cites` that concept entity (entity-level, per §4.3).

*Worked example (b).* The claim "compound interest grows faster at higher compounding frequency" recurs across many explainers and is a genuine corpus fact. Promote it to a statement on `@finance:compound-interest` with a `sources[].snippet` from a finance reference. Any explainer needing it now `cites @finance:compound-interest`; `citedNodeSourced` confirms that entity's source obligation is met.

**Crisp boundary (a) vs (b):**
- Prefer **(a) `derived`** when the synthesis is **local to one explanation** — a pedagogical framing, an argument assembled for this lesson, not itself a reusable corpus fact.
- Prefer **(b) promotion** when the claim is **reused across multiple explainers** AND is **genuinely a corpus fact** (standalone-true, sourceable). Promotion pays the cost of a real sourced statement in exchange for reuse and entity-level citability.
- Rule of thumb: if you would cite it from a second explainer, promote it; if it only makes sense inside this explanation's argument, keep it `derived`.

## 5. Topic ontology design

### Shape (worked example)

```json
{ "id": "@topic:personal-finance",
  "labels": { "en": "Personal finance" },
  "description": "Money management for individuals and households.",
  "statements": [
    { "id": "s:tp1inst", "predicate": "@core:instance_of", "value": "@meta:topic", "lens": "core" },
    { "id": "s:tp2subt", "predicate": "@core:subtopic_of", "value": "@topic:finance", "lens": "core" }
  ] }
```
A concept tags itself with `about_topic`:
```json
{ "id": "s:ci9abt", "predicate": "@core:about_topic", "value": "@topic:personal-finance", "lens": "finance" }
```

### Predicate definitions (verbatim)

```json
{ "id": "@core:subtopic_of", "label": "subtopic of", "lens": "core",
  "description": "Asserts this topic is narrower than the object topic. Transitive — same closure engine as subclass_of, on the topic axis.",
  "value_type": "entity", "domain": ["@meta:topic"], "range": ["@meta:topic"],
  "cardinality": "0..*", "transitive": true }
```
```json
{ "id": "@core:about_topic", "label": "about topic", "lens": "core",
  "description": "Links any entity (typically a concept) to a subject topic it concerns. Orthogonal to instance_of: 'what kind of thing' (class) vs 'what subject' (topic).",
  "value_type": "entity", "domain": null, "range": ["@meta:topic"],
  "cardinality": "0..*", "inverse": "@core:topic_of" }
```

### Closure reuse (genuine) — acyclicity (NEW)

`subtopic_of` is `transitive:true` exactly like `subclass_of`, so the existing closure builder produces a `subtopicClosure` with **no new machinery for the closure itself** — same transitive-closure pass, different predicate. This part IS genuine reuse. Sample query "all concepts under `@topic:personal-finance`": compute `subtopicClosure(@topic:personal-finance)`, then return every entity with an `about_topic` statement whose value is in that set. Pure set ops over prebuilt closures — deterministic, no LLM.

**But acyclicity is NOT reused.** The draft claimed `subtopicOfAcyclic` "parallels the implicit class-hierarchy expectation." It does not: there is **no `subclass_of` acyclicity rule today** — `aliasCycle` (the structural template) only covers `alias_of`. `subtopicOfAcyclic` is genuinely NEW machinery (modeled on `aliasCycle`'s cycle-detection structure, but a new rule). Recommendation: also add the symmetric **`subclassOfAcyclic`**, since the class hierarchy currently has no cycle guard either — an existing gap this layer should close while the machinery is being written.

### subtopic_of vs subclass_of — decision procedure (NEW)

Two orthogonal hierarchies (class via `subclass_of`, topic via `subtopic_of`) with no cross-check between them is a real drift risk: a concept's class ancestry and topic tagging can diverge silently. Honest about that. Decision procedure for "is X a topic or a class?":

> **Topics are never instantiated.** If X has (or could have) instances — things that are *a kind of* X — it is a **class**, modeled with `subclass_of`. If X is a *subject area* that things are *about* but is never itself instantiated, it is a **topic**, modeled with `subtopic_of` + `about_topic`.

Optional **`topicClassAlignment`** warning (§7): fires when a concept's topics and its superclasses are **wholly disjoint** in subject — a heuristic drift signal, warning-severity only (the two hierarchies are legitimately orthogonal, so disjointness is suspicious but not always wrong).

### The hard part is curating, not the mechanism

The mechanism above is trivial; the intellectual product is the taxonomy itself. Curate it tiered: **human-curated upper/mid levels** (the topic tree's spine — stable, opinionated, small), and **construction-time-LLM-suggested leaf tagging** (the LLM proposes `about_topic` edges for new concepts) that is **human-reviewed before commit**. Do not auto-generate the upper tree and do not over-engineer tagging into ML; treat it as curation with LLM assistance. One concept may sit under multiple topics (`about_topic` is `0..*`), so the topic DAG need not be a strict tree.

## 6. Register / lens wrinkle (resolved)

**Tension:** Decision 3 says pedagogy lives *inside* each domain lens, distinguished by entity type (explainer) plus "possibly a pedagogical register." But `register` is a **lens-level** field today, not per-entity/per-statement. We cannot give the finance lens a pedagogical register without also retagging its factual statements.

**Decision: option (a) + a per-entity type marker — explainers inherit their domain lens's register; pedagogy is distinguished by entity TYPE (`instance_of @meta:explainer`), not by register.** No new register value, no per-statement register override.

Justification: an explainer in the finance lens IS factual content (it must be true and sourced); it belongs in `register:"factual"` exactly as the facts it distills do. Introducing a per-statement register or a new register value would add a schema field and a code path to express something the entity's *type* already expresses. The `@meta:explainer` type is the marker the spec hints at; it is sufficient. `register` stays lens-level and unchanged.

### Ownership — defined explicitly (was unvalidated convention)

The draft treated "explainers live in their domain lens" as convention. It is now an enforced rule, **`explainerOwnershipAligned`** (§7). Ownership defined: an explainer's **owning lens** is the lens that owns its entity (the `entityOwner` map). The rule requires (1) all of the explainer's statement lenses equal its owning lens, and (2) the owning lens equals — or declares `depends_on` — the lens of every concept it `explains`. This blocks cross-domain ownership confusion (a finance explainer secretly owning law concepts) that nothing validates today.

### Interaction with `crossLensFictional` — honest scope

`crossLensFictional` guards entity **REFERENCES** (it gates on `value.startsWith("@")`), **not prose ASSERTIONS**. An explainer's `content` is a string; the validator **cannot** police it for fictional leaks. The draft implied otherwise. Correct statement: register-safety for explainer *prose* is enforced **at BUILD TIME by the verification pass** (the LLM reading the content against its cited factual nodes), NOT by any validator rule. The validator catches a fictional *reference* in `cites`/`explains` (entity refs); it cannot catch a fictional *claim* written into `content`. No rule does, and the doc no longer pretends one does.

### Interaction with `source_required`

The finance lens is `source_required:true`. Two sub-cases:
- An explainer's `content`/`medium` statements are **not** external-document facts — they are distilled. Requiring an external `sources[].snippet` on them is wrong. **Carve-out: explainer statements (`explains`/`medium`/`content`/`cites`/`verified` on `@meta:explainer` entities) are exempt from `sourceRequiredViolation`**, mirroring the existing exemption for structural `instance_of`/`subclass_of` on class entities. This carve-out is a NEW edit to `sourceRequiredViolation`, not free behavior.
- The carve-out opens a **laundering hole** the draft missed: sentinel-valued statements (`"__sentinel__"`, from `{unknown}`/`{novalue}`) are ALREADY exempt from `sourceRequiredViolation`. An explainer could cite an unsourced or sentinel-valued node and inherit no source obligation. Closed by the new **`citedNodeSourced`** rule (§7): every entity an explainer cites must itself satisfy the source obligation, transitively closing the requirement. Deterministic, no LLM.
- The explainer's rigor obligation is the **entity-level** combination: ≥1 `@core:cites` + a verification stamp where required (NOT a per-statement source). Facts cite documents; explainers cite facts and get verified.

## 7. New validation rules (full set after pressure-test)

All pure `(ctx: ValidateContext) => Violation[]`, registered in `runAllRules`. Severity in parens. Each marked **[REUSE]** (existing rule genuinely covers it) or **[NEW]** (new machinery — the existing rule set does not cover it).

1. **`explains`/`medium`/`content` presence & cardinality** — **[REUSE]** generic `cardinalityViolationMin/Max` covers these now that `explains`/`medium`/`content` are `1..*` (min 1). No bespoke rule needed; do NOT claim a separate presence rule.
2. **medium in vocabulary** — **[REUSE]** existing `rangeViolation` (`medium` range `@meta:medium`, values are `@`-prefixed so the rule sees them). Genuine reuse.
3. **`contentShapeMatchesMedium`** (error) — **[NEW]** per `medium`, constrain `content` shape: `medium:interactive` → a `@component:*` ref or repo-relative path; `medium:video`/`audio`/`diagram` → URL-shaped or repo-relative path; `medium:text` → inline markdown (not URL/ref-shaped). Pairing: a `content` value is matched to a `medium` value by equal `rank`; if a single `content` serves multiple media, it must satisfy every declared medium's shape. This is the ONLY defense against content/medium type confusion — there is no value_type validation anywhere.
4. **`explainerCitesNonempty`** (error) — **[NEW]** explainers in a `source_required:true` lens have ≥1 `@core:cites`. Not covered by cardinality (`cites` is `0..*`); lens-conditional rigor.
5. **`danglingCitesRef`** (error) — **[REUSE, partial]** every `@core:cites` value (now entity-only, `@ns:slug`) resolves to an existing entity. This is fully covered by the existing `danglingEntityRef` since `cites` values are `@`-prefixed; keep as an alias/no-op or drop. (The draft's statement-id half is dropped — §4.3.) Mark honestly: NOT new machinery for v0.
6. **`citedNodeSourced`** (error) — **[NEW]** for an explainer in a `source_required` lens, every cited ENTITY must itself satisfy the source obligation (each of the cited entity's source-required statements is sourced or legitimately exempt). Transitively closes the obligation; closes the sentinel/unsourced laundering hole. Deterministic, no LLM.
7. **`verificationPresentWhenRequired`** (error) — **[NEW]** explainers in a `source_required:true` lens have a `@core:verified` statement whose `verification_status` qualifier ∈ {`supported`,`partial`,`unsupported`,`derived`}. Enforces the controlled vocabulary (no value_type does). Semantic correctness of the verdict is the build-time process's job.
8. **`verificationStale`** (error) — **[NEW]** fires when a cited node's current relevant-statement state ≠ the anchor recorded in `verified_against`. Hash/revision comparison; no LLM for detection. Protects the trust premise.
9. **`explainerStatementWhitelist`** (error) — **[NEW]** `@meta:explainer` entities may carry ONLY the pedagogy predicates (`explains`/`medium`/`content`/`cites`/`verified` + `instance_of`/labels/description); arbitrary factual predicates are forbidden. Enforces the boundary of the `source_required` carve-out so explainers cannot smuggle unsourced factual claims as statements. Obligation is ENTITY-level (the explainer has ≥1 `cites` and a stamp where required), not per-statement.
10. **`explainerOwnershipAligned`** (error) — **[NEW]** all of an explainer's statement lenses equal its owning lens, and the owning lens equals or `depends_on` the lens of every concept it `explains` (§6 ownership). Cross-domain ownership is unvalidated convention today.
11. **`subtopicOfAcyclic`** (error) — **[NEW]** the `subtopic_of` graph has no cycle. NOT a parallel of an existing rule — there is no `subclass_of` acyclicity rule; `aliasCycle` (the structural template) only covers `alias_of`.
12. **`subclassOfAcyclic`** (error, recommended) — **[NEW]** symmetric cycle guard for the class hierarchy, which currently has none. Close this existing gap while writing #11.
13. **`topicClassAlignment`** (warning) — **[NEW]** a concept's topics and superclasses are wholly disjoint (drift heuristic). Warning only; the hierarchies are legitimately orthogonal.
14. **dangling `about_topic` / `subtopic_of` refs** — **[REUSE]** existing `danglingEntityRef` (values `@`-prefixed). Genuine reuse.
15. **`sourceRequiredViolation` carve-out edit** — **[NEW edit]** add the explainer-statement exemption (§6). An edit to an existing rule, not free behavior.
16. **Predicate-def completeness** — not a rule but a build prerequisite: ship `core__verified_by.json`, `core__verification_status.json`, `core__verified_against.json` (and `core__subclass_of.json`-style files for any new core predicate) or `qualifierUnknownPredicate` warns on every qualifier use.

**Net genuinely-new machinery:** `contentShapeMatchesMedium`, `explainerCitesNonempty`, `citedNodeSourced`, `verificationPresentWhenRequired`, `verificationStale`, `explainerStatementWhitelist`, `explainerOwnershipAligned`, `subtopicOfAcyclic` (+ recommended `subclassOfAcyclic`), `topicClassAlignment` (warning), plus the `sourceRequiredViolation` carve-out edit. **Genuine reuse:** cardinality presence, medium-in-vocabulary, cites/topic dangling refs (all via existing cardinality/range/dangling rules on `@`-prefixed values).

## 8. Corpus-construction QA affordances

Deterministic, construction-time queries this design enables (closures + statement scans, no LLM):

- **Medium-coverage gaps** — per concept: `{all media} − {media of its explained_by explainers, unioned}` → which media lack an explainer. With `medium` `1..*`, union each explainer's full media set. Drives "comprehensive coverage" completeness.
- **Unverified-explainer report** — explainers lacking `@core:verified`, or with `verification_status` ∈ {`partial`,`unsupported`}.
- **Stale-verification report** — explainers flagged by `verificationStale` (anchor drift).
- **Untagged-concept report** — concepts with no `@core:about_topic` statement.
- **Topic/class drift report** — concepts flagged by `topicClassAlignment`.
- **Orphan topics** — topics with no inbound `about_topic` and not an upper-tree node (no `subtopic_of` children either).
- **Uncited explainers** — explainers with zero `@core:cites` (subset of rule 4, useful as a report even outside source-required lenses).

## 9. Open seams (carry forward)

- **Interactive-component embedding** — `content` for `medium:interactive` holds a manifest reference; the manifest format and embedding mechanism (WASM / Web Component / sandboxed iframe-with-small-API) is unresolved. Plugs in at `content`'s value (validated by `contentShapeMatchesMedium`) with no other schema change; likely a future `@component:*` namespace. Cross-ref: master plan "Open questions / interactive-component-embedding," verify against Dusklight's renderer/plugin model. **Note (exotic/analogical explainers):** this seam is directly motivated by the captured "exotic explanation modes" use case — a spellcasting-visualization explainer for parsers is a `medium:interactive` explainer in the fictional/interpretive lens, `cites`-ing the relevant parser-concept entities. Exotic/analogical framings (storytelling, game mechanics, spellcasting) are an ordinary use of the interpretive lens + omnimedia layer: the fanciful overlay is an explainer entity in a fictional-register lens; the factual parser/typechecker entities stay in the factual lens; the lens system prevents contamination. See design-overview.md "Exotic / analogical explanation modes (captured idea)."
- **Dusklight medium selection** — the deterministic ranked pick over `explained_by` filtered by `medium` is specified in §3 (any-medium match + fixed tie-break); the wiring of that pick into a Dusklight config/query is a Dusklight concern, out of scope here. Cross-ref: master plan "Architecture / Engine."
- **Statement-id-level citation** — deferred precision enhancement (§4.3): a new statement-id index plus re-implementing every ref-integrity check for the `s:` kind. Not v0.
- **Final home** — this design moves into the corpus repo (`~/git/pterror/<corpus>`) when that repo is created; for now it is a plans-dir design doc.
