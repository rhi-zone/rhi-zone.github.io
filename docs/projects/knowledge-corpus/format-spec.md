# Knowledge Corpus Document Format — Specification (FINAL)

Status: DECIDED. This is the settled specification, not an exploration. Options doc:
`format-options.md`. Master plan: `design-overview.md`
("Substrate decision" section). This document supersedes the open question those
docs left, and is the contract the software-taxonomy refactor implements.

---

## 1. Overview & principles

### 1.1 The model is RDF / RDF-star (by derivation, not by adoption)

The conceptual contract is **RDF with RDF-star semantics**:

- Knowledge is a set of **subject–predicate–object** assertions (statements).
- Statements are **addressable / reifiable** — you can name a statement and assert
  things *about* it (annotations on statements).
- Annotations are themselves statements, so the model is uniform and recursive.

We did not start from RDF and adopt it. We started from three constraints —
**(a) no blessed metadata**, **(b) uniformity** (metadata and data are the same kind
of thing), **(c) statement-addressability** (you must be able to point at a statement
to annotate it) — and rederived the subject/predicate/object + reified-statement
shape. That shape *is* RDF-star. So the model is **RDF-equivalent by design**, which
makes a trivial RDF-star export possible (§3) without ever committing the corpus to
RDF tooling, triple stores, or RDF serializations.

### 1.2 No-blessed-metadata principle

> The format must not declare required, official, or privileged *metadata* fields.
> The only blessing permitted is what is structurally unavoidable.

Operationally: the format blesses **only** the act of assertion (`predicate` +
`value`), statement **addressability** (an optional `id`), and the entity
**container** (`id` + `statements`). It blesses **nothing in metadata position**.
`rank`, `lens`, `sources`, time-bounds, evidence-grade, roles — every formerly-blessed
field — is an ordinary, open-bag key on a statement: none named by the format, none
required, none schema-enforced. §2.3 argues this surface is the irreducible minimum.

### 1.3 Document-native serialization

The serialization is **our own clean JSON**, **document-native**, **entity-per-file**.
It is explicitly **NOT Turtle and NOT JSON-LD** — those are RDF serializations carrying
RDF's framing and ceremony. We keep RDF *semantics* and reject RDF *syntax*. The
document is the source of truth: git-diffable, human- and LLM-authorable, one entity
per file.

### 1.4 Separation of concerns

- **Format** (this spec) — how knowledge is written down. Purely the on-disk shape.
- **Projection / query** — **Dusklight's** job. Universal, substrate-independent,
  shape-agnostic. The format makes no projection commitments.
- **Validation** — **per-corpus tooling**. Each corpus defines its own rules over the
  documents. There is no shared/blessed validation engine and no triple store.

There is no engine. The former "engine" dissolves into format + Dusklight + per-corpus
validation.

---

## 2. The format, precisely

### 2.1 Entity document

One file per entity. The file is a JSON object:

```json
{
  "id": "@software:nginx",
  "statements": [ ]
}
```

- `id` — the entity's identifier, namespaced `@<ns>:<slug>`, `@` stored. The entity
  is the **implicit subject** of every statement in `statements`. No statement repeats
  the subject; it is the document it lives in.
- `statements` — an array of statement objects (§2.2).

`id` and `statements` are the only blessed **container** keys. Everything else an
author might want at entity level (`labels`, `aliases`, `description`, …) is expressed
as **ordinary statements** — they are assertions about the entity, so they belong in
`statements` under ordinary predicates, not as blessed top-level keys. (Migration note:
software-taxonomy currently blesses `labels`/`aliases`/`description`/`lens` at entity
level; under this spec they demote to statements. See §4.)

### 2.2 Statement

A statement is a JSON object. Its only structural keys are `predicate` and `value`
(the assertion), plus an optional `id` (addressability):

```json
{
  "predicate": "@core:developed_by",
  "value": "@person:igor-sysoev"
}
```

- `predicate` — the relation. A reference (`@ns:slug`) into the corpus's predicate
  vocabulary. **Structure**, not metadata.
- `value` — the object of the assertion (§2.4). **Structure**, not metadata.
- `id` — OPTIONAL. A statement identifier (e.g. `s:032sfj3`). Present only when
  something must point *at* this statement (annotation/reification, §2.7). Its absence
  is meaningful: an unaddressed statement is one nothing external refers to.
- **all other keys** — ORDINARY METADATA. Open bag. `rank`, `lens`, `sources`,
  `start_time`, `evidence_grade`, anything. The format names none of them, requires
  none, and special-cases none. Tooling that reads them does so as *corpus* policy,
  never as *format* structure.

### 2.3 The blessed surface (minimal — argued)

The complete blessed surface is:

| Position | Blessed keys | Why it cannot be demoted |
|---|---|---|
| Entity container | `id`, `statements` | A document needs identity (so other entities can reference it) and a place to put assertions. Removing either makes the file not-a-knowledge-document. |
| Statement structure | `predicate`, `value` | This is the act of assertion. You cannot say *anything* without committing to a relation and an object. Blessing this is blessing assertion itself, not blessing a metadata field. |
| Statement addressability | `id` (optional) | The moment you want to say something *about* a statement (provenance, rank, annotation), the statement must be addressable. Reference presupposes an addressable referent. This is the irreducible floor identified in the options analysis. |

**Argument that this is the irreducible minimum.** Three things are genuinely
unavoidable: (1) **identity** — addressability, so things can refer to things; present
as entity `id` and statement `id`. (2) **reference** — a value can denote another node
(handled as the `@`-prefix *convention* on values, §2.4, so it is not even a structural
slot). (3) **assertion shape** — `predicate` + `value`; the thinnest encoding of "X
relates to Y." Everything else — `rank`, `lens`, `sources`, qualifiers, evidence-grade,
the binary-vs-n-ary commitment — sits *above* this floor and is expressed as ordinary
data (metadata keys, or nested nodes per §2.6/§2.7). **Nothing in metadata position is
blessed.** We do **not** bless a named metadata container (no `meta` / `about` bag):
metadata keys live directly on the statement as siblings of `predicate`/`value`,
distinguished from structure only by *not being* `predicate`/`value`/`id`. This is one
fewer blessing than a named bag and keeps the format flat.

### 2.4 Value kinds

`value` may be exactly one of:

1. **Literal** — a JSON string, number, boolean, or null. The terminal datum.
   ```json
   { "predicate": "@core:first_released", "value": "2004-10-04" }
   ```
2. **Reference** — a string of the form `@ns:slug`, denoting another entity. The
   `@`-prefix is the reference *convention* (not a structural slot): a string value
   beginning with `@` is interpreted as a reference, otherwise as a string literal.
   ```json
   { "predicate": "@core:written_in", "value": "@language:c" }
   ```
3. **Inline anonymous node** — a JSON object that is itself a node/assertion bundle
   with **no external `id`**. Used for cohesion and for n-ary structure (§2.6).
   ```json
   { "predicate": "@core:employment", "value": { "@core:role": "maintainer", "@core:org": "@org:f5-inc" } }
   ```
4. **Array** — an ordered list whose elements are any of the above (§2.5).
   ```json
   { "predicate": "@core:authors", "value": ["@person:a", "@person:b"] }
   ```

### 2.5 Multiplicity vs ordered-list — the disambiguation

These are **distinct constructs** and the format keeps them unambiguous:

- **Multiplicity** (a predicate that holds of several objects, unordered) =
  **repeated statements with the same predicate**.
  ```json
  "statements": [
    { "predicate": "@core:developed_by", "value": "@person:igor-sysoev" },
    { "predicate": "@core:developed_by", "value": "@org:f5-inc" }
  ]
  ```
- **Ordered list** (a single assertion whose object *is* a sequence) = **one statement
  whose `value` is a JSON array**.
  ```json
  { "predicate": "@core:release_order", "value": ["@release:0-1", "@release:0-5", "@release:1-0"] }
  ```

Because multiplicity is carried by *repetition*, an array `value` is never ambiguous —
it can only mean "this single assertion's object is an ordered collection." This gives
the corpus **first-class ordered collections** for free (closing a gap noted in the
master plan's value-layer audit).

### 2.6 N-ary relations

An n-ary fact ("A employed B as C from D to E") is a single assertion whose `value` (or
a role-bearing key) is an **inline anonymous node** with multiple keys. No information
is forced into a binary base + dangling qualifiers; the n-ary relation is modeled
directly:

```json
{
  "predicate": "@core:employment",
  "value": {
    "@core:employee": "@person:igor-sysoev",
    "@core:employer": "@org:f5-inc",
    "@core:role": "@role:principal-engineer",
    "@core:start_time": "2011",
    "@core:end_time": "2019"
  }
}
```

The inline node is an anonymous subject; its keys are predicate→value pairs. Promote it
to a named node (give it an `id` and a file) only if something external must reference
it (§2.7).

### 2.7 Reification / annotation — via id-or-nesting

Saying something *about* a statement has two equivalent mechanisms; choose per case:

- **By id (reference).** Give the statement an `id`; another statement's `value`
  references that id. Use when the annotation must be addressable from elsewhere or
  must itself be a top-level statement.
- **By nesting.** A metadata key's value is itself a value-object (inline node), or a
  metadata value carries its own nested structure. Use for locality/cohesion. **No
  separate `subject` field is ever needed — nesting carries the subject implicitly**
  (the enclosing statement is the subject of its nested annotation).

Both are the same operation in the model (an annotation triple on a reified statement);
they differ only in whether the reified statement is named or anonymous. This mirrors
the inline-vs-referenced choice for nodes (§2.4): **inline = anonymous, referenced =
named, same thing, chosen per assertion.**

### 2.8 Worked examples (verbatim)

**(a) Bare fact** — assertion only, no metadata, no id:
```json
{ "predicate": "@core:written_in", "value": "@language:c" }
```

**(b) Fact with metadata** — ordinary open-bag keys (`rank`, `lens`, `sources`,
time-bounds) as siblings of the assertion; nothing here is blessed:
```json
{
  "id": "s:032sfj3",
  "predicate": "@core:developed_by",
  "value": "@person:igor-sysoev",
  "rank": "deprecated",
  "lens": "core",
  "start_time": "2004",
  "end_time": "2019",
  "sources": [
    { "ref": "wp:nginx@1353230091",
      "snippet": "The software was created by Russian developer [[Igor Sysoev]]..." }
  ]
}
```

**(c) Multi-valued predicate** — multiplicity by repetition:
```json
[
  { "predicate": "@core:developed_by", "value": "@person:igor-sysoev",
    "rank": "deprecated", "start_time": "2004", "end_time": "2019" },
  { "predicate": "@core:developed_by", "value": "@org:f5-inc",
    "rank": "preferred", "start_time": "2019" }
]
```

**(d) Ordered-list value** — array object, single assertion:
```json
{ "predicate": "@core:changelog_order",
  "value": ["@release:1-0-0", "@release:1-2-0", "@release:1-4-0"] }
```

**(e) N-ary / qualified fact** — inline anonymous node carries all roles:
```json
{
  "predicate": "@core:acquisition",
  "value": {
    "@core:acquired": "@software:nginx",
    "@core:acquirer": "@org:f5-inc",
    "@core:date": "2019-03-11",
    "@core:price_usd": 670000000
  }
}
```

**(f) Statement about a statement (annotation)** — `s:r-prov` annotates `s:032sfj3`
by reference; equivalently the `provenance` annotation could be nested inline:
```json
[
  { "id": "s:032sfj3", "predicate": "@core:developed_by", "value": "@person:igor-sysoev" },
  { "id": "s:r-prov", "predicate": "@meta:asserted_by", "value": "@source:wikipedia",
    "about": "s:032sfj3" }
]
```
Inline-nested equivalent (no ids, subject carried by nesting):
```json
{
  "predicate": "@core:developed_by",
  "value": "@person:igor-sysoev",
  "provenance": { "@meta:asserted_by": "@source:wikipedia", "@meta:confidence": "high" }
}
```
Here `about` and `provenance` are ordinary metadata keys (corpus vocabulary), not
blessed format keys — the format only provides the *capability* (id + reference, or
nesting); the *naming* is the corpus's choice.

---

## 3. RDF-star mapping (for the exporter)

The export target is **RDF-star** (RDF 1.1 + quoted/annotated triples). The mapping is
total and mechanical; an implementer can build the exporter from this section alone.

### 3.1 Identifiers → IRIs

- **Entity id** `@ns:slug` → IRI `<BASE><ns>/<slug>`, where `<BASE>` is a corpus base
  IRI (e.g. `https://corpus.example/`). The leading `@` is dropped; the single `:`
  separating ns and slug becomes a `/`. (Alternatively a per-`ns` `PREFIX ns:
  <BASE><ns>/` declaration with the term `ns:slug` — equivalent.)
- **Predicate** `@ns:slug` → IRI by the same rule. Predicates are IRIs like any term.
- **Statement id** `s:xxxxxxx` → either a blank node or, if stable IRIs are wanted,
  `<BASE>statement/<id>`. Only needed when the statement is annotated/reified (§3.5).

### 3.2 Statement → triple

For a statement on entity E (E is the subject IRI from §3.1):

`E  <predicate-IRI>  <object>  .`

The object is produced from `value` per §3.3–3.4.

### 3.3 Value literal → typed literal

- string → `"…"^^xsd:string` (or plain literal).
- number (integer) → `"…"^^xsd:integer`; (decimal) → `"…"^^xsd:decimal`.
- boolean → `"…"^^xsd:boolean`.
- null → omit the triple, or map to a corpus-defined sentinel IRI (corpus policy).
- **Datatype/units beyond JSON primitives are NOT inferred by the exporter.** A value
  like `"2004-10-04"` is exported as `xsd:string` unless the corpus supplies a typing
  convention (e.g. a `datatype` metadata key on the statement, or per-predicate range
  metadata). Typed/unit handling is corpus vocabulary (§6 open question), so the
  exporter reads it from corpus-provided metadata, not from the format.

### 3.4 Value reference → IRI

A string value matching `@ns:slug` → the IRI from §3.1, emitted as the triple's object
IRI (not a literal).

### 3.5 Inline anonymous node → blank node

An object-valued `value` (or any nested inline node) → a fresh **blank node** `_:bN`.
The blank node becomes the object of the enclosing triple, and each key/value of the
inline node becomes a triple `_:bN  <key-IRI>  <object> .` (recursing through §3.3–3.5).
This is exactly RDF's standard n-ary-relation-via-blank-node pattern.

### 3.6 Array value → ordered list

An array `value` → an RDF ordered collection. Default encoding: **`rdf:List`**
(`rdf:first`/`rdf:rest`/`rdf:nil` cons cells), so element order is preserved:

```
E  <pred>  _:l0 .
_:l0 rdf:first <elem0-object> ; rdf:rest _:l1 .
_:l1 rdf:first <elem1-object> ; rdf:rest rdf:nil .
```

Each element object is produced by §3.3–3.5. (An exporter MAY instead emit numbered
`rdf:_1…rdf:_n` container members; `rdf:List` is the chosen default for exact-order
fidelity.)

### 3.7 Statement id + metadata → RDF-star reified triple + annotation triples

When a statement carries metadata keys (anything beyond `predicate`/`value`/`id`) or is
referenced by another statement, emit the base triple as a **quoted/annotated triple**
and attach each metadata key as an annotation:

```
<< E <pred> <object> >>  <metakey-IRI>  <metavalue-object> .
```

- Each ordinary metadata key → an annotation predicate IRI (§3.1 applied to the key if
  it is a `@ns:slug`; corpus-local bare keys get a `<BASE>meta/<key>` IRI).
- Each metadata value → object via §3.3–3.5 (literals, references, inline→blank,
  arrays→list, recursively — so nested annotations and provenance-of-provenance map to
  annotations on annotations).
- A statement referenced **by id** from elsewhere: the referencing statement's value
  becomes the quoted triple `<< E <pred> <object> >>` (RDF-star quoting *is* the
  reference), so `about: "s:032sfj3"` resolves to a quoted-triple object.

This makes the export well-specified end to end: entity→subject IRI, predicate→IRI,
literal→typed literal, reference→IRI, inline node→blank node, array→rdf:List, statement
id+metadata→RDF-star reified triple with annotation triples.

---

## 4. Migration delta from software-taxonomy

Grounded in the current source: `tooling/src/lib/entity-file.ts`, `tooling/src/lib/load.ts`,
`tooling/src/lib/schema.ts`, and `data/entities/software/nginx.json`.

### 4.1 Current shape (verbatim, from `entity-file.ts`)

```ts
export interface Statement {
  id: string;
  predicate: string;
  value: unknown;
  rank?: string;
  qualifiers?: Record<string, unknown>;
  lens: string;
  sources?: Array<{ id: string; snippet?: string }>;
}

export interface EntityFile {
  id: string;
  lens?: string;
  labels?: Record<string, string>;
  aliases?: string[];
  description?: string;
  statements: Statement[];
}
```

Current `nginx.json` statement (verbatim, `s:032sfj3`):

```json
{
  "id": "s:032sfj3",
  "predicate": "@core:developed_by",
  "value": "@person:igor-sysoev",
  "lens": "core",
  "rank": "deprecated",
  "qualifiers": { "@core:start_time": "2004", "@core:end_time": "2019" },
  "sources": [
    { "id": "wp:nginx@1353230091",
      "snippet": "The software was created by Russian developer [[Igor Sysoev]]..." }
  ]
}
```

### 4.2 What is KEPT

- **Entity-per-file** JSON at `data/entities/<ns>/<slug>.json`. Unchanged.
- **Entity `id`** (`@ns:slug`, `@` stored) and the **`statements` array**. Unchanged —
  these are the two blessed container keys.
- **`predicate` + `value`** on each statement. Unchanged — the blessed assertion.
- **Statement `id`** (`s:<7char base36>`). Kept, but now **optional** (present when the
  statement is addressed/annotated). The existing minting helper (`freshStmtId`) and
  uniqueness collection (`collectExistingStmtIds`) stay for statements that need ids.
- The **`@`-prefix reference convention** on values. Unchanged.

### 4.3 What is DEMOTED (blessed fields → ordinary open-bag keys)

The `Statement` interface stops typing metadata. `rank`, `lens`, `sources`,
`qualifiers` are no longer named/typed fields — they become ordinary keys in the open
bag, indistinguishable at the format level from any other metadata key:

```ts
// NEW — format-level type
interface Statement {
  predicate: string;          // blessed: the assertion relation
  value: unknown;             // blessed: literal | "@ref" | inline-node | array
  id?: string;                // blessed-optional: addressability
  [metaKey: string]: unknown; // open bag — rank, lens, sources, time-bounds, etc.
}

interface EntityFile {
  id: string;
  statements: Statement[];
  // labels / aliases / description / lens NO LONGER blessed top-level keys
}
```

Concretely for `s:032sfj3`, the demotion is near-mechanical (it is largely a *type*
change, not a *data* change — the keys already sit on the object; `qualifiers`'
contents flatten up to sibling keys, or stay nested as a plain metadata key):

```json
{
  "id": "s:032sfj3",
  "predicate": "@core:developed_by",
  "value": "@person:igor-sysoev",
  "rank": "deprecated",
  "lens": "core",
  "@core:start_time": "2004",
  "@core:end_time": "2019",
  "sources": [ { "ref": "wp:nginx@1353230091", "snippet": "..." } ]
}
```

(`qualifiers` may be flattened to sibling keys as shown, or retained as one nested
metadata key `"qualifiers": {…}` — both are legal open-bag data; the corpus picks a
convention. `sources[].id` → `sources[].ref` is cosmetic and optional.)

**Entity-level demotion.** `labels`, `aliases`, `description`, and entity `lens` stop
being blessed top-level keys and become **statements** (assertions about the entity)
under ordinary predicates, e.g. `@core:label`, `@core:alias`, `@core:description`. This
is the larger data migration: a script rewrites each entity file, moving those four
fields into `statements`. (If the corpus prefers to keep them as a pragmatic
convenience, they may remain as conventional top-level keys — but the format does not
bless them; tooling must not name-check them as structure.)

### 4.4 What is DELETED

- **The EAV triple store / `@thi.ng/rstream-query` layer entirely** (`store.ts`,
  `schema.ts`'s blessed-attribute registry, and `load.ts`'s transact-into-EAV body).
  It is an ephemeral in-memory index rebuilt each run, never persisted; every nontrivial
  query already scans documents and post-processes in TS. It adds no capability.
- The `statement/subject` synthesized attribute (subject is the document, never stored
  per-statement) and the `__sentinel__` value coercion (sentinels stay as ordinary
  JSON values; any interpretation is per-corpus).

### 4.5 Tooling changes

- **`load.ts` simplifies drastically.** It no longer builds an EAV `Db`. It becomes:
  read each entity file → `JSON.parse` → return the documents (a list of
  `EntityFile`s), plus whatever in-memory index a *per-corpus helper* wants to build
  (e.g. an `id → statement` map for annotation resolution, a `subject → statements` map
  is unneeded since subject = document). The `findStatementLine` / `statement/file` /
  `statement/line` provenance can stay as a thin file-scan utility if tooling wants
  source locations.
- **`schema.ts`'s blessed-attribute registry goes away** as a *format* artifact. A
  corpus may keep a **per-corpus vocabulary** (predicate definitions: value_type,
  domain, range, cardinality) as ordinary corpus data/config — but it is per-corpus
  validation vocabulary, not a blessed format schema, and the format never reads it.
- **`rules.ts` stays, per-corpus.** Validation rules become pure functions over the
  documents (and over the per-corpus indexes built in `load.ts`). Closures
  (subclass/subtopic transitive closure) and ref-integrity checks reimplement as TS
  fixpoints/scans over documents — which is already how they effectively run today.
- **`entity-file.ts`'s read/write/path helpers stay**; only the `Statement`/`EntityFile`
  interfaces loosen per §4.3.

---

## 5. How the annotation layer rides on this

The annotation/topic-ontology layer (`annotation-schema.md`) requires
**no special-casing** in this format. Confirmed against that doc's key shapes:

- **Explainers are ordinary entities.** `@explainer:compound-interest-text-01` is an
  entity-per-file document with `instance_of @meta:explainer`. Its pedagogy relations —
  `@core:explains`, `@core:medium`, `@core:content`, `@core:cites`, `@core:verified` —
  are **ordinary predicates** (statements with `predicate`/`value`), no different from
  `@core:developed_by`.
- **Topics are ordinary entities.** `@topic:personal-finance` with `instance_of
  @meta:topic` and `subtopic_of @topic:finance` — ordinary statements. `about_topic` on
  a concept is an ordinary statement.
- **Verification metadata is ordinary open-bag metadata.** The annotation doc's
  `@core:verified` statement with `qualifiers: { @core:verified_by, …,
  @core:verification_status, @core:verified_against }` maps directly: `qualifiers`
  is just open-bag metadata on a statement (or its keys flatten to siblings, per §4.3).
  No blessed `qualifiers` slot needed.
- **`medium`/`cites`/`verified` multiplicity** (relaxed to `1..*` in that doc) is
  multiplicity-by-repetition (§2.5) — repeated `@core:medium` / `@core:cites`
  statements. Ordered media preference, if ever needed, is an array value (§2.5).
- **`verified_against`** (currently a comma-joined `@ns:slug#rev` string) could become a
  cleaner array value or inline-node list under this format, but the current string is
  legal open-bag data and needs no change for v0.

So the entire pedagogy/citation/topic layer is "entities + statements in this format."
The new *validation rules* that doc specifies are per-corpus `rules.ts` functions (§4.5)
— the format itself stays untouched by the annotation layer.

---

## 6. Open sub-questions (flagged, not resolved)

1. **Identity scheme.** Explicit `id` (current; stable, but minted/threaded by hand and
   noisy in diffs) vs **content-hash** (dedup-friendly, but changes on every edit) vs
   **positional** (file-path + array index; zero ceremony, but unstable under reorder).
   The spec assumes explicit `id`; the choice is genuinely open and interacts with
   diff-noise, dedup, and the RDF-star statement-IRI mapping (§3.1).
2. **Literal datatype / unit handling.** How are typed literals and units expressed as
   ordinary data? Candidates: a `datatype`/`unit` metadata key per statement;
   per-predicate range metadata in the per-corpus vocabulary; or a structured inline
   value-node (`{ "@core:amount": 5, "@core:unit": "@unit:percent" }`). The exporter
   (§3.3) currently defaults everything non-primitive to `xsd:string` pending this
   decision. Open.
3. **Reference resolution.** `@ns:slug` → file path is `data/entities/<ns>/<slug>.json`
   today (in `entityFilePath`). Is that mapping blessed by the format, or per-corpus
   convention? Leaning per-corpus (the format only blesses the `@`-prefix *convention*,
   not the file layout), but the corpus needs one fixed rule. Open.
4. **Is `value` the right structural key name?** `value` reads as metadata-ish; `object`
   would track RDF vocabulary exactly. Kept `value` for continuity with the current
   corpus, but this is a cosmetic-but-permanent naming decision worth a deliberate call.
5. **Flatten vs nest `qualifiers`.** Whether time-bounds and similar qualifiers flatten
   to sibling metadata keys (§4.3) or stay under a nested `qualifiers` key is a
   per-corpus convention the spec does not fix. Affects RDF-star annotation shape.
6. **Multiplicity ordering across files / merge.** Repeated-statement multiplicity has
   no inherent order; if a consumer needs stable order without promoting to an array
   value, that ordering is undefined. Open whether the corpus needs a tie-break rule.
