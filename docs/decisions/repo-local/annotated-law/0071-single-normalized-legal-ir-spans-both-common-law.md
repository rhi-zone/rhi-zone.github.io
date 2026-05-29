# ADR-0071: Single normalized legal IR spans both common-law and civil-law without flattening

- Status: Accepted
- Date: 2026-05-29

**Context.** Jurisdictions differ structurally: common-law systems (US/UK/CA/AU) weight case law heavily, while civil-law systems (EU/DE/FR) have deep codification and different regulatory hierarchies. The IR design must choose between one unifying representation and per-legal-family representations.

**Decision.** Use one normalized legal IR that accommodates both common-law and civil-law sources without flattening the distinctions that matter, with cross-references as a first-class edge type, per-node version history and provenance, and per-jurisdiction ingestion adapters feeding the shared IR — so each new jurisdiction is a new adapter, not new architecture.

**Alternatives rejected.**
- *Separate representations per legal family, or a single IR that flattens common-law/civil-law structural differences* — A single IR is required to accommodate both 'without flattening the distinctions that matter'; flattening would erase case-law-weight and codification-depth differences that are substantive, and separate IRs would mean new architecture per jurisdiction rather than just a new adapter.

**Consequences.** Adapters absorb format variance; the IR stays stable as jurisdictions are added (Phase 3 = adapters only). The IR's generality is deliberately unproven until a second, structurally different jurisdiction is ingested (Phase 1+); civil-law jurisdictions are deferred to stress-test it later. Mined from: /home/me/.claude/plans/snuggly-wobbling-melody.md (24), /home/me/.claude/plans/snuggly-wobbling-melody.md (79), /home/me/.claude/plans/snuggly-wobbling-melody.md (48).
