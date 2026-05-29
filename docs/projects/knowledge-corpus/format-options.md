# No-Blessed-Metadata Knowledge Document Format — Design Options

> **DECIDED — see `format-spec.md`.** This options doc is retained for the reasoning
> trail. The landed design is RDF/RDF-star semantics with our own document-native JSON
> serialization (entity-per-file): blessed surface is only `predicate`+`value`+optional
> statement `id` and the entity container `id`/`statements`; all metadata is ordinary
> open-bag keys (no `meta`/`about` container blessed). It is closest to Option 2/3's
> spirit but flatter than Option 3 (no named bag) and reaches Option 1/4's
> reification/n-ary power via inline anonymous nodes + id-or-nesting. The final,
> implementable specification is `format-spec.md`.

Status: DECISION-READY OPTIONS. No choice made. The user picks.

## Frame

Settled decisions (not reopened here):

- Substrate is **document-native**: open JSON, entity-per-file, git-diffable, source of truth.
- Triples-as-substrate **rejected** (incidental complexity).
- Projection/query is **Dusklight's** job (universal, substrate-independent). Not this format's concern.
- Validation is **per-corpus tooling**.

This spec answers one question only: **how is knowledge written down as documents, honoring "no blessed metadata"?**

The principle every option is judged against:

> **No blessed/authoritative metadata.** The format must not declare required/official/privileged fields. The only blessing allowed is what is truly unavoidable. The user's words: "no authoritative 'we shall have X and Y and Z metadata'."

Two distinct ways to "not bless" a field, and the whole document turns on the difference:

- **Unblessed by structure** — the format *cannot express* a privileged field; metadata and data are the same kind of thing at the schema level. A blessing would require changing the format.
- **Unblessed by convention** — the format *permits* anything; some keys happen to be common, but nothing in the core privileges them. A blessing is just a popular key.

---

## 1. Current (blessed) baseline — quoted

From `~/git/pterror/software-taxonomy/tooling/src/lib/entity-file.ts`:

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

What is **blessed** here (named, privileged, special-cased by tooling):

- Statement-level: `id`, `predicate`, `value`, `rank`, `qualifiers`, `lens`, `sources` (and within `sources`: `id`, `snippet`).
- Entity-level: `id`, `lens`, `labels`, `aliases`, `description`, `statements`.

And the tooling acts on these names explicitly. In `load.ts`:

```ts
"statement/value": isSentinelValue(stmt.value) ? "__sentinel__" : String(stmt.value),
"statement/lens":  stmt.lens,
...(stmt.rank       !== undefined && { "statement/rank":       stmt.rank }),
...(stmt.qualifiers !== undefined && { "statement/qualifiers": JSON.stringify(stmt.qualifiers) }),
```

`rank`, `qualifiers`, `lens`, `sources` are each read by name. This is the maximally-blessed end of the spectrum. Note the irony for the principle: `qualifiers` is *already* an open bag (`Record<string, unknown>`) — start_time/end_time live there as ordinary keys. So the corpus already proves "open bag for metadata" works in practice. The question is how far to push that.

The real example fact this document tracks (verbatim from `data/entities/software/nginx.json`, statement `s:032sfj3`), enriched per the brief with an explicit lens and a source revision:

> nginx was **developed_by** Igor Sysoev, **2004–2019**, ranked **deprecated** (historical), sourced from **Wikipedia rev 1353230091**, asserted under the **core** factual lens.

Current rendering:

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

---

## Option 1 — Statements-about-statements (full reification)

Every statement has an id. `rank`, `lens`, `source`, time-bounds are themselves **separate statements** whose subject is that id. Maximally uniform: there is exactly one kind of thing (a statement), and a statement can be the subject of another statement, recursively.

The entity file is a flat list of statements; cohesion is "all statements whose subject is (transitively) this entity."

```json
{
  "id": "@software:nginx",
  "statements": [
    { "id": "s:032sfj3", "subject": "@software:nginx",
      "predicate": "@core:developed_by", "value": "@person:igor-sysoev" },

    { "id": "s:r1", "subject": "s:032sfj3", "predicate": "@meta:rank",       "value": "deprecated" },
    { "id": "s:r2", "subject": "s:032sfj3", "predicate": "@meta:lens",       "value": "core" },
    { "id": "s:r3", "subject": "s:032sfj3", "predicate": "@core:start_time", "value": "2004" },
    { "id": "s:r4", "subject": "s:032sfj3", "predicate": "@core:end_time",   "value": "2019" },
    { "id": "s:r5", "subject": "s:032sfj3", "predicate": "@meta:source",     "value": "wp:nginx@1353230091" },

    { "id": "s:r6", "subject": "s:r5", "predicate": "@meta:snippet",
      "value": "The software was created by Russian developer [[Igor Sysoev]]..." }
  ]
}
```

`s:r6` annotates `s:r5` (the source link), demonstrating arbitrary-depth annotation: you can say things about a source-assertion as easily as about the base fact. No depth limit, no special case.

Blessed surface: `id`, `subject`, `predicate`, `value` — and that's **all**. `rank`/`lens`/`source`/time are not in the format; they are predicates in the corpus's vocabulary, indistinguishable from `developed_by`.

- **Principle**: Strongest possible. Structurally unblessed for everything except the s/p/v/id quad. There is no place in the schema to privilege "rank."
- **Authoring ergonomics**: Worst. One human-meaningful fact explodes into 6–7 records with generated ids. Git diffs scatter: changing the end_time touches a record visually far from the base fact. An LLM must mint and thread ids correctly across records — high error surface. Reading a file, you cannot see "the nginx developed_by fact" as a unit; you reassemble it by following `subject` pointers.
- **Saying things about statements**: Trivial and uniform — this is the whole point. Nesting is free.
- **Tooling**: Plain TS must build an in-memory index `subject -> statements` to reconstitute a fact and its metadata (effectively a join). Every consumer re-derives this. Closure/validation helpers all operate post-join. This re-introduces, in code, exactly the EAV/triple indirection the substrate decision rejected at the storage layer. The data file is documents; the access pattern is triples.
- **Dusklight projection**: Worst fit for optics. Field-access/array-iteration optics want `stmt.qualifiers.start_time`. Here Dusklight must traverse by `subject` reference — a graph walk, not a field access. Cleanly projectable only if Dusklight is given a reification-aware lens that does the join first.
- **Migration cost**: High. Each current statement becomes 1 + N records; ids must be minted for every metadata assertion.

---

## Option 2 — Open nested objects (unblessed by convention)

A statement is an open JSON object. `rank`/`lens`/`sources` are keys authors **may** use; the format mandates none and the core special-cases none. Tooling treats all keys uniformly — it iterates `Object.entries(stmt)`, it does not read `stmt.rank` by name.

```json
{
  "id": "@software:nginx",
  "statements": [
    {
      "subject": "@software:nginx",
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
  ]
}
```

The fact reads as one cohesive unit; rank/lens/time/source are sibling keys with no privileged status in code.

- **Principle**: Unblessed **by convention only**. Schema-wise nothing is required, but `rank` and `lens` are de-facto blessed the moment a second corpus copies the key and tooling starts expecting it. Nothing structural stops drift back into blessing. This is the crux: it satisfies the *letter* ("the format declares no required fields") while being weak on the *spirit* ("no authoritative we-shall-have-X"). The honest claim is "no blessing in the *format*; blessing can still emerge in a *corpus*."
- **What stops de-facto blessing**: Only discipline + the rule that core tooling never name-checks a key. A registry-of-conventions (documented, not enforced) is the realistic guardrail. There is no structural backstop.
- **Authoring ergonomics**: Best. Closest to what humans and LLMs already produce; minimal ceremony; one fact = one object; clean git diffs (changing end_time is a one-line edit in place).
- **Saying things about statements**: Easy for one level (metadata are keys). Saying something about a *metadata value* (e.g. provenance of the rank) is awkward — you'd nest objects (`"rank": { "value": "deprecated", "source": "..." }`), and now "scalar vs annotated" is ambiguous and per-key. Recursion is possible but inelegant and non-uniform.
- **Tooling**: Simplest. Parse JSON, iterate keys. No join. Closure/validation helpers walk objects directly. Whether they treat any key specially is a *policy* choice the format does not force.
- **Dusklight projection**: Best fit. `stmt.rank`, `stmt.sources[].ref` are direct optic targets. Field access and array iteration land exactly.
- **Migration cost**: Lowest. Drop `id`/keep-or-flatten `qualifiers` from the current shape; nearly a rename. (Current `qualifiers` already *is* this pattern.)

---

## Option 3 — Hybrid: minimal blessed core + open bag

Bless only the irreducible — statement-addressability plus the assertion triad — and put **everything else** in a single open, uniformly-treated metadata space. The core knows the triad and the bag; it knows *nothing* about what is in the bag.

```json
{
  "id": "@software:nginx",
  "statements": [
    {
      "id": "s:032sfj3",
      "subject": "@software:nginx",
      "predicate": "@core:developed_by",
      "value": "@person:igor-sysoev",
      "meta": {
        "rank": "deprecated",
        "lens": "core",
        "start_time": "2004",
        "end_time": "2019",
        "sources": [ { "ref": "wp:nginx@1353230091", "snippet": "..." } ]
      }
    }
  ]
}
```

Blessed surface: `id`, `subject`, `predicate`, `value`, and the *existence* of `meta` (an opaque bag). The keys *inside* `meta` are pure convention — the core never reads them by name. This makes the blessed/unblessed boundary **explicit and visible in the file**: anything outside `meta` is structural; anything inside is corpus vocabulary.

- **Principle**: Middle, and arguably the most *honest*. It does not pretend rank/lens are unblessed-by-structure (Option 1's claim) nor leave the boundary implicit (Option 2). It draws a hard line: "these four things are blessed and we say so; nothing else is." The blessing surface is small, named, and defensible. The weakness: `meta` itself is a (small) blessing, and the s/p/v triad is still blessed (see irreducible analysis).
- **Authoring ergonomics**: Very good. One fact = one object with a clear "facts vs about-the-fact" split. Slightly more nesting than Option 2; git diffs stay local. LLMs handle the two-bucket shape reliably.
- **Saying things about statements**: One level is the bag (clean). Deeper annotation (provenance of the rank) needs either nested objects in `meta` (Option-2 awkwardness) or a separate statement with `subject: "s:032sfj3"` (Option-1 mechanism). So Option 3 can *borrow* reification for the rare deep case while keeping the common case flat — a pragmatic mixed mode.
- **Tooling**: Simple. Core helpers operate on the triad uniformly and pass `meta` through opaquely; corpus helpers interpret `meta`. Clean separation of "format-level" vs "corpus-level" code.
- **Dusklight projection**: Good. `stmt.value` and `stmt.meta.rank` are direct optic targets; one extra hop vs Option 2.
- **Migration cost**: Low. Move `rank`/`lens`/`qualifiers`/`sources` under `meta`; keep `id`/`subject`/`predicate`/`value`. Mechanical, scriptable.

---

## Option 4 — Reified-bag hybrid (meta entries are themselves statements)

A variant probing "can metadata be statements without exploding the file?" The base fact is a cohesive object (Option-3 style), but its `meta` is an **array of inline statement objects** keyed implicitly to the parent — reification kept *local* to the fact rather than scattered across the file.

```json
{
  "id": "@software:nginx",
  "statements": [
    {
      "id": "s:032sfj3",
      "subject": "@software:nginx",
      "predicate": "@core:developed_by",
      "value": "@person:igor-sysoev",
      "about": [
        { "predicate": "@meta:rank",       "value": "deprecated" },
        { "predicate": "@meta:lens",       "value": "core" },
        { "predicate": "@core:start_time", "value": "2004" },
        { "predicate": "@core:end_time",   "value": "2019" },
        { "predicate": "@meta:source",     "value": "wp:nginx@1353230091",
          "about": [ { "predicate": "@meta:snippet", "value": "The software was created..." } ] }
      ]
    }
  ]
}
```

Each `about` entry is the same p/v shape as a statement (subject implied = parent). The last entry shows recursion: an `about` on the source-assertion. This gets Option 1's uniformity and unbounded nesting **and** Option 2/3's file cohesion (the whole fact stays in one place, one git-diff locus).

- **Principle**: Strong. Metadata is structurally the same shape as data (p/v + nested `about`); no metadata *key* is blessed. Blessed surface: `predicate`, `value`, `about`, plus `id`/`subject` at the top. The `@meta:` namespace is convention, not structure.
- **Authoring ergonomics**: Middle. More verbose than 2/3 (each metadatum is `{predicate, value}` not a key) but cohesive and uniform. LLMs handle the regular shape well; the regularity is easier to generate correctly than Option 1's id-threading.
- **Saying things about statements**: Excellent and uniform at any depth via nested `about`. No id-minting needed for the common case (subject is positional/implied).
- **Tooling**: Moderate. Uniform recursive walk (`about` is the only recursion point). No global join (cohesion is local), so simpler than Option 1's index. Lookups like "rank of this fact" = scan `about` for `@meta:rank`.
- **Dusklight projection**: Moderate. Not a direct `stmt.rank` field; requires "find the about-entry with predicate X." Projects cleanly only with a small helper optic (find-by-predicate). Worse than 2/3, better than 1 (local not graph-wide).
- **Migration cost**: Moderate. Each current metadata key/qualifier/source becomes an `about` entry. Scriptable.

---

## Irreducible-blessing analysis — how thin can it go?

The user wants the smallest mandatory blessed surface. Working from most-aggressive thinning inward:

**Is `rank`/`lens`/`sources`/`qualifiers` irreducible?** No. All four are corpus *vocabulary*. Every option above (1, 3, 4) demonstrates expressing them as ordinary data. They can be fully unblessed. (Option 2 leaves them as conventional keys but still unblessed in the format.) **Verdict: not irreducible.**

**Is `predicate`/`value` (the binary-relation shape) irreducible?** This is the real question. Two positions:

- *Pro-blessing the triad*: A knowledge document is, minimally, "X relates-to Y in way Z." Subject/predicate/value is the thinnest encoding of that, and you cannot say anything without committing to *some* shape. Blessing s/p/v is blessing the act of assertion itself, not a metadata field. This is closer to "unavoidable" than to "we shall have X metadata."
- *Anti-blessing the triad*: s/p/v privileges **binary** relations. An n-ary fact ("A employed B as C from D to E") is forced into one binary base + qualifiers, which is itself a modeling bias — a soft blessing. The triple-substrate rejection was partly about this rigidity. A thinner primitive: **nodes and references**. A document is a set of nodes; a node may *reference* other nodes by id; nothing privileges a "predicate" slot. JSON objects with id-bearing references already are this. Under this view even `predicate`/`value` are unblessed; you have only: *things have identity, and things can point at other things.*

The genuinely irreducible minimum, pushed all the way:

1. **Identity** — some way to address a thing so other things can refer to it. *This is unavoidable* the moment you want to say something *about* a statement (provenance, rank). Reference presupposes an addressable referent. Whether the address is an explicit `id` field, a content hash, or positional (file-path + array index) is open — but *some* addressing scheme must be blessed. **Irreducible.**
2. **Reference** — a value can denote another node rather than be a literal. Without this you have isolated records, not knowledge. **Irreducible** (but note: this can be a *convention* — "a string starting with `@` is a reference" — rather than a structural slot; references can be unblessed-by-convention while identity stays blessed-by-structure).

Everything else — predicate, value, subject, rank, lens, source, even the binary-vs-n-ary commitment — is *above* this floor and can be pushed into convention or vocabulary.

So the spectrum of defensible "blessed cores," thinnest to thickest:

- **Floor (thinnest)**: identity + reference. Nodes that can point at nodes. (Implies an Option-2-like open object whose only privileged thing is `id` and the reference convention.)
- **+ assertion shape**: floor + `subject`/`predicate`/`value`. (Options 1, 3, 4.) Blesses binary relations.
- **+ metadata container**: above + a named `meta` bag. (Option 3.) One more blessing, bought for explicitness.

The honest finding: **`id` (addressability) is the one thing every option that wants statement-about-statement provenance must bless.** Even Option 2 needs it the moment you annotate an annotation. The smallest possible blessed surface is therefore *identity + a reference convention* — and the central design choice is how much *above that floor* you bless for the sake of ergonomics and tooling.

---

## Comparison table

| Criterion | Baseline | 1 Reification | 2 Open objects | 3 Core+bag | 4 Reified-bag |
|---|---|---|---|---|---|
| Blessed surface | id,pred,value,rank,quals,lens,sources | id,subject,pred,value | id (+ref conv.) | id,subject,pred,value,`meta` | id,subject,pred,value,`about` |
| Unblessed: by structure / convention | neither | structure | convention | structure (bag boundary explicit) | structure |
| Honors the *spirit* of the principle | no | strongest | weakest | strong+honest | strong |
| Authoring ergonomics (human) | good | worst | best | very good | middle |
| LLM construction reliability | good | worst (id threading) | best | very good | good (regular shape) |
| Git-diff legibility | good | scattered | best | good | good (local) |
| Entity-file cohesion | good | poor (reassemble) | best | good | good |
| Say things about statements | qualifiers only | trivial, uniform, ∞ depth | awkward past 1 level | 1 level clean; deep via borrow | uniform, ∞ depth, local |
| Tooling over plain JSON | name-checks keys | needs join/index | iterate keys | triad + opaque bag | recursive walk |
| Dusklight optics fit | direct | worst (graph walk) | best (direct fields) | good (one hop) | moderate (find-by-pred) |
| Migration cost from baseline | — | high | lowest | low | moderate |
| n-ary / non-binary facts | poor | natural | poor | poor | natural |

---

## Recommendation framing — the genuine fork

The central tension is **purity/uniformity vs ergonomics/cohesion**, and it bottoms out in *which kind of "unblessed" the user actually wants*:

- If "no blessed metadata" means **structurally impossible to privilege a metadata field**, the answer is reification — Option 1 (scattered) or Option 4 (local). Option 4 dominates Option 1: same structural purity and unbounded nesting, but keeps a fact cohesive in one file location and avoids global id-threading. The cost is real but bounded: more verbose authoring, find-by-predicate access, weaker Dusklight optics.

- If "no blessed metadata" means **the format imposes no required/privileged fields, and blessing is forbidden in the format even if conventions emerge in a corpus**, then Option 2 or 3. Option 2 is the lightest and most ergonomic but leaves the blessed/unblessed boundary *implicit and undefended* — de-facto blessing can creep back with nothing structural to stop it. Option 3 draws that boundary *explicitly in the file* (`meta` is the unblessed zone), keeps the blessed core tiny and named, migrates cheaply, and projects cleanly.

**Where I lean (the user decides):** Option 3, the minimal-core + open bag, with the door left open to *borrow* Option 4/1's `subject`-pointing reification for the rare case of annotating an annotation. Reasoning:

- It makes the principle *operational and honest*: it doesn't claim rank is unblessed-by-structure while everyone special-cases it (Option 2's quiet failure); it names a four-element blessed core and declares everything else corpus vocabulary inside a visible boundary.
- The four blessed elements collapse close to the irreducible floor: `id` is irreducible (addressability for provenance); `subject`/`predicate`/`value` is the defensible "assertion shape" blessing; `meta` is the one *added* blessing, and it's bought specifically to make the unblessed zone explicit.
- It wins on the practical axes that determine whether the corpus actually gets written and consumed: LLM/human authoring, git diffs, plain-TS tooling without a join, and Dusklight optics — while costing the least to migrate from the current shape (which already uses an open `qualifiers` bag).

The fork to put to the user, stated plainly:

> **Do you want "no blessed metadata" to be a structural guarantee (nothing in the schema can ever privilege a metadata field → Option 4, accept verbosity and weaker optics), or a small honest declared boundary (a tiny named core; everything else is corpus vocabulary in an explicit bag → Option 3, accept that the s/p/v triad and a `meta` container are blessed)?**

The deeper, sharper version of the same fork — worth surfacing because it lets the user go *thinner* than any option above: **is even `subject`/`predicate`/`value` too much blessing?** If binary-relation bias is itself objectionable, drop to the floor (identity + reference convention; nodes that point at nodes) and let "predicate" be vocabulary. That is the purest possible reading and the user may want it; it costs the most in tooling and authoring discipline and is essentially Option 2 with `id` as the *only* structural blessing.

---

## Honest uncertainties

- **The n-ary question is underexplored.** I treated facts as binary + qualifiers throughout (because that's the corpus today), but "developed_by Igor 2004–2019" is arguably one 4-ary fact, not a binary fact with two time qualifiers. If the corpus will routinely carry genuinely n-ary facts, that pushes toward Option 1/4 (or the floor) harder than the table suggests, because the s/p/v blessing becomes an active modeling constraint, not a neutral one.
- **Dusklight's optic vocabulary is assumed, not verified.** I assumed field-access + array-iteration + a find-by-predicate helper. If Dusklight already has (or wants) reference-following optics, Option 4/1 project far better than rated and the ergonomic gap to Option 3 narrows. This should be checked against Dusklight's actual optic set before committing.
- **"Borrowing reification" in Option 3 is a real seam.** Allowing both `meta.rank` (flat) and `subject`-pointing statements (deep) means two ways to express provenance-of-metadata. That flexibility could become inconsistency across the corpus without a convention pinning down when to use which. It needs a per-corpus rule.
- **Identity scheme is left open** (explicit `id` vs content-hash vs positional). This is a separate sub-decision with its own tradeoffs (stability under edit, diff noise, dedup) and interacts with all options; not analyzed here.
- **De-facto blessing under Option 2/3** is a social/governance risk I can describe but not quantify. Whether convention holds depends on tooling discipline over time, which is outside what the format alone can guarantee.
