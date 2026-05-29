# Decisions (ADRs)

Architecture Decision Records for the rhi ecosystem.

## What an ADR is here

A short, durable record of one architecturally significant decision: the context
that forced it, what was decided, the alternatives that lost (and why), and the
consequences. ADRs are append-only history — once accepted, a decision is not
edited away; it is superseded by a later ADR that cites it.

## Numbering

ADRs are numbered sequentially, zero-padded to four digits, with a kebab-case
slug: `NNNN-short-slug.md`. Numbers are never reused.

## ADR-0001 is intentionally composite

`0001-knowledge-corpus-foundations.md` records the foundational decisions for the
omnimedia knowledge-corpus effort as a single composite ADR. These decisions are
tightly interlinked — the substrate choice, the dissolution of the "engine," the
annotation layer, and the projection layer only make sense relative to one
another — so they are recorded together to preserve the narrative. This is a
deliberate exception. **Future decisions get atomic ADRs:** one decision per
record.

## Scope: ecosystem vs corpus-specific

Ecosystem-level decisions live here. Decisions specific to the knowledge corpus
itself may move to the corpus repo (`github:pterror`) once that repo exists. Until
then, the corpus's foundational decisions are recorded here in ADR-0001.
