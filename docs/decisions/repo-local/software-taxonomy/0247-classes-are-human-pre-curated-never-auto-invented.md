# ADR-0247: Classes are human-pre-curated, never auto-invented during ingest

- Status: Accepted
- Date: 2026-05-29

**Context.** Bulk LLM-assisted ingest (phases 5-6) will encounter instances that don't fit any existing class. Letting ingest create classes on the fly would let the model invent the taxonomy.

**Decision.** Classes (clades) are pre-curated by humans; an ingest tool that meets an instance not fitting an existing class proposes a new class for review rather than creating it automatically. New classes require a synapomorphy (not just a label), >=3 known instances, and a clean fit under an existing superclass.

**Alternatives rejected.**
- *Auto-invent classes during ingest when an instance doesn't fit* — Would let the model fabricate the taxonomy; the substrate-pre-seed pattern (Phase 3.0) is made the general rule so humans control clade structure

**Consequences.** Ingest tools must emit class proposals, not class creations. The 3-instance/synapomorphy/superclass-fit checklist gates every new clade. Constrains the phase 5-6 ingest tool design. Mined from: /home/me/git/pterror/software-taxonomy/CLAUDE.md (89).
