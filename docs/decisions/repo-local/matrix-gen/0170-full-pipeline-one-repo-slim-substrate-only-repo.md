# ADR-0170: Full pipeline in one repo, not a slim substrate-only repo

- Status: Accepted
- Date: 2026-05-29

**Context.** The project could have been scoped narrowly to just the simulator substrate, or broadly to include the MATRIX-Gen synthesis layer and data export.

**Decision.** Keep the full pipeline (simulator + MATRIX-Gen synthesis + data export) in a single repo, deliberately choosing the broader scope.

**Alternatives rejected.**
- *A slimmer 'just the substrate' framing (simulator only, synthesis elsewhere)* — Scope chosen deliberately over the slimmer framing because splitting later is cheaper than merging.

**Consequences.** Simulator and synthesis layer co-evolve in one workspace; export lives here too. A future split remains possible (and is the cheaper direction), but is not done now. Mined from: /home/me/git/pterror/matrix-gen/CLAUDE.md (19).
