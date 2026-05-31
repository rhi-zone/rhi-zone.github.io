# ADR-0127: Colocation over fragmentation: related facts on one entity, not linked sub-entities

- Status: Accepted
- Date: 2026-05-29

**Context.** Complex entities (e.g. a character with many body parts) could be modeled either by colocating all facts on one entity or by splitting details into separate linked entities referenced via <code v-pre>{{entity:ID}}</code>.

**Decision.** Keep related information together on one entity rather than splitting it across multiple linked entities. The fragmented approach is rejected not for engineering reasons but for LLM cognitive load.

**Alternatives rejected.**
- *Fragmentation (body parts / details as separate linked entities)* — requires multiple 'leaps in logic' — the LLM must fetch multiple entities, understand relationships, and coordinate changes across them; fragmented data is harder to reason about

**Consequences.** Entities tend toward self-contained context blobs the LLM sees and edits in place; cross-entity linking is reserved for genuinely separate things. This is justified by LLM reasoning load, explicitly not by code complexity. Mined from: /home/me/git/exoplace/hologram/docs/philosophy.md (43), /home/me/git/exoplace/hologram/docs/philosophy.md (65).
