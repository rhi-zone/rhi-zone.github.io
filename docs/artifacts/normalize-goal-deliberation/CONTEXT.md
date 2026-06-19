# CONTEXT — Decision layer (design-stage glossary)

Design-stage Ubiquitous Language for normalize's decision-reconstruction layer. Each term is challenged against normalize's own `CONTEXT.md` ("Ubiquitous Language"); terms graduate into that file only once the design is validated. This is **not** normalize's shipped vocabulary yet.

## Decision
_Avoid:_ Symbol, PlannedEdit, Commit, "Intent"/grouping (a non-leaf Decision, not a separate type)

A node in a program's recursive **decision tree**: the **root** Decision is the originating purpose ("this feature exists"); each **non-leaf** Decision is a purpose that spawns child Decisions; the **leaves** are the atomic irreducible choices — the units you author going forward and that reconstruction resolves toward. The machine derives a Decision's determined consequences (its "shrapnel"); the Decision itself is **authored** (forward) or **recovered** from evidence (backward).

Treating "Decision" as only the atomic leaf loses the higher-purpose nodes and the root. A "grouping of Decisions unified by a purpose" is **not** a separate kind of thing — it is just a non-leaf Decision; do not reintroduce a parallel "Intent" term. A **Symbol** or **PlannedEdit** is the rendered artifact a Decision produces, not the choice. A **Commit** is *evidence* for reconstructing Decisions, not a Decision.

## Changeset
_Avoid:_ pinning it to a single grouping; treating "a Decision's changeset" and "a Commit's changeset" as different types

A set of **Edits** under a grouping key — any such set. The primitive is the Edit; a Changeset is a grouping of them: by owning **Decision** ("a Decision's changeset"), by **Commit** ("a Commit's changeset"), etc. "A Decision's changeset" and "a Commit's changeset" are the **same concept under different keys**, not different types — one Edit belongs to both a Decision and a Commit.

Grouping semantics differ by key: by-Decision can aggregate a Decision's edits across its whole evolution (many Commits over time); by-Commit is a single point-in-time snapshot. That difference is a property of the key, not a different kind of Changeset.

Reifying one grouping (e.g. "the Decision changeset") into a distinct type invents a collision with "the Commit changeset" that does not exist — they are one notion sliced two ways.

## Projection
_Avoid:_ surface-projection (server-less / one definition → CLI·HTTP·MCP), "the AST" or "the representation" as authoritative

A bidirectional **lens** over code: `get` (substrate → view) and `put` (edited view + original → substrate change). A *view of the program* an Edit is expressed over. Projections are plural and pluggable; **none is authoritative.** They span *naive, near-lossless* projections (text, AST) to *lossy* ones (control-flow graph, type graph, call graph). A lossy projection's `put` is under-determined — the **view-update problem**. A near-lossless projection (AST) can serve as the reconciliation **medium** — lossless enough to put through — which is a practical role, not authority.

## Edit
_Avoid:_ PlannedEdit (normalize's transient whole-file form), text-diff, patch

A **transformation-as-data** expressed over a **Projection** and anchored structurally — the *choice* itself ("rename to Bar", "add param `p: T`", "change this condition"). Version-neutral; NOT a text before/after. Realized against a specific version by **materialize**. Supersedes reusing normalize's whole-file `PlannedEdit` as the manifestation primitive.

## materialize
`materialize(Edit, original) → Diff` — the lens **put**. Resolves an Edit's transformation against a specific **original** (a version of the substrate / AST), producing the concrete substrate change. The original supplies the information the projection dropped, so put-ambiguity is **confined to the edited locus** rather than spanning the whole source (the standard state-based-lens resolution of the view-update problem). This is also where **version-pinning** happens — the `original` *is* a version. Where the put stays under-determined at the locus, that residual *is* a **spawned Decision** (a choice the view-edit didn't pin) — the handoff point for an oracle/verifier.

## Diff
_Avoid:_ Edit (the version-neutral choice), Changeset (a grouping), Commit, PlannedEdit

The concrete, **version-bound** substrate change produced by `materialize(Edit, original)` — the realized form of an Edit at a specific version. Distinct from the Edit (the neutral transformation) and from a Changeset (a grouping of Edits).

## Identity
_Avoid:_ "the identity" (there is none), the primary key (a key is an opaque handle, not the identity), a single chosen id scheme

A Decision (or Edit) has no single identity — it has a **pluggable family of purpose-relative identity-projections** (name/path, structural hash, similarity-anchored lineage, version-pinned anchor, …), none authoritative; each answers a different question (display, exact dedup, cross-evolution tracking, "as realized at version V"). For storage/reference an **opaque primary key** (e.g. a UUID) labels a Decision — deliberately *meaningless*, so that no identity-projection is privileged as "the" key (a meaningful key, e.g. the hash, would re-crown one projection as authoritative). The load-bearing work is **identity resolution** — deciding which observations share a key, and when to split or merge one — via structural similarity + commit/co-change evidence, oracle-refinable. The key's *format* is not load-bearing; the *resolution* is.

## Evidence
_Avoid:_ treating git commits as the only or canonical source

Any signal usable to reconstruct Decisions and Edits, acquired through **plural, pluggable means** at differing granularity and semantic level — e.g. **git commits** (coarse, semantic-ish grouping ≈ one intent; usually needs an Oracle to distill into Decisions), **session logs** (captured intent/reasoning — the "why" that commits and text discard), **individual write commands** (fine-grained diffs — precise Edits, little intent). No source is canonical; the source set is pluggable; reconstruction fuses them.

## Reconstruction
_Avoid:_ a single canonical reconstruction step; git-commits-as-the-reconstruction

There is no single canonical reconstruction step. Reconstruction **acquires Evidence from plural sources and fuses it** into Decisions (and their tree) + Edits: fine-grained sources (write commands) supply precise Edits/Diffs; coarse semantic sources (commits, session logs) supply grouping/intent and usually need an **Oracle** to distill into usable Decisions. Pluggable in its evidence sources; Oracle/verifier-refinable.

## Oracle
_Avoid:_ "the LLM" / a single canonical decider; the control loop

A *role*, not a specific tool: any external decider that proposes or refines reconstruction (grouping, identity resolution, spawned-Decision fills) — a human, an LLM, a solver, a heuristic. Fillable **plurally; none canonical**; the control surface is decider-agnostic. The Oracle proposes/refines **at the leaves, gated by verification — never the control loop.**

## Relationships
- A **Decision** contains zero or more child **Decisions** (atomic Decisions are leaves; the root is the originating purpose). The tree is the structure; "purpose grouping" is just a non-leaf node viewed by intent.
- A **Commit** (and co-change, structural similarity) is *evidence* used to reconstruct Decisions/their tree — not itself a Decision.
- An **Edit** is a version-neutral transformation-as-data over a **Projection**; `materialize(Edit, original) → Diff` is the lens `put` that realizes it against a specific version.
- A **Decision** manifests as a **Changeset** — a grouping of **Edits** keyed to it; "a Decision's changeset" and "a Commit's changeset" are the same notion under different keys.
- A **Projection** is a lens (`get`/`put`); text & AST are near-lossless, richer views (CFG, types, call graph) are lossy; AST can be the reconciliation *medium* (medium ≠ authority).
- An under-determined `put` at the edited locus surfaces a **spawned Decision**.
- A **Decision** is referenced by an opaque **primary key**; its name/hash/lineage/etc. are **identity-projections** attached to that key — none authoritative (identity is plural, like code-Projections).
- **Identity resolution** (similarity + commit/co-change evidence + oracle) decides which observations share a key (and when to split/merge); the key's format is not load-bearing, the resolution is.
- **Reconstruction** fuses plural **Evidence** sources (git commits, session logs, write commands, …) into **Decisions** + **Edits**; no source and no step is canonical. Fine sources give precise Edits; coarse semantic sources give grouping/intent (Oracle-distilled).
- An **Oracle** is any external decider (human / LLM / solver / heuristic — *not* specifically an LLM); it proposes/refines at the leaves, gated by verification, and is never the control loop.
